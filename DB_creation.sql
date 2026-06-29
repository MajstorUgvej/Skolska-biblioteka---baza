---- 1. Kreiranje baze podataka
CREATE DATABASE Skolska_biblioteka;
GO

USE Skolska_biblioteka;
GO

-- 2. Kreiranje tabele TipClana
CREATE TABLE TipClana (
    IdTipa INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NazivTipa NVARCHAR(50) NOT NULL UNIQUE
);

-- 3. Kreiranje tabele Clan
CREATE TABLE Clan (
    IdClana INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ime NVARCHAR(50) NOT NULL,
    Prezime NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NULL,
    Telefon NVARCHAR(20) NULL,
    RazredOdeljenje NVARCHAR(10) NULL, -- Npr. 'IV-3', za nastavnike ostaje NULL
    IdTipa INT NOT NULL,
    FOREIGN KEY (IdTipa) REFERENCES TipClana(IdTipa)
);

-- 4. Kreiranje tabele Kategorija
CREATE TABLE Kategorija (
    IdKategorije INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    NazivKategorije NVARCHAR(100) NOT NULL UNIQUE
);

-- 5. Kreiranje tabele Autor
CREATE TABLE Autor (
    IdAutora INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ime NVARCHAR(50) NOT NULL,
    Prezime NVARCHAR(50) NOT NULL
);

-- 6. Kreiranje tabele Knjiga
CREATE TABLE Knjiga (
    IdKnjige INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Naslov NVARCHAR(200) NOT NULL,
    ISBN NVARCHAR(20) NOT NULL UNIQUE,
    GodinaIzdanja INT NULL,
    IdKategorije INT NOT NULL,
    FOREIGN KEY (IdKategorije) REFERENCES Kategorija(IdKategorije)
);

-- 7. Kreiranje vezne tabele Knjiga_Autor (M:M)
CREATE TABLE Knjiga_Autor (
    IdKnjige INT NOT NULL,
    IdAutora INT NOT NULL,
    PRIMARY KEY (IdKnjige, IdAutora),
    FOREIGN KEY (IdKnjige) REFERENCES Knjiga(IdKnjige),
    FOREIGN KEY (IdAutora) REFERENCES Autor(IdAutora)
);

-- 8. Kreiranje tabele Primerak
CREATE TABLE Primerak (
    IdPrimerka INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InventarskiBroj NVARCHAR(50) NOT NULL UNIQUE,
    Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Primerak_Status DEFAULT 'Slobodan',
    IdKnjige INT NOT NULL,
    CONSTRAINT CHK_Status CHECK (Status IN ('Slobodan', 'Pozajmljen', 'Oštećen')),
    FOREIGN KEY (IdKnjige) REFERENCES Knjiga(IdKnjige)
);

-- 9. Kreiranje tabele Pozajmica
CREATE TABLE Pozajmica (
    IdPozajmice INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DatumPozajmljivanja DATE NOT NULL,
    RokZaVracanje DATE NOT NULL,
    DatumVracanja DATE NULL,
    IdClana INT NOT NULL FOREIGN KEY (IdClana) REFERENCES Clan(IdClana),
    IdPrimerka INT NOT NULL,
    FOREIGN KEY (IdPrimerka) REFERENCES Primerak(IdPrimerka),
    -- Datum vracanja (ako postoji) i rok moraju biti veci ili jednaki datumu pozajmljivanja
    CONSTRAINT CHK_Pozajmica_Datumi CHECK (RokZaVracanje >= DatumPozajmljivanja AND (DatumVracanja IS NULL OR DatumVracanja >= DatumPozajmljivanja))
);
GO