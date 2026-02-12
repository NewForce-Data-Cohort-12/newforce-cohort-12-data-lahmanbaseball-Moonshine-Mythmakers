-- Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

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
		SUM(g::NUMERIC) AS game_count
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