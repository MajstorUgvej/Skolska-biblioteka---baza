-- Pogledi

-- Svi korisnici koji nisu vratili knjigu (aktivne pozajmice)
CREATE VIEW vw_AktivnePozajmice AS
SELECT 
    p.IdPozajmice,
    c.Ime + ' ' + c.Prezime AS ClanImePrezime,
    tc.NazivTipa AS TipClana,
    c.RazredOdeljenje,
    k.Naslov AS NaslovKnjige,
    pr.InventarskiBroj,
    p.DatumPozajmljivanja,
    p.RokZaVracanje,
    DATEDIFF(day, p.RokZaVracanje, GETDATE()) AS DanaKasnjenja -- Pozitivna vrednost označava broj dana kašnjenja
FROM Pozajmica p
JOIN Clan c ON p.IdClana = c.IdClana
JOIN TipClana tc ON c.IdTipa = tc.IdTipa
JOIN Primerak pr ON p.IdPrimerka = pr.IdPrimerka
JOIN Knjiga k ON pr.IdKnjige = k.IdKnjige
WHERE p.DatumVracanja IS NULL;
GO

-- Sve knjige
CREATE VIEW vw_KnjigePregled AS
SELECT 
    k.IdKnjige,
    k.Naslov,
    k.ISBN,
    k.GodinaIzdanja,
    kat.NazivKategorije,
    CONCAT(a.Ime, ' ', a.Prezime) AS [Autori],
    COUNT(p.IdPrimerka) AS UkupnoPrimeraka
FROM Knjiga k
JOIN Kategorija kat ON k.IdKategorije = kat.IdKategorije
LEFT JOIN Knjiga_Autor ka ON k.IdKnjige = ka.IdKnjige
LEFT JOIN Autor a ON ka.IdAutora = a.IdAutora
LEFT JOIN Primerak p ON k.IdKnjige = p.IdKnjige
GROUP BY k.IdKnjige, k.Naslov, k.ISBN, k.GodinaIzdanja, kat.NazivKategorije, a.Ime, a.Prezime;
GO


-- Funkcije

-- broj slobodnih primeraka knjige za odredjeni Id
CREATE FUNCTION fn_BrojSlobodnihPrimeraka (@IdKnjige INT)
RETURNS INT
AS
BEGIN
    DECLARE @BrojSlobodnih INT;
    
    SELECT @BrojSlobodnih = COUNT(*)
    FROM Primerak
    WHERE IdKnjige = @IdKnjige AND Status = N'Slobodan';
    
    RETURN ISNULL(@BrojSlobodnih, 0);
END;
GO


-- Istorija svih pozajmica nekog clana
CREATE FUNCTION fn_PozajmiceClana (@IdClana INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.IdPozajmice,
        k.Naslov AS NaslovKnjige,
        pr.InventarskiBroj,
        p.DatumPozajmljivanja,
        p.RokZaVracanje,
        p.DatumVracanja,
        CASE 
            WHEN p.DatumVracanja IS NULL AND p.RokZaVracanje < GETDATE() THEN N'Prekoračen rok'
            WHEN p.DatumVracanja IS NULL THEN N'Uzeta'
            WHEN p.DatumVracanja > p.RokZaVracanje THEN N'Vraćena (kasno)'
            ELSE N'Vraćena'
        END AS StatusPozajmice
    FROM Pozajmica p
    JOIN Primerak pr ON p.IdPrimerka = pr.IdPrimerka
    JOIN Knjiga k ON pr.IdKnjige = k.IdKnjige
    WHERE p.IdClana = @IdClana
);
GO


