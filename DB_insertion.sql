USE Skolska_biblioteka;
GO

-- =========================================================================
-- 1. UNOS TIPA ČLANA
-- =========================================================================
SET IDENTITY_INSERT TipClana ON;
INSERT INTO TipClana (IdTipa, NazivTipa) VALUES
(1, N'Učenik'),
(2, N'Nastavnik');
SET IDENTITY_INSERT TipClana OFF;
GO

-- =========================================================================
-- 2. UNOS ČLANOVA (Učenici imaju odeljenja, Nastavnicima je to NULL)
-- =========================================================================
SET IDENTITY_INSERT Clan ON;
INSERT INTO Clan (IdClana, Ime, Prezime, Email, Telefon, RazredOdeljenje, IdTipa) VALUES
-- Učenici (IdTipa = 1)
(1, N'Marko', N'Marković', N'marko.m@skola.edu.rs', N'064111222', N'V-1', 1),
(2, N'Milica', N'Jovanović', N'milica.j@skola.edu.rs', N'065222333', N'VIII-3', 1),
(3, N'Nikola', N'Nikolić', N'nikola.n@skola.edu.rs', NULL, N'VI-2', 1),
(4, N'Jelena', N'Petrović', N'jelena.p@skola.edu.rs', N'063444555', N'VII-1', 1),
(5, N'Dušan', N'Tadić', NULL, NULL, N'V-2', 1),
(6, N'Sofija', N'Lukić', N'sofija.l@skola.edu.rs', N'061777888', N'IV-3', 1),
(7, N'Luka', N'Stanković', N'luka.s@skola.edu.rs', NULL, N'VIII-1', 1),
(8, N'Ana', N'Kovačević', N'ana.k@skola.edu.rs', N'066999000', N'VI-3', 1),
(9, N'Stefan', N'Đorđević', NULL, NULL, N'V-1', 1),
(10, N'Dunja', N'Ilić', N'dunja.i@skola.edu.rs', N'062333444', N'III-2', 1),
(11, N'Filip', N'Pavlović', NULL, NULL, N'VII-2', 1),
(12, N'Teodora', N'Popović', N'teodora.p@skola.edu.rs', N'064555666', N'VIII-2', 1),
(13, N'Vuk', N'Mladenović', NULL, NULL, N'II-1', 1),
(14, N'Marta', N'Vasiljević', N'marta.v@skola.edu.rs', N'060123456', N'VI-1', 1),
(15, N'Aleksa', N'Ristić', NULL, NULL, N'VIII-3', 1),

-- Nastavnici (IdTipa = 2)
(16, N'Dragan', N'Petrović', N'dragan.petrovic@skola.edu.rs', N'064987654', NULL, 2),
(17, N'Marija', N'Sarić', N'marija.saric@skola.edu.rs', N'065876543', NULL, 2),
(18, N'Zoran', N'Kostić', N'zoran.kostic@skola.edu.rs', NULL, NULL, 2),
(19, N'Snežana', N'Dimić', N'snezana.dimic@skola.edu.rs', N'063765432', NULL, 2),
(20, N'Goran', N'Milić', N'goran.milic@skola.edu.rs', NULL, NULL, 2),
(21, N'Olivera', N'Arsić', N'olivera.arsic@skola.edu.rs', N'061234789', NULL, 2);
SET IDENTITY_INSERT Clan OFF;
GO

-- =========================================================================
-- 3. UNOS KATEGORIJA KNJIGA
-- =========================================================================
SET IDENTITY_INSERT Kategorija ON;
INSERT INTO Kategorija (IdKategorije, NazivKategorije) VALUES
(1, N'Školska lektira'),
(2, N'Beletristika'),
(3, N'Naučna fantastika i Epska fantastika'),
(4, N'Istorijski romani'),
(5, N'Poezija'),
(6, N'Stručna literatura i Udžbenici'),
(7, N'Enciklopedije i priručnici'),
(8, N'Dečija književnost');
SET IDENTITY_INSERT Kategorija OFF;
GO

-- =========================================================================
-- 4. UNOS AUTORA
-- =========================================================================
SET IDENTITY_INSERT Autor ON;
INSERT INTO Autor (IdAutora, Ime, Prezime) VALUES
(1, N'Ivo', N'Andrić'),
(2, N'Branko', N'Ćopić'),
(3, N'Desanka', N'Maksimović'),
(4, N'J.K.', N'Rowling'),
(5, N'J.R.R.', N'Tolkien'),
(6, N'Meša', N'Selimović'),
(7, N'Miloš', N'Crnjanski'),
(8, N'Danilo', N'Kiš'),
(9, N'Antoine', N'de Saint-Exupéry'),
(10, N'George', N'Orwell'),
(11, N'Fjodor', N'Dostojevski'),
(12, N'William', N'Shakespeare'),
(13, N'Jovan', N'Dučić'),
(14, N'Borislav', N'Pekić'),
(15, N'Dositej', N'Obradović');
SET IDENTITY_INSERT Autor OFF;
GO

