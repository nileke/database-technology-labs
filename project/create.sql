--DROP TABLE IF EXISTS Ranks CASCADE;
--DROP TABLE IF EXISTS Athletes CASCADE;
--DROP TABLE IF EXISTS Teams CASCADE;
--DROP TABLE IF EXISTS Nationalities CASCADE;
--DROP TABLE IF EXISTS Officials CASCADE; 
--DROP TABLE IF EXISTS Competitions CASCADE;
--DROP TABLE IF EXISTS Venues CASCADE;
--DROP TABLE IF EXISTS TeamComp CASCADE;

CREATE EXTENSION btree_gist;

CREATE TABLE Nationalities (
	countryId INT PRIMARY KEY,
	country VARCHAR(20) NOT NULL);

CREATE TABLE Venues (
	venueId INT PRIMARY KEY,
	venueName VARCHAR(50) NOT NULL, 
	address VARCHAR(50) NOT NULL, 
	zipcode CHAR(5) NOT NULL, 
	city VARCHAR(20) NOT NULL);

CREATE TABLE Officials (
	officialId INT PRIMARY KEY,
	fname VARCHAR(20) NOT NULL,
	lname VARCHAR(20) NOT NULL);

CREATE TABLE Competitions (
	compId INT PRIMARY KEY,
	compName VARCHAR(255) NOT NULL,
	genderClass VARCHAR(10) NOT NULL,
	round VARCHAR(20) NOT NULL,
	officialId INT,
	location INT,
	start_time TIMESTAMP NOT NULL,
	end_time TIMESTAMP NOT NULL,
	FOREIGN KEY (officialId) REFERENCES Officials(officialId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (location) REFERENCES Venues(venueId) ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT event_time_and_place EXCLUDE USING gist (location WITH =, tsrange(start_time, end_time, '[]') WITH &&));


CREATE TABLE Teams (
	teamId INT PRIMARY KEY,
	compId INT,
	countryId INT,
	sport VARCHAR(20) NOT NULL,
	FOREIGN KEY (countryId) REFERENCES Nationalities(countryId)ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (compId) REFERENCES Competitions(compId) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE TeamComp (
	compId INT REFERENCES Competitions(compId) ON UPDATE CASCADE ON DELETE CASCADE,
	teamId INT REFERENCES Teams(teamId) ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE Ranks (
	teamId INT,
	rank INT,
	FOREIGN KEY (teamId) REFERENCES Teams(TeamId));

CREATE TABLE Athletes (
	athleteId INT PRIMARY KEY,
	teamId INT ,
	fname VARCHAR(20) NOT NULL,
	lname VARCHAR(20) NOT NULL,
	gender VARCHAR(10) NOT NULL,
	role VARCHAR(20),
	FOREIGN KEY (teamId) REFERENCES Teams(teamId) ON UPDATE CASCADE ON DELETE CASCADE);


/* Populating for queries */

INSERT INTO Nationalities (countryId, country) VALUES
	(1,'Sweden'),
	(2, 'Denmark'),
	(3, 'Russia'),
	(4, 'Spain');


INSERT INTO Officials (officialId, fname, lname) VALUES
	(1,'Nils','Oskarsson'),
	(2,'Tore', 'Knutsson'),
	(3,'Domarjavul','Fanson'),
	(4, 'Anti', 'Laninen'),
	(5, 'Vladimir', 'Putin'),
	(6, 'Jamie', 'Abbat');


INSERT INTO Venues (venueID, venueName, address, zipcode, city) VALUES 
	(1, 'Globen', 'Globengatan 1', '12330', 'Stockholm'),
	(2, 'Hovet', 'Hovetgatan 2', '12331', 'Stockholm'),
	(3 , 'Hammarbybacken', 'Hammarbygatan 1', '15550', 'Stockholm'),
	(4, 'VM8an','Åregatan 4', '41414', 'Åre'),
	(5, 'Friends Arena', 'Arenavägen', '12332', 'Sundbyberg');


INSERT INTO Teams (teamId, countryId, sport) VALUES 
	(1,1,'Hockey'),	
	(2,1,'Hockey'),
	(3,2,'Hockey'),
	(4,2,'Speedskating'),
	(5,3,'Hockey'),
	(6,4,'Figuere Skating'),
	(7,1,'Ski Big Air'),
	(8,1,'Bobsleigh'),
	(9,2, 'Slalom'),
	(10,3, 'Slalom');


INSERT INTO Ranks (teamId, rank) VALUES
	(1,1),
	(2,3),
	(3,2),
	(4,4),
	(5,5);


INSERT INTO Competitions (compId, compName, round, genderClass, location, start_time, end_time) VALUES
	(1, 'Skiing Big Air','Ski Big Air', 'Men', 3, '2022-01-22 14:00:00', '2022-01-22 16:00:00'),
	(2, 'Hockey','Group 1', 'Men', 5, '2022-01-16 13:00:00', '2022-01-16 15:00:00'),
	(3, 'Hockey','Group 2', 'Men', 2, '2022-01-20 10:00:00', '2022-01-20 12:00:00'),
	(4, 'Bobsleigh', 'Final', 'Women', 1, '2022-02-02 11:00:00', '2022-02-02 13:00:00'),
	(5, 'Speedskating','Group stage', 'Women', 2, '2022-01-14 14:00:00', '2022-01-14 15:00:00'),
	(6, 'Slalom Alpine Ski Race', 'Group stage', 'Women', 4, '2022-02-10 13:00:00', '2022-02-10 15:00:00');


INSERT INTO TeamComp (teamId, compId) VALUES 
	(1,2),
	(2,2),
	(3,3),
	(5,3),
	(8,4),
	(7,1),
	(4,5),
	(9,6),
	(10,6);


INSERT INTO Athletes (athleteId, teamId, fname, lname, role, gender) VALUES
	(1,1,'Filip','Stal','Center','Male'),
	(2,1,'Evelina','Hedberg', 'Goalie', 'Female'),
	(3,7,'Kungen','Kungsson', 'Skier', 'Male'),
	(4,2, 'Tord', 'Mikkelsen', 'Goalkeeper', 'Male'),
	(5,2, 'Alexander', 'Nordh', 'Waterboi', 'Male'),
	(6,2, 'Nils', 'Ekenback', 'Bnchwarmer', 'Male'),
	(7,3, 'Joel', 'Weidenmark', 'Forward', 'Male'),
	(8,3, 'Olga', 'Sputnik', 'Center', 'Female'),
	(9,4,'Aino', 'Bastuviva', 'Defender', 'Female'),
	(10,4, 'Sara', 'Luustivaae', 'Defender', 'Female'),
	(11,5, 'Pekka', 'Pouianen', 'Forward', 'Male'),
	(12,6,'Olle','Pasta','FigureSkater','Male'),
	(13,6, 'Ylva', 'Jamon', 'FigureStater', 'Female'),
	(14,7, 'Rick', 'Sanchez', 'Skier', 'Male'),
	(15,5,'Vladimir', 'Putin', 'Goalkeeper', 'Male');