-- Svi clanovi koji kasne duze ili jednako od odredjenog dana kasnjenja
CREATE FUNCTION fn_ClanoviSaPrekoracenjem (@MinimalnoDanaKasnjenja INT)
RETURNS @Rezultat TABLE (
    IdClana INT,
    ImePrezime NVARCHAR(100),
    TipClana NVARCHAR(50),
    NaslovKnjige NVARCHAR(200),
    InventarskiBroj NVARCHAR(50),
    DanaKasnjenja INT
)
AS
BEGIN
    INSERT INTO @Rezultat
    SELECT 
        c.IdClana,
        c.Ime + N' ' + c.Prezime,
        tc.NazivTipa,
        k.Naslov,
        pr.InventarskiBroj,
        DATEDIFF(day, p.RokZaVracanje, GETDATE())
    FROM Pozajmica p
    JOIN Clan c ON p.IdClana = c.IdClana
    JOIN TipClana tc ON c.IdTipa = tc.IdTipa
    JOIN Primerak pr ON p.IdPrimerka = pr.IdPrimerka
    JOIN Knjiga k ON pr.IdKnjige = k.IdKnjige
    WHERE p.DatumVracanja IS NULL 
      AND DATEDIFF(day, p.RokZaVracanje, GETDATE()) >= @MinimalnoDanaKasnjenja;

    RETURN;
END;
GO


-- Uskladistene procedure

-- Registruje novu pozajmicu (vrsi validaciju i unos nove pozajmice ako je to moguce), vraca id nove pozajmice
CREATE PROCEDURE sp_EvidentirajPozajmicu
    @IdClana INT,
    @IdPrimerka INT,
    @BrojDanaZaVracanje INT = 14,
    @IdPozajmiceOutput INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validacija postojanja člana i primerka
    IF NOT EXISTS (SELECT 1 FROM Clan WHERE IdClana = @IdClana)
    BEGIN
        RAISERROR(N'Član sa datim ID-jem ne postoji.', 16, 1);
        RETURN;
    END

    DECLARE @TrenutniStatus NVARCHAR(20);
    SELECT @TrenutniStatus = Status FROM Primerak WHERE IdPrimerka = @IdPrimerka;

    IF @TrenutniStatus IS NULL
    BEGIN
        RAISERROR(N'Primerak sa datim ID-jem ne postoji.', 16, 1);
        RETURN;
    END

    IF @TrenutniStatus != N'Slobodan'
    BEGIN
        RAISERROR(N'Primerak knjige nije slobodan za izdavanje.', 16, 1);
        RETURN;
    END

    -- Početak transakcije
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @Danas DATE = GETDATE();
        DECLARE @Rok DATE = DATEADD(day, @BrojDanaZaVracanje, @Danas);

        -- 1. Unos pozajmice
        INSERT INTO Pozajmica (DatumPozajmljivanja, RokZaVracanje, DatumVracanja, IdClana, IdPrimerka)
        VALUES (@Danas, @Rok, NULL, @IdClana, @IdPrimerka);

        SET @IdPozajmiceOutput = SCOPE_IDENTITY(); -- uzima poslednji id unet, tj id nove pozajmice

        -- 2. Ažuriranje statusa primerka
        UPDATE Primerak
        SET Status = N'Pozajmljen'
        WHERE IdPrimerka = @IdPrimerka;

        -- Potvrda transakcije
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Poništavanje transakcije u slučaju greške
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH
END;
GO

-- Registurije vracanje knjige, vraca kašnjenje u danima
CREATE PROCEDURE sp_EvidentirajVracanje
    @IdPrimerka INT,
    @NoviStatusPrimerka NVARCHAR(20) = N'Slobodan', -- Može biti 'Slobodan' ili 'Oštećen'
    @DaniKasnjenjaOutput INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Provera validnosti novog statusa
    IF @NoviStatusPrimerka NOT IN (N'Slobodan', N'Oštećen')
    BEGIN
        RAISERROR(N'Nevažeći status. Dozvoljeni su samo Slobodan i Oštećen.', 16, 1);
        RETURN;
    END

    DECLARE @IdPozajmice INT;
    DECLARE @RokZaVracanje DATE;

    -- Pronalazenje aktivne pozajmice za taj primerak
    SELECT @IdPozajmice = IdPozajmice, @RokZaVracanje = RokZaVracanje
    FROM Pozajmica
    WHERE IdPrimerka = @IdPrimerka AND DatumVracanja IS NULL;

    IF @IdPozajmice IS NULL
    BEGIN
        RAISERROR(N'Ne postoji aktivna pozajmica za prosleđeni primerak.', 16, 1);
        RETURN;
    END

    -- Racunanje kasnjenja
    DECLARE @Danas DATE = GETDATE();
    DECLARE @RazlikaDana INT = DATEDIFF(day, @RokZaVracanje, @Danas);
    
    IF @RazlikaDana > 0
        SET @DaniKasnjenjaOutput = @RazlikaDana;
    ELSE
        SET @DaniKasnjenjaOutput = 0;

    -- Početak transakcije
    BEGIN TRANSACTION;

    
    -- 1. Ažuriranje pozajmice
    UPDATE Pozajmica
    SET DatumVracanja = @Danas
    WHERE IdPozajmice = @IdPozajmice;

    -- 2. Ažuriranje statusa primerka
    UPDATE Primerak
    SET Status = @NoviStatusPrimerka
    WHERE IdPrimerka = @IdPrimerka;

    COMMIT TRANSACTION;