-- =========================================================================
-- 5. UNOS KNJIGA
-- =========================================================================
SET IDENTITY_INSERT Knjiga ON;
INSERT INTO Knjiga (IdKnjige, Naslov, ISBN, GodinaIzdanja, IdKategorije) VALUES
-- Školska lektira (IdKategorije = 1)
(1, N'Na Drini ćuprija', N'9788617151012', 1945, 1),
(2, N'Seobe', N'9788617151029', 1929, 1),
(3, N'Prokleta avlija', N'9788617151036', 1954, 1),
(4, N'Derviš i smrt', N'9788617151043', 1966, 1),
(5, N'Orlovi rano lete', N'9788617151050', 1957, 1),
(6, N'Mali princ', N'9788617151067', 1943, 1),
(7, N'Romeo i Julija', N'9788617151074', 1597, 1),

-- Beletristika & Sci-Fi & Dečije (Kategorije: 2, 3, 8)
(8, N'Hari Poter i Kamen mudrosti', N'9788677022011', 1997, 8),
(9, N'Hari Poter i Dvorana tajni', N'9788677022028', 1998, 8),
(10, N'Hobit', N'9788677022035', 1937, 3),
(11, N'Gospodar prstenova: Družina prstena', N'9788677022042', 1954, 3),
(12, N'1984', N'9788677022059', 1949, 3),
(13, N'Zločin i kazna', N'9788677022066', 1866, 2),
(14, N'Grobnica za Borisa Davidoviča', N'9788677022073', 1976, 2),

-- Istorijski, Poezija, Stručna, Enciklopedije (Kategorije: 4, 5, 6, 7)
(15, N'Pismo Haralampiju / Život i priključenija', N'9788677022080', 1783, 4),
(16, N'Zlatno runo I', N'9788677022097', 1977, 4),
(17, N'Tražim pomilovanje', N'9788677022103', 1964, 5),
(18, N'Gradovi i himere', N'9788677022110', 1940, 5),
(19, N'Opšta istorija sveta', N'9788677022127', 2018, 7),
(20, N'Gramatika srpskog jezika za osnovnu školu', N'9788617151104', 2020, 6),
(21, N'Zabavna fizika za radoznale', N'9788617151111', 2015, 6),
(22, N'Velika enciklopedija životinja', N'9788617151128', 2019, 7);
SET IDENTITY_INSERT Knjiga OFF;
GO

-- =========================================================================
-- 6. POVEZIVANJE KNJIGA I AUTORA (Knjiga_Autor)
-- =========================================================================
INSERT INTO Knjiga_Autor (IdKnjige, IdAutora) VALUES
(1, 1),   -- Na Drini ćuprija - Ivo Andrić
(2, 7),   -- Seobe - Miloš Crnjanski
(3, 1),   -- Prokleta avlija - Ivo Andrić
(4, 6),   -- Derviš i smrt - Meša Selimović
(5, 2),   -- Orlovi rano lete - Branko Ćopić
(6, 9),   -- Mali princ - Antoine de Saint-Exupéry
(7, 12),  -- Romeo i Julija - William Shakespeare
(8, 4),   -- Hari Poter 1 - J.K. Rowling
(9, 4),   -- Hari Poter 2 - J.K. Rowling
(10, 5),  -- Hobit - J.R.R. Tolkien
(11, 5),  -- Gospodar prstenova - J.R.R. Tolkien
(12, 10), -- 1984 - George Orwell
(13, 11), -- Zločin i kazna - Fjodor Dostojevski
(14, 8),  -- Grobnica za Borisa Davidoviča - Danilo Kiš
(15, 15), -- Pismo Haralampiju - Dositej Obradović
(16, 14), -- Zlatno runo I - Borislav Pekić
(17, 3),  -- Tražim pomilovanje - Desanka Maksimović
(18, 13), -- Gradovi i himere - Jovan Dučić
(19, 15), -- Opšta istorija sveta - Dositej Obradović (Učešće u adaptaciji/prevodu)
(20, 15), -- Gramatika srpskog jezika - Dositej Obradović (Simbolično)
(21, 13), -- Zabavna fizika za radoznale - Jovan Dučić (Simbolično)
(22, 15); -- Velika enciklopedija životinja - Dositej Obradović (Simbolično)
GO

