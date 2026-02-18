-- Question 1
-- What range of years for baseball games played does the provided database cover?
SELECT 
	MIN(year)
	, MAX(year)
	, MAX(year) - MIN(year) AS num_years
FROM homegames;


-- Question 2
-- Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

-- Selecting releavant data from the people table
SELECT
	height
	, playerID
	, debut
	, finalGame
FROM people
ORDER BY height
LIMIT 1;

-- Joining with appearances table to find team and number of games played
SELECT
	height
	, playerID
	, namefirst
	, namelast
	, a.g_all
	, a.teamid
FROM people
LEFT JOIN appearances AS a
USING(playerid)
ORDER BY height
LIMIT 1;


-- Question 3
-- Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- David Price earned a total of $245,553,888 during his major league career

-- Examining CollegePlaying table
SELECT * FROM collegeplaying;

-- Finding Vanderbilt's code in the schools table
SELECT
	schoolid,
	schoolname
FROM schools
WHERE schoolname LIKE 'Vanderbilt%';

-- Finding all unique playerids who played at Vanderbilt (schoolid = vandy)
SELECT DISTINCT playerid
FROM collegeplaying
WHERE schoolid = 'vandy';

-- Joining with people table to find first and last name
SELECT DISTINCT 
	playerid
	, p.namefirst
	, p.namelast
FROM collegeplaying
LEFT JOIN people AS p
USING(playerid)
WHERE schoolid = 'vandy';

-- Joining with salaries table to find each player's yearly salary
SELECT DISTINCT 
	playerid
	, p.namefirst
	, p.namelast
	, s.yearid
	, s.salary
FROM collegeplaying
LEFT JOIN people AS p
USING(playerid)
LEFT JOIN salaries AS s
USING(playerid)
WHERE schoolid = 'vandy';

-- Finding each player's total salary across all years
SELECT DISTINCT 
	playerid
	, p.namefirst
	, p.namelast
	, SUM(s.salary) OVER(PARTITION BY playerid) AS total_salary
FROM collegeplaying
LEFT JOIN people AS p
USING(playerid)
LEFT JOIN salaries AS s
USING(playerid)
WHERE schoolid = 'vandy'
ORDER BY total_salary DESC NULLS LAST;


-- Question 4
-- Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- Examining fielding table
SELECT * FROM fielding;

-- Creating labels based on position (pos)
SELECT
	playerid
	, pos
	, po
	, CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS pos_group
FROM fielding;

-- Finding number of putouts per group in 2016
WITH position_groups AS (
	SELECT
		playerid
		, pos
		, po
		, yearid
		, CASE
			WHEN pos = 'OF' THEN 'Outfield'
			WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			WHEN pos IN ('P', 'C') THEN 'Battery'
			END AS pos_group
	FROM fielding
)
SELECT
	pos_group
	, SUM(po) AS putout_count
FROM position_groups
WHERE yearid = 2016
GROUP BY pos_group;


-- Question 6
-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

-- Chris Owings had the highest success rate at 91.3%

-- Examining batting table
SELECT * FROM batting;

-- Selecting stolen base data from batting table
SELECT
	playerid
	, sb
	, cs
FROM batting;

-- Finding total sb and cs for each player
SELECT
	playerid
	, SUM(sb)
	, SUM(cs)
FROM batting
GROUP BY playerid
ORDER BY SUM(sb) DESC;

-- Setting up theft_table
SELECT DISTINCT
	playerid
	, yearid
	, SUM(sb) AS sum_stolen
	, SUM(cs) AS sum_caught
	, SUM(sb) + SUM(cs) AS theft_attempts
FROM batting
GROUP BY playerid, yearid
ORDER BY yearid DESC, theft_attempts DESC NULLS LAST;

-- Adding column for total base theft attempts and limiting results to players who attempted 20+ thefts in 2016
WITH theft_table AS (
	SELECT DISTINCT
		playerid
		, yearid
		, SUM(sb) AS sum_stolen
		, SUM(cs) AS sum_caught
		, SUM(sb) + SUM(cs) AS theft_attempts
	FROM batting
	GROUP BY playerid, yearid
)
SELECT 
	*
	, ROUND(sum_stolen::NUMERIC * 100 / theft_attempts::NUMERIC, 2) AS pct_success
