SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- Kreiranje unique non-clustered indeksa
CREATE UNIQUE NONCLUSTERED INDEX UX_Clan_Email
ON Clan (Email)
WHERE Email IS NOT NULL;
GO

-- Ovaj insert će pasti jer narušava jedinstvenost indeksa UX_Clan_Email
INSERT INTO Clan (Ime, Prezime, Email, Telefon, RazredOdeljenje, IdTipa)
VALUES (N'Petar', N'Petrović', N'marko.m@skola.edu.rs', N'069999999', N'V-1', 1);
GO

-- Kreiranje standardnog non-clustered indeksa nad prezimenom
CREATE NONCLUSTERED INDEX IX_Clan_Prezime
ON Clan (Prezime);
GO

-- Index sa INCLUDE klauzulom
-- Sadrzi trazenu kolonu u kljucu, a ostale potrebne kolone u listu indeksa,
-- izbegava se "Key Lookup".
CREATE NONCLUSTERED INDEX IX_Clan_RazredOdeljenje_Pokrivajuci
ON Clan (RazredOdeljenje)
INCLUDE (Ime, Prezime);
GO

-- Filtrirani indeks
-- Indeksira samo aktivne pozajmice (gde knjiga jos nije vraćena). 
CREATE NONCLUSTERED INDEX IX_Pozajmica_Aktivne
ON Pozajmica (IdPrimerka, IdClana)
WHERE DatumVracanja IS NULL;
GO

SELECT IdClana, Ime, Prezime, Email
FROM Clan
WHERE Prezime = N'Petrović';

SELECT Ime, Prezime 
FROM Clan 
WHERE RazredOdeljenje = N'VIII-3';


SELECT IdPrimerka, IdClana 
FROM Pozajmica 
WHERE DatumVracanja IS NULL;