-- =========================================================================
-- 7. UNOS PRIMERAKA KNJIGA (Neke knjige imaju više primeraka)
-- =========================================================================
SET IDENTITY_INSERT Primerak ON;
INSERT INTO Primerak (IdPrimerka, InventarskiBroj, Status, IdKnjige) VALUES
-- Na Drini ćuprija (IdKnjige = 1) - 3 primerka (jedan trenutno pozajmljen, jedan oštećen)
(1, N'INV-0001', N'Slobodan', 1),
(2, N'INV-0002', N'Pozajmljen', 1),
(3, N'INV-0003', N'Oštećen', 1),

-- Seobe (IdKnjige = 2) - 2 primerka
(4, N'INV-0004', N'Slobodan', 2),
(5, N'INV-0005', N'Pozajmljen', 2),

-- Prokleta avlija (IdKnjige = 3) - 2 primerka
(6, N'INV-0006', N'Slobodan', 3),
(7, N'INV-0007', N'Slobodan', 3),

-- Derviš i smrt (IdKnjige = 4) - 2 primerka
(8, N'INV-0008', N'Slobodan', 4),
(9, N'INV-0009', N'Pozajmljen', 4),

-- Orlovi rano lete (IdKnjige = 5) - 4 primerka (dva pozajmljena zbog velike potražnje)
(10, N'INV-0010', N'Slobodan', 5),
(11, N'INV-0011', N'Pozajmljen', 5),
(12, N'INV-0012', N'Slobodan', 5),
(13, N'INV-0013', N'Pozajmljen', 5),

-- Mali princ (IdKnjige = 6) - 3 primerka
(14, N'INV-0014', N'Slobodan', 6),
(15, N'INV-0015', N'Pozajmljen', 6),
(16, N'INV-0016', N'Slobodan', 6),

-- Romeo i Julija (IdKnjige = 7) - 2 primerka
(17, N'INV-0017', N'Slobodan', 7),
(18, N'INV-0018', N'Pozajmljen', 7),

-- Hari Poter i Kamen mudrosti (IdKnjige = 8) - 3 primerka
(19, N'INV-0019', N'Pozajmljen', 8),
(20, N'INV-0020', N'Slobodan', 8),
(21, N'INV-0021', N'Oštećen', 8),

-- Hari Poter i Dvorana tajni (IdKnjige = 9) - 2 primerka
(22, N'INV-0022', N'Slobodan', 9),
(23, N'INV-0023', N'Pozajmljen', 9),

-- Hobit (IdKnjige = 10) - 2 primerka
(24, N'INV-0024', N'Slobodan', 10),
(25, N'INV-0025', N'Pozajmljen', 10),

-- Gospodar prstenova (IdKnjige = 11) - 2 primerka
(26, N'INV-0026', N'Slobodan', 11),
(27, N'INV-0027', N'Pozajmljen', 11),

-- 1984 (IdKnjige = 12) - 2 primerka
(28, N'INV-0028', N'Slobodan', 12),
(29, N'INV-0029', N'Slobodan', 12),

-- Zločin i kazna (IdKnjige = 13) - 2 primerka
(30, N'INV-0030', N'Pozajmljen', 13),
(31, N'INV-0031', N'Slobodan', 13),

-- Grobnica za BD (IdKnjige = 14) - 1 primerak
(32, N'INV-0032', N'Slobodan', 14),

-- Pismo Haralampiju (IdKnjige = 15) - 1 primerak
(33, N'INV-0033', N'Slobodan', 15),

-- Zlatno runo I (IdKnjige = 16) - 1 primerak
(34, N'INV-0034', N'Slobodan', 16),

-- Tražim pomilovanje (IdKnjige = 17) - 2 primerka
(35, N'INV-0035', N'Pozajmljen', 17),
(36, N'INV-0036', N'Slobodan', 17),

-- Gradovi i himere (IdKnjige = 18) - 1 primerak
(37, N'INV-0037', N'Slobodan', 18),

-- Opšta istorija sveta (IdKnjige = 19) - 1 primerak
(38, N'INV-0038', N'Slobodan', 19),

-- Gramatika (IdKnjige = 20) - 3 primerka
(39, N'INV-0039', N'Slobodan', 20),
(40, N'INV-0040', N'Slobodan', 20),
(41, N'INV-0041', N'Slobodan', 20),

-- Zabavna fizika (IdKnjige = 21) - 2 primerka
(42, N'INV-0042', N'Slobodan', 21),
(43, N'INV-0043', N'Pozajmljen', 21),

-- Velika enciklopedija životinja (IdKnjige = 22) - 1 primerak
(44, N'INV-0044', N'Slobodan', 22);
SET IDENTITY_INSERT Primerak OFF;
GO