FROM theft_table
WHERE theft_attempts >= 20
	AND yearid = 2016
ORDER BY pct_success DESC;

-- Finding first and last name for the most successful base thief
SELECT
	playerid
	, namefirst
	, namelast
FROM people
WHERE playerid = 'owingch01';


-- Question 7
-- From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year.

-- Examining teams table
SELECT * FROM teams;

-- Finding all teams that did not win the world series
SELECT *
FROM teams
WHERE wswin = 'N';

-- Finding the largest number of wins for a team that did not win the world series
SELECT
	yearid
	, teamid
	, w
	, wswin
FROM teams
WHERE wswin = 'N'
ORDER BY w DESC NULLS LAST
LIMIT 1;

-- Limiting results to 1970 - 2016
SELECT
	yearid
	, teamid
	, w
	, wswin
FROM teams
WHERE wswin = 'N'
	AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC NULLS LAST
LIMIT 1;

-- Finding number of wins for all world series winners 1970 - 2016
SELECT
	yearid
	, teamid
	, w
	, wswin
FROM teams
WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC NULLS LAST;

-- Finding smallest number of wins for a world series winner 1970 - 2016
-- This year is an anomaly due to the 1981 players' strike and subsequent splitting of the 1981 season into two halves.
SELECT
	yearid
	, teamid
	, w
	, wswin
FROM teams
WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
ORDER BY w NULLS LAST
LIMIT 1;

-- Finding smallest number of wins for a world series winner, excluding 1981
SELECT
	yearid
	, teamid
	, w
	, wswin
FROM teams
WHERE wswin = 'Y'
	AND yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
ORDER BY w NULLS LAST
LIMIT 1;

-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- 23.08%

-- Finding the team with the most wins each year 1970 - 2016
WITH win_table AS (
	SELECT 
		yearid
		, teamid
		, w
		, MAX(w) OVER(PARTITION BY yearid) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
)
SELECT 
	yearid
	, teamid
	, w
FROM win_table
WHERE w = most_wins;

-- Determining whether teams with the most wins won the world series in the same year
WITH win_table AS (
	SELECT 
		yearid
		, teamid
		, w
		, wswin
		, MAX(w) OVER(PARTITION BY yearid) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
)
SELECT 
	yearid
	, teamid
	, w
	, wswin
FROM win_table
WHERE w = most_wins;

-- Determining percentage of teams with the most wins who also won the world series

WITH win_table AS (
	SELECT 
		yearid
		, teamid
		, w
		, wswin
		, MAX(w) OVER(PARTITION BY yearid) AS most_wins
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
)
SELECT
	COUNT(CASE WHEN wswin = 'Y' THEN 1 ELSE NULL END)
	, COUNT(*)
	, ROUND(
		COUNT(CASE WHEN wswin = 'Y' THEN 1 ELSE NULL END)::NUMERIC * 100 / 
		COUNT(wswin)::NUMERIC, 2)
FROM win_table
WHERE w = most_wins;


-- Question 8
-- Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- Examining homegames table
SELECT * FROM homegames;

-- Finding average attendance per game for each unique year/team/park combination
SELECT DISTINCT
	year
	, team
	, hg.park
	, hg.games AS games
	, hg.attendance AS attendance
	, ROUND(hg.attendance::NUMERIC / hg.games::NUMERIC, 2) AS avg_home_attendance
FROM homegames AS hg
INNER JOIN teams
ON year = yearid AND team = teamid
WHERE hg.attendance <> 0
ORDER BY year, team;

-- Limiting year to 2016, games >= 10, and finding the top 5
SELECT DISTINCT
	year
	, team
	, hg.park
	, hg.games AS games
	, hg.attendance AS attendance
	, ROUND(hg.attendance::NUMERIC / hg.games::NUMERIC, 2) AS avg_home_attendance
FROM homegames AS hg
INNER JOIN teams
ON year = yearid AND team = teamid
WHERE hg.attendance <> 0
	AND year = 2016
	AND games >= 10
ORDER BY avg_home_attendance DESC
LIMIT 5;

-- Same everything except it's the bottom 5 now
SELECT DISTINCT
	year
	, team
	, hg.park
	, hg.games AS games
	, hg.attendance AS attendance
	, ROUND(hg.attendance::NUMERIC / hg.games::NUMERIC, 2) AS avg_home_attendance
FROM homegames AS hg
INNER JOIN teams
ON year = yearid AND team = teamid
WHERE hg.attendance <> 0
	AND year = 2016
	AND games >= 10
ORDER BY avg_home_attendance
LIMIT 5;


-- Question 10
-- Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- Examining the batting table
SELECT * FROM batting;

-- Limiting to 2016
SELECT * 
FROM batting
WHERE yearid = 2016;

-- Limiting to at least 1 home run
SELECT * 
FROM batting
WHERE yearid = 2016
	AND hr >= 1;

-- Joining with people table to find first/last name and exclude players that have been playing for less than 10 years
SELECT
	playerid
	, p.namefirst
	, p.namelast
	, LEFT(p.debut, 4)::INTEGER AS debut_year
	, hr
FROM batting
LEFT JOIN people AS p
USING(playerid)
WHERE yearid = 2016
	AND hr >= 1
	AND 2016 - LEFT(p.debut, 4)::INTEGER >= 10
ORDER BY playerid;

-- Finding sum of home runs per player for the 2016 season
SELECT DISTINCT
	playerid
	, p.namefirst
	, p.namelast
	, LEFT(p.debut, 4)::INTEGER AS debut_year
	, SUM(hr) OVER(PARTITION BY playerid) AS homeruns
FROM batting
LEFT JOIN people AS p
USING(playerid)
WHERE yearid = 2016
	AND hr >= 1
	AND 2016 - LEFT(p.debut, 4)::INTEGER >= 10
ORDER BY playerid;

-- Finding sum of other years
SELECT DISTINCT
	playerid
	, yearid
	, p.namefirst
	, p.namelast
	, LEFT(p.debut, 4)::INTEGER AS debut_year
	, SUM(hr) OVER(PARTITION BY playerid, yearid) AS homeruns
FROM batting
LEFT JOIN people AS p
USING(playerid)
WHERE 
	-- yearid = 2016
	hr >= 1
	AND 2016 - LEFT(p.debut, 4)::INTEGER >= 10
ORDER BY playerid;

-- Finding the career max for each player
WITH yearly_homeruns AS (
	SELECT DISTINCT
		playerid
		, yearid
		, p.namefirst
		, p.namelast
		, LEFT(p.debut, 4)::INTEGER AS debut_year
		, SUM(hr) OVER(PARTITION BY playerid, yearid) AS homeruns
	FROM batting
	LEFT JOIN people AS p
	USING(playerid)
	WHERE 
		hr >= 1
		AND 2016 - LEFT(p.debut, 4)::INTEGER >= 10
	ORDER BY playerid
)
SELECT *
	, MAX(homeruns) OVER(PARTITION BY playerid) AS career_max_homeruns
FROM yearly_homeruns;

-- Filtering for players where the career max occurred in 2016
WITH career_max_table AS (
	WITH yearly_homeruns AS (
		SELECT DISTINCT
			playerid
			, yearid
			, p.namefirst
			, p.namelast
			, LEFT(p.debut, 4)::INTEGER AS debut_year
			, SUM(hr) OVER(PARTITION BY playerid, yearid) AS homeruns
		FROM batting
		LEFT JOIN people AS p
		USING(playerid)
		WHERE 
			hr >= 1
			AND 2016 - LEFT(p.debut, 4)::INTEGER >= 10
		ORDER BY playerid
	)
	SELECT *
		, MAX(homeruns) OVER(PARTITION BY playerid) AS career_max_homeruns
	FROM yearly_homeruns
)
SELECT 
	namefirst
	, namelast
	, homeruns
FROM career_max_table
WHERE 
	yearid = 2016 AND
	homeruns = career_max_homeruns;