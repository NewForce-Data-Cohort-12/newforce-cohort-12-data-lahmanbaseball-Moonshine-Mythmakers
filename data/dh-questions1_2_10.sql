-- 1.What range of years for baseball games played does the provided database cover?
SELECT MIN(yearid) AS earliest, MAX(yearid) AS latest
FROM teams;
-- 1871 - 2016

-- 2.Find the name and height of the shortest player in the database.
-- Edward Carl 43"
-- How many games did he play in? 
-- 1
-- What is the name of the team for which he played?
-- St.Louis Browns


SELECT namegiven, height, COUNT(DISTINCT g_all) AS total_games_played, teams.name
FROM people
INNER JOIN appearances
USING (playerid)
INNER JOIN teams
USING (teamid)
GROUP BY  namegiven, height, teams.name
ORDER BY height ASC
LIMIT 1;



-- 10.Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH career AS
(SELECT playerid, namefirst, namelast, AGE(finalgame::DATE, debut::DATE) AS career_length
FROM people
WHERE AGE(finalgame::DATE, debut::DATE) >= INTERVAL '10 years')
SELECT namefirst, namelast, career_length, yearid, SUM(hr) AS total_hr
FROM career
INNER JOIN batting
USING (playerid)
WHERE yearid = '2016' AND hr >= 1
GROUP BY namefirst, namelast, career_length, yearid
ORDER BY total_hr DESC;





