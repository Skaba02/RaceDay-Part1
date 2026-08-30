-- This script was written and tested against SQL Server 2022 in SSMS 20.
/* ============================================================
   RaceDay System - Database Creation Script
   Run in SQL Server Management Studio (SSMS) on a clean instance.
   Creates the schema shown in ERD.png and seeds it with sample data.
   ============================================================ */

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* ------------------------------------------------------------
   Drop tables if they already exist (in reverse dependency order)
   so this script can be re-run cleanly.
   ------------------------------------------------------------ */
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

/* ------------------------------------------------------------
   1. Roles
   ------------------------------------------------------------ */
CREATE TABLE dbo.Roles (
    RoleId      INT             IDENTITY(1,1) PRIMARY KEY,
    RoleName    VARCHAR(50)     NOT NULL UNIQUE
);
GO

/* ------------------------------------------------------------
   2. Users
   ------------------------------------------------------------ */
CREATE TABLE dbo.Users (
    UserId          INT             IDENTITY(1,1) PRIMARY KEY,
    RoleId          INT             NOT NULL,
    FullName        VARCHAR(100)    NOT NULL,
    Email           VARCHAR(150)    NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255)    NOT NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);
GO

/* ------------------------------------------------------------
   3. Events (created by an Organiser)
   ------------------------------------------------------------ */
   -- Each Event is created by one Organiser and have multiple Categories (e.g. 5km, 10km).
CREATE TABLE dbo.Events (
    EventId         INT             IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT             NOT NULL,
    Title           VARCHAR(150)    NOT NULL,
    Description     VARCHAR(500)    NULL,
    EventDate       DATE            NOT NULL,
    Location        VARCHAR(150)    NOT NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) REFERENCES dbo.Users(UserId)
);
GO

/* ------------------------------------------------------------
   4. Categories (each Event has one or more Categories, e.g. 5km, 10km)
   ------------------------------------------------------------ */
CREATE TABLE dbo.Categories (
    CategoryId      INT             IDENTITY(1,1) PRIMARY KEY,
    EventId         INT             NOT NULL,
    CategoryName    VARCHAR(100)    NOT NULL,
    DistanceKm      DECIMAL(5,2)    NOT NULL,
    MaxParticipants INT             NOT NULL DEFAULT 100,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES dbo.Events(EventId)
);
GO

/* ------------------------------------------------------------
   5. Enrolments (junction table: Participant enrols in a Category)
   ------------------------------------------------------------ */
   -- Enrolments links a Participant to a category. The unique constraint below stops someone enrolling in the same category twice.
CREATE TABLE dbo.Enrolments (
    EnrolmentId     INT             IDENTITY(1,1) PRIMARY KEY,
    ParticipantId   INT             NOT NULL,
    CategoryId      INT             NOT NULL,
    EnrolmentDate   DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          VARCHAR(20)     NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT UQ_Enrolment UNIQUE (ParticipantId, CategoryId)
);
GO

/* ------------------------------------------------------------
   6. Results (one Result per Enrolment)
   ------------------------------------------------------------ */
CREATE TABLE dbo.Results (
    ResultId        INT             IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT             NOT NULL UNIQUE,
    FinishTime      TIME            NULL,
    Position        INT             NULL,
    RecordedAt      DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES dbo.Enrolments(EnrolmentId)
);
GO

/* ============================================================
   SEED DATA
   ============================================================ */
   -- Sample data below: 2 Organisers, 2 Participants, 3 Events with categories, and a few enrolments/results for testing.

-- Roles
INSERT INTO dbo.Roles (RoleName) VALUES ('Organiser'), ('Participant');
GO

-- Users: 2 Organisers, 2 Participants
INSERT INTO dbo.Users (RoleId, FullName, Email, PasswordHash)
VALUES
    (1, 'Naledi Khumalo', 'naledi.khumalo@raceday.com', 'HASHED_PASSWORD_1'),
    (1, 'Thabo Mokoena',  'thabo.mokoena@raceday.com',  'HASHED_PASSWORD_2'),
    (2, 'Emily Carter',   'emily.carter@raceday.com',   'HASHED_PASSWORD_3'),
    (2, 'James Novak',    'james.novak@raceday.com',    'HASHED_PASSWORD_4');
GO

-- Events: 3 events, each created by an Organiser
INSERT INTO dbo.Events (OrganiserId, Title, Description, EventDate, Location)
VALUES
    (1, 'City Fun Run',        'An open road race through the city centre.', '2026-10-10', 'Johannesburg CBD'),
    (1, 'Riverside Marathon',  'A scenic marathon along the riverside route.', '2026-11-15', 'Riverside Park'),
    (2, 'Trail Blazer Series', 'An off-road trail running event for all levels.', '2026-12-05', 'Magaliesberg Trails');
GO

-- Categories: at least one per event
INSERT INTO dbo.Categories (EventId, CategoryName, DistanceKm, MaxParticipants)
VALUES
    (1, '5km Fun Run',     5.00,  200),
    (1, '10km Challenge',  10.00, 150),
    (2, 'Half Marathon',   21.10, 300),
    (2, 'Full Marathon',   42.20, 200),
    (3, '15km Trail Run',  15.00, 100);
GO

-- Enrolments: sample participants enrolling in categories
INSERT INTO dbo.Enrolments (ParticipantId, CategoryId, Status)
VALUES
    (3, 1, 'Confirmed'),
    (3, 3, 'Confirmed'),
    (4, 2, 'Confirmed'),
    (4, 5, 'Confirmed');
GO

-- Results: sample results for two enrolments
INSERT INTO dbo.Results (EnrolmentId, FinishTime, Position)
VALUES
    (1, '00:28:45', 12),
    (3, '01:05:30', 8);
GO

PRINT 'RaceDay database created and seeded successfully.';
GO
