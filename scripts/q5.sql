-- 5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT (yearid / 10) * 10 AS decade,
	ROUND(SUM(so)::numeric / SUM(g), 2) AS strikeouts_per_game,
	ROUND(SUM(hr)::numeric / SUM(g), 2) AS home_runs_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;


-- --  both of these use integer math. since there is no decimal with integers,
-- -- 		it leaves us with the left 3 of the year.  
-- 		1871/10 = 187  (187.1 but int has no decimal)
--	    187*10 = 1870

-- select yearid, (yearid / 10) * 10 AS decade
-- from teams

-- this one has to cast to ::numeric so as to NOT lose the decimal in the division
-- the ::numeric cast has been left off of this one since i was losing my mind working it out.

-- SELECT (yearid / 10) * 10 AS decade,
-- 	ROUND(SUM(so)::numeric / SUM(g), 2) AS strikeouts_per_game,
-- 	ROUND(SUM(hr)::numeric / SUM(g), 2) AS home_runs_per_game
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY decade
-- ORDER BY decade;