END;
GO

--Dodaje novu knjgu koju povezuje sa autorom i kreira jedan primerak. Vraca IdKnjige
CREATE PROCEDURE sp_DodajNovuKnjiguSaAutorom
    @Naslov NVARCHAR(200),
    @ISBN NVARCHAR(20),
    @GodinaIzdanja INT,
    @IdKategorije INT,
    @IdAutora INT,
    @InventarskiBrojPrimerka NVARCHAR(50),
    @NovaKnjigaIdOutput INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Provera postojanja autora i kategorije
    IF NOT EXISTS (SELECT 1 FROM Autor WHERE IdAutora = @IdAutora)
    BEGIN
        RAISERROR(N'Autor sa datim ID-jem ne postoji.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Kategorija WHERE IdKategorije = @IdKategorije)
    BEGIN
        RAISERROR(N'Kategorija sa datim ID-jem ne postoji.', 16, 1);
        RETURN;
    END

    -- Početak transakcije
    BEGIN TRANSACTION;

    
    -- 1. Unos knjige
    INSERT INTO Knjiga (Naslov, ISBN, GodinaIzdanja, IdKategorije)
    VALUES (@Naslov, @ISBN, @GodinaIzdanja, @IdKategorije);

    SET @NovaKnjigaIdOutput = SCOPE_IDENTITY();

    -- 2. Povezivanje knjige i autora
    INSERT INTO Knjiga_Autor (IdKnjige, IdAutora)
    VALUES (@NovaKnjigaIdOutput, @IdAutora);

    -- 3. Kreiranje prvog slobodnog primerka
    INSERT INTO Primerak (InventarskiBroj, Status, IdKnjige)
    VALUES (@InventarskiBrojPrimerka, N'Slobodan', @NovaKnjigaIdOutput);

    COMMIT TRANSACTION;
    
END;
GO

-- Okidaci

-- Sprecava pozajmicu zauzete ili ostecene knjige ako korisnik koristi direktno insert umesto da koristi proceduru
CREATE TRIGGER trg_Stop_DuplaPoz
ON Pozajmica
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ukoliko se među unetim redovima nalazi primerak koji nije slobodan
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Primerak p ON i.IdPrimerka = p.IdPrimerka
        WHERE p.Status != 'Slobodan'
    )
    BEGIN
        RAISERROR(N'Transakcija prekinuta: Jedan ili više odabranih primeraka trenutno nisu slobodni za pozajmicu.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- Sprecava unos odeljenja za nastavnika
CREATE TRIGGER trg_Stop_NastavnikOdeljenje
ON Clan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Provera da li je nakon izmene neki nastavnik dobio razred/odeljenje
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE i.IdTipa = 2 AND i.RazredOdeljenje IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Transakcija prekinuta:Nastavnik ne može imati definisano odeljenje (mora biti NULL).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


-- Sprecava brisanje autora ako ima knjiga koju je pisao
CREATE TRIGGER trg_BrisanjeAktivnogAutora
ON Autor
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- proverava da li id autora iz deleted je povezan sa nekom knjigom
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN Knjiga_Autor ka ON d.IdAutora = ka.IdAutora
    )
    BEGIN
        RAISERROR(N'Greška: Nije moguće obrisati autora jer u biblioteci postoje knjige povezane sa njim.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Ako autor nema napisanih knjiga, brisemo
    DELETE FROM Autor
    WHERE IdAutora IN (SELECT IdAutora FROM deleted);
END;
GO


-- TESTIRANJE SVIH FUNKCIONALNOSTI

-- pogledi
SELECT * FROM vw_AktivnePozajmice;
GO

SELECT * FROM vw_KnjigePregled;
GO

-- funkcije
SELECT 
    IdKnjige, 
    Naslov, 
    dbo.fn_BrojSlobodnihPrimeraka(IdKnjige) AS SlobodniPrimerci
FROM Knjiga
WHERE IdKnjige = 1;
GO

SELECT * FROM dbo.fn_PozajmiceClana(1);
GO


SELECT * FROM dbo.fn_ClanoviSaPrekoracenjem(1);
GO

-- procedure
DECLARE @NoviIdPozajmice INT;
EXEC sp_EvidentirajPozajmicu 
    @IdClana = 3, 
    @IdPrimerka = 1, 
    @BrojDanaZaVracanje = 14, 
    @IdPozajmiceOutput = @NoviIdPozajmice OUTPUT;
SELECT @NoviIdPozajmice AS GenerisaniIdPozajmice; -- prikazuje novi id pozajmice
SELECT IdPrimerka, InventarskiBroj, Status FROM Primerak WHERE IdPrimerka = 1; -- prikazuje promenu statusa
GO


DECLARE @DaniKasnjenja INT;
EXEC sp_EvidentirajVracanje 
    @IdPrimerka = 1, -- primerak koji je u proslom primeru bio pozajmljen
    @NoviStatusPrimerka = N'Slobodan', 
    @DaniKasnjenjaOutput = @DaniKasnjenja OUTPUT;
SELECT @DaniKasnjenja AS BrojDanaKasnjenja;
SELECT IdPrimerka, InventarskiBroj, Status FROM Primerak WHERE IdPrimerka = 1; -- prikazuje promenu statusa
GO


DECLARE @NoviIdKnjige INT;
-- Unos knjige za kategoriju 2 (Beletristika) i autora 1 (Ivo Andrić)
EXEC sp_DodajNovuKnjiguSaAutorom
    @Naslov = N'Znakovi pored puta',
    @ISBN = N'9788617151222',
    @GodinaIzdanja = 1976,
    @IdKategorije = 2,
    @IdAutora = 1,
    @InventarskiBrojPrimerka = N'INV-9999',
    @NovaKnjigaIdOutput = @NoviIdKnjige OUTPUT;
SELECT @NoviIdKnjige AS IDNoveKnjige; 
SELECT * FROM Knjiga WHERE IdKnjige = @NoviIdKnjige; -- prikazuje novu knjigu
SELECT * FROM Primerak WHERE IdKnjige = @NoviIdKnjige; -- prikazuje novi primerak za tu knjigu
GO


-- Okidaci

-- pokusavamo da pozajmimo ostecenu knjigu(ID: 3)
BEGIN TRY
    INSERT INTO Pozajmica (DatumPozajmljivanja, RokZaVracanje, DatumVracanja, IdClana, IdPrimerka)
    VALUES (GETDATE(), DATEADD(day, 14, GETDATE()), NULL, 1, 3);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS PorukaGreskeOkidaca;
END CATCH;
GO

-- Pokusavamo da dodelimo odeljenje nastavniku(ID:16 je nastavnik)
BEGIN TRY
    UPDATE Clan
    SET RazredOdeljenje = N'VIII-1'
    WHERE IdClana = 16;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS PorukaGreskeOkidaca;
END CATCH;
GO

-- Pokusavamo da obrisemo autora sa knjigama
BEGIN TRY
    DELETE FROM Autor WHERE IdAutora = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS PorukaGreskeOkidaca;
END CATCH;
GO