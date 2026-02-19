-- Question 5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- For both strikeouts and home runs, the average per game generally increases over time.

-- Methodology:
-- Strikeouts, home runs, games, and years are recorded in the Batting table
-- The Teams table would be better than the Batting table because it records the number of games played and the number of strikeouts, homeruns from each team for each year
-- Need to figure out how to group by decade

-- Rough drafts:

	-- SELECT * FROM batting;
	
	-- SELECT 
	-- 	yearid
	-- 	, g
	-- 	, so
	-- 	-- , LEFT(yearid::TEXT, 3)
	-- 	, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	-- FROM batting
	-- WHERE yearid >= 1920;

	-- SELECT * FROM teams;
	
	-- SELECT 
	-- 	yearid
	-- 	, g
	-- 	, so
	-- 	, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	-- 	, SUM(g) OVER(
	-- 				PARTITION BY CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER
	-- 				ORDER BY yearid) AS game_count
	-- 	, SUM(so) OVER(
	-- 				PARTITION BY CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER
	-- 				ORDER BY yearid) AS strikeout_count
	-- FROM teams
	-- WHERE yearid >= 1920;
	
	-- SELECT 
	-- 	SUM(g) AS game_count
	-- 	, SUM(so) AS strikeout_count
	-- 	, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	-- FROM teams
	-- WHERE yearid >= 1920
	-- GROUP BY decade
	-- ORDER BY decade;

-- Strikeouts per game per decade:

WITH games_strikeouts_per_decade AS (
	SELECT 
		SUM(g::NUMERIC) AS game_count
		, SUM(so::NUMERIC) AS strikeout_count
		, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	FROM teams
	WHERE yearid >= 1920
	GROUP BY decade
	ORDER BY decade
)
SELECT 
	decade
	, ROUND(strikeout_count / game_count, 2) AS avg_strikeouts_per_game
FROM games_strikeouts_per_decade;

-- Homeruns per game per decade:

WITH games_homeruns_per_decade AS (
	SELECT 
		SUM(g::NUMERIC) AS game_count
		, SUM(hr::NUMERIC) AS homerun_count
		, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	FROM teams
	WHERE yearid >= 1920
	GROUP BY decade
	ORDER BY decade
)
SELECT 
	decade
	, ROUND(homerun_count / game_count, 2) AS avg_homeruns_per_game
FROM games_homeruns_per_decade;

-- Combining results into one table:
WITH g_so_hr_per_decade AS (
	SELECT 
		-- Dividing game_count by 2 since each game in the teams table has two associated teams
		SUM(g::NUMERIC)/2 AS game_count 
		, SUM(so::NUMERIC) AS strikeout_count
		, SUM(hr::NUMERIC) AS homerun_count
		, CONCAT(LEFT(yearid::TEXT, 3), '0')::INTEGER AS decade
	FROM teams
	WHERE yearid >= 1920
	GROUP BY decade
	ORDER BY decade
)
SELECT 
	decade
	, ROUND(strikeout_count / game_count, 2) AS avg_strikeouts_per_game
	, ROUND(homerun_count / game_count, 2) AS avg_homeruns_per_game
FROM g_so_hr_per_decade;



-- Question 9: Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH al_nl_managers AS (
		(SELECT playerid 
			FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'NL'
		ORDER BY playerid, yearid)
	INTERSECT
		(SELECT playerid 
			FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
			AND lgid = 'AL'
		ORDER BY playerid, yearid)
)
SELECT DISTINCT 
	playerid
	, p.nameFirst
	, p.nameLast
	, teamid
	, teams.name
	, awardid
	, yearid
	, am.lgid 
	FROM awardsmanagers AS am
INNER JOIN people AS p
	USING(playerid)
LEFT JOIN managers AS m
USING(playerid, yearid)
INNER JOIN teams
USING(teamid, yearid)
WHERE playerid IN (SELECT playerid FROM al_nl_managers)
	AND awardid = 'TSN Manager of the Year'
ORDER BY playerid, yearid
;

-- SELECT * FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year'
-- 	AND (lgid = 'NL' OR lgid = 'AL')
-- ORDER BY playerid, yearid
-- ;

-- SELECT * 
-- FROM managers
-- WHERE playerid IN ('johnsda02', 'leylaji99')
-- ORDER BY playerid, yearid;

-- WITH nl AS (
-- 	SELECT * FROM awardsmanagers
-- 	WHERE awardid = 'TSN Manager of the Year'
-- 		AND lgid = 'NL'
-- 	ORDER BY playerid, yearid
-- )
-- SELECT * FROM nl
-- INNER JOIN (
-- 	SELECT * FROM awardsmanagers
-- 	WHERE awardid = 'TSN Manager of the Year'
-- 		AND lgid = 'AL'
-- 	ORDER BY playerid, yearid)
-- USING(playerid)
-- ;

-- (SELECT playerid, awardid, yearid, lgid FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year'
-- 	AND lgid = 'NL'
-- ORDER BY playerid, yearid)
-- UNION
-- (SELECT playerid, awardid, yearid, lgid FROM awardsmanagers
-- WHERE awardid = 'TSN Manager of the Year'
-- 	AND lgid = 'AL'
-- ORDER BY playerid, yearid)
-- ;