--1.  What countries are competing and how many medals have they won?
SELECT 
    country, 
    SUM(count) AS medals
FROM Nationalities
JOIN Teams ON Teams.countryID = Nationalities.countryId
JOIN (SELECT teamId, count(rank <= 3) AS count FROM Ranks GROUP BY teamId) AS Count_medals ON teams.teamId = Count_medals.teamId
GROUP BY country;

--2. What is going on at Friends Arena on Sunday?
SELECT compName, round, start_time, end_time
FROM Competitions
JOIN Venues ON Competitions.location = Venues.venueId
WHERE venueName = 'Friends Arena' AND start_time::date = ('2022-01-16');;

--3. What teams are competing in the women’s slalom alpine ski race?
SELECT distinct(country) FROM Nationalities
JOIN Teams ON Teams.countryId = Nationalities.countryId
JOIN TeamComp ON TeamComp.teamId = Teams.teamId
JOIN Competitions ON TeamComp.compId = Competitions.compId
WHERE compName = 'Slalom Alpine Ski Race' ;

--4. Where and when are the finals in the Bobsleigh race being run?
SELECT venueName, start_time
FROM Venues
JOIN Competitions ON Venues.venueId = Competitions.location
WHERE round = 'Final' AND compName = 'Bobsleigh';

--5. Who are the Goalkeepers for Russian’s men’s ice hockey team?
SELECT fname, lname FROM Athletes
JOIN Teams ON Athletes.teamId = Teams.teamId 
JOIN Nationalities ON Nationalities.countryId = Teams.countryId 
WHERE country = 'Russia' AND sport = 'Hockey' AND gender = 'Male' AND role = 'Goalkeeper';

--6. På vilka datum hålls tävlingar i Speed Skating?
SELECT compName, start_time::date
FROM Competitions
WHERE lower(compName) = 'speedskating';

--7.  Vilka olika tävlingar hålls på Friends Arena?
SELECT DISTINCT(compName)
FROM Venues
JOIN Competitions ON Competitions.location = Venues.venueId
WHERE lower(venueName) = 'friends arena';

--8. Dömer Nils Oskarsson i någon sport där Sverige deltar?
SELECT 
FROM Officials
JOIN Competitions ON Competitions.officialId = Officials.officialId
JOIN TeamComp ON Competitions.compId = TeamComp.compId
JOIN Teams ON TeamComp.teamId = Teams.teamId 
JOIN Nationalities ON Teams.countryId = Nationalities.countryId
WHERE (fname = 'Nils' AND lname = 'Oskarsson' AND country = 'Sweden');

--9. Hur stor andel av atleterna är kvinnor
SELECT (cast(count(female) as decimal)/count(athleteId) * 100) as female_percentage
FROM Athletes
FULL OUTER JOIN (SELECT athleteId as female FROM Athletes where gender = 'Female') 
AS femaleAthletes ON Athletes.athleteId = femaleAthletes.female;



