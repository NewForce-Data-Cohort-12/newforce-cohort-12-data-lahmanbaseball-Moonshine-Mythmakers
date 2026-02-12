-- 12. In this question, you will explore the connection between number of wins and attendance.
	-- Does there appear to be any correlation between attendance at home games and number of wins?
	-- Do teams that win the world series see a boost in attendance the following year? What about teams that 	made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT year, team, games, attendance
FROM homegames;

SELECT yearid, teamid, ghome, w, l, attendance
FROM teams;

SELECT * FROM homegames;

-- Shows each team's total home game attendance per year
SELECT DISTINCT
	year
	, team
	, SUM(attendance) OVER(PARTITION BY team, year) AS home_attendance
FROM homegames
ORDER BY year, team;

-- Shows each team's total wins (home and away) and their total home game attendance per year
SELECT DISTINCT
	year
	, team
	, w
	, SUM(hg.attendance) OVER(PARTITION BY team, year) AS home_attendance
FROM homegames AS hg
INNER JOIN teams
ON year = yearid AND team = teamid
ORDER BY year, team;