-- =========================================================================
-- 8. UNOS POZAJMICA (Istorijske pozajmice i aktivne pozajmice)
-- =========================================================================
SET IDENTITY_INSERT Pozajmica ON;
INSERT INTO Pozajmica (IdPozajmice, DatumPozajmljivanja, RokZaVracanje, DatumVracanja, IdClana, IdPrimerka) VALUES
-- --- ISTORIJSKE POZAJMICE (Knjige koje su uspešno vraćene) ---
(1, '2025-09-10', '2025-09-24', '2025-09-22', 1, 1),   -- Marko uzeo "Na Drini ćuprija" (primerak 1) i vratio na vreme
(2, '2025-10-05', '2025-10-19', '2025-10-18', 2, 1),   -- Milica uzela isti primerak, vratila na vreme
(3, '2025-11-01', '2025-11-15', '2025-11-14', 16, 4),  -- Nastavnik Dragan uzeo "Seobe", vratio na vreme
(4, '2025-12-10', '2025-12-24', '2025-12-23', 3, 6),   -- Nikola vratio "Prokletu avliju" dan ranije
(5, '2026-01-15', '2026-01-29', '2026-01-29', 10, 10), -- Dunja vratila "Orlove" tačno na dan roka
(6, '2026-02-01', '2026-02-15', '2026-02-14', 5, 14),  -- Dušan vratio "Malog princa"
(7, '2026-02-10', '2026-02-24', '2026-02-28', 13, 20), -- Vuk kasnio 4 dana sa vraćanjem Hari Potera
(8, '2026-03-05', '2026-03-19', '2026-03-18', 14, 22), -- Marta vratila Hari Potera 2 na vreme
(9, '2026-03-20', '2026-04-03', '2026-04-01', 15, 24), -- Aleksa vratio Hobita na vreme
(10, '2026-04-10', '2026-04-24', '2026-04-22', 20, 26),-- Nastavnik Goran vratio Gospodara prstenova
(11, '2026-04-15', '2026-04-29', '2026-04-28', 21, 28),-- Nastavnica Olivera vratila 1984
(12, '2026-05-01', '2026-05-15', '2026-05-15', 8, 31),  -- Ana vratila Zločin i kaznu
(13, '2026-05-10', '2026-05-24', '2026-05-22', 9, 32),  -- Stefan vratio Grobnicu za BD
(14, '2026-05-12', '2026-05-26', '2026-05-25', 11, 36), -- Filip vratio Tražim pomilovanje
(15, '2026-05-20', '2026-06-03', '2026-06-01', 17, 39), -- Nastavnica Marija vratila Gramatiku

-- --- TRENUTNO AKTIVNE POZAJMICE (Usklađeno sa statusom 'Pozajmljen' u tabeli Primerak) ---
-- (Napomena: Trenutni datum u simulaciji je jun 2026. godine)

-- Prekoračen rok (Overdue):
(16, '2026-06-01', '2026-06-15', NULL, 6, 18),  -- Sofija (učenik) još uvek drži primerak 18 (Romeo i Julija). Rok je bio 15. jun.
(17, '2026-06-10', '2026-06-24', NULL, 1, 2),   -- Marko (učenik) drži primerak 2 (Na Drini ćuprija). Rok bio 24. jun.

-- U roku (Active & within due date):
(18, '2026-06-15', '2026-07-15', NULL, 16, 5),  -- Nastavnik Dragan drži primerak 5 (Seobe). Nastavnici obično imaju duži rok.
(19, '2026-06-20', '2026-07-04', NULL, 2, 9),   -- Milica drži primerak 9 (Derviš i smrt).
(20, '2026-06-18', '2026-07-18', NULL, 17, 11), -- Nastavnica Marija drži primerak 11 (Orlovi rano lete).
(21, '2026-06-22', '2026-07-06', NULL, 3, 13),  -- Nikola drži primerak 13 (Orlovi rano lete).
(22, '2026-06-12', '2026-06-26', NULL, 4, 15),  -- Jelena drži primerak 15 (Mali princ). Rok ističe danas (26. jun).
(23, '2026-06-25', '2026-07-09', NULL, 7, 19),  -- Luka drži primerak 19 (Hari Poter 1).
(24, '2026-06-24', '2026-07-08', NULL, 8, 23),  -- Ana drži primerak 23 (Hari Poter 2).
(25, '2026-06-19', '2026-07-03', NULL, 10, 25), -- Dunja drži primerak 25 (Hobit).
(26, '2026-06-14', '2026-07-14', NULL, 18, 27), -- Nastavnik Zoran drži primerak 27 (Gospodar prstenova).
(27, '2026-06-05', '2026-07-05', NULL, 19, 30), -- Nastavnica Snežana drži primerak 30 (Zločin i kazna).
(28, '2026-06-21', '2026-07-05', NULL, 12, 35), -- Teodora drži primerak 35 (Tražim pomilovanje).
(29, '2026-06-23', '2026-07-07', NULL, 14, 43); -- Marta drži primerak 43 (Zabavna fizika).
SET IDENTITY_INSERT Pozajmica OFF;
GO