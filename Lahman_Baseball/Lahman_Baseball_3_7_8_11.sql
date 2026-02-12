-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s 
-- first and last names as well as the total salary they earned in the major leagues. Sort this list in descending 
-- order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- David Price	$81,851,296.00

SELECT 
	p.namefirst AS firstname,
	p.namelast  AS lastname,
	SUM(sa.salary)::NUMERIC::MONEY AS total_salary
FROM people AS p
	JOIN (
	SELECT DISTINCT c.playerid
	FROM collegeplaying AS c
		JOIN schools AS s 
		USING (schoolid)
WHERE s.schoolname = 'Vanderbilt University'
) 
AS vp
	USING (playerid)
		LEFT JOIN salaries sa ON sa.playerid = p.playerid
GROUP BY p.playerid, p.namefirst, p.namelast
ORDER BY total_salary DESC NULLS LAST

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
-- SEA, 116 wins

SELECT teamid , w , wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND (wswin = 'N' OR wswin IS NULL)
ORDER BY w DESC
LIMIT 2;

-- What is the smallest number of wins for a team that did win the world series?

-- LAN with 63 wins

SELECT teamid , w , wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY w ASC

-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case.

-- In 1981 MLB players went on strike mid season, resulting in the season being split in two halves meaning teams only played about
-- 110 games instead of 162. So 63 wins in 1981 is not comparable to normal full seasons.

-- Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins
-- also won the world series? What percentage of the time

SELECT 
	ROUND(100.0 * COUNT(DISTINCT CASE WHEN wswin = 'Y' THEN yearid END) / 
	COUNT(DISTINCT yearid), 2) AS percentage
FROM teams AS t
WHERE yearid BETWEEN 1970 AND 2016 
	AND yearid <> 1981
		AND w = (SELECT MAX(w) FROM teams WHERE yearid = t.yearid);
		

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance
-- per game in 2016 (where average attendance is defined as total attendance divided by number of games).
-- Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance.
-- Repeat for the lowest 5 average attendance.

-- Top 5

SELECT 
    p.park_name,
    t.name AS team_name,
    h.attendance / h.games AS avg_attendance
FROM homegames AS h
JOIN parks AS p 
	USING (park)
JOIN teams t 
	ON h.team = t.teamid 
	AND h.year = t.yearid
WHERE h.year = 2016 
	AND h.games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;

-- Bottom 5

SELECT 
    p.park_name,
    t.name AS team_name,
    h.attendance / h.games AS avg_attendance
FROM homegames AS h
JOIN parks AS p 
	USING (park)
JOIN teams t 
	ON h.team = t.teamid 
	AND h.year = t.yearid
WHERE h.year = 2016 
	AND h.games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;

-- **Open-ended question**

-- 11. Is there any correlation between number of wins and team salary?
-- Use data from 2000 and later to answer this question. As you do this analysis,
-- keep in mind that salaries across the whole league tend to increase together,
-- so you may want to look on a year-by-year basis.

-- This shows each team's total salary and wins from 2000 onward as raw data.
-- The results show that higher salary does not always lead to more wins.

-- For example in the year 2000 the New York Yankees had 87 wins with a salary of $92,338,260.00 compared to
-- the Chicago White Sox who had 95 wins with a salary of $31,133,500.00.
 
SELECT 
	t.yearid,
	t.teamid,
	t.w AS wins,
    SUM(s.salary)::NUMERIC::MONEY AS total_salary
FROM teams AS t
JOIN salaries AS s 
	USING(teamid, yearid)
WHERE t.yearid >= 2000
GROUP BY t.yearid, t.teamid, t.w
ORDER BY t.yearid, total_salary DESC;

-- This second query uses the CORR function to measure the relationship 
-- between salary and wins by each year. The results show that the connection 
-- between salary and wins is stronger in some years and weaker in others
-- meaning other factors beyond salary contribute to team success.

WITH team_stats AS (
	SELECT 
	t.yearid
	, t.w
	, SUM(s.salary) AS total_salary
FROM teams AS t
	JOIN salaries AS s 
		USING(teamid, yearid)
WHERE t.yearid >= 2000
GROUP BY t.yearid, t.teamid, t.w
)
SELECT yearid, CORR(w, total_salary) 
FROM team_stats
GROUP BY yearid 
ORDER BY yearid;