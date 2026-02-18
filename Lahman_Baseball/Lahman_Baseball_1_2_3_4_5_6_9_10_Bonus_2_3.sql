-- 1. What range of years for baseball games played does the provided database cover? 

SELECT 
	MIN(yearid) AS first_year
	, MAX(yearid) AS last_year
FROM teams;

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT 
	p.namefirst
	, p.namelast
	, p.height
	, SUM(a.g_all) AS games_played
	, t.name AS team
FROM people AS p
LEFT JOIN appearances AS a 
	ON p.playerid = a.playerid
LEFT JOIN teams AS t 
	ON a.teamid = t.teamid 
			AND a.yearid = t.yearid
WHERE p.height = (SELECT MIN(height) FROM people)
GROUP BY p.playerid, p.namefirst, p.namelast, p.height, t.name;


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		END AS position_group
	, SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
	AND pos IN ('OF', 'SS', '1B', '2B', '3B', 'P', 'C')
GROUP BY position_group;

   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
	FLOOR(yearid / 10) * 10 AS decade
	, ROUND(SUM(so) * 1.0 / SUM(g), 2) AS avg_strikeouts_per_game
	, ROUND(SUM(hr) * 1.0 / SUM(g), 2) AS avg_homeruns_per_game
FROM teams
WHERE yearid >=1920
GROUP BY decade 
ORDER BY decade;

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

-- FIRSTNAME  LASTNAME  SB  CS  ATTEMPTS  SUSCCESS %
--  Chris	   Owings   21	 2	   23	    91.30

SELECT 
	p.namefirst
	, p.namelast
	, SUM(b.sb) AS stolen_bases
	, SUM(b.cs) AS caught_stealing
	, SUM(b.sb) + SUM(b.cs) AS total_attempts
	, ROUND(SUM(b.sb) * 100.0 / (SUM(b.sb) + SUM(b.cs)), 2) AS success_percentage
FROM batting AS b
JOIN people AS p 
	ON b.playerid = p.playerid
WHERE b.yearid = 2016
GROUP BY p.playerid, p.namefirst, p.namelast
HAVING SUM(b.sb) + SUM(b.cs) >= 20
ORDER BY success_percentage DESC
LIMIT 1;

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

SELECT 
    p.namefirst
    , p.namelast
    , am.lgid
    , am.yearid
    , t.name AS team_name
FROM awardsmanagers AS am
JOIN people AS p 
	USING(playerid)
JOIN managers AS m 
	USING(playerid, yearid, lgid)
JOIN teams AS t 
	ON m.teamid = t.teamid 
		AND m.yearid = t.yearid
WHERE am.awardid = 'TSN Manager of the Year'
    AND am.playerid IN (SELECT playerid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year'
		GROUP BY playerid
		HAVING COUNT(DISTINCT lgid) = 2
		)
ORDER BY p.namelast, am.yearid;



-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH career_hr AS (
	SELECT 
	playerid
	, yearid
	, SUM(hr) AS hr
    FROM batting
    GROUP BY playerid, yearid
	)
SELECT 
    p.namefirst
    , p.namelast
    , c.hr AS homeruns_2016
FROM career_hr AS c
JOIN people AS p 
	USING(playerid)
WHERE c.yearid = 2016
	AND c.hr >= 1
	AND c.hr >= ALL (
	SELECT hr 
	FROM career_hr 
	WHERE playerid = c.playerid
	)
		AND (SELECT COUNT(DISTINCT yearid) 
		FROM career_hr 
		WHERE playerid = c.playerid) >= 10
ORDER BY c.hr DESC;

-- BONUS 2. Another advantage of lateral joins is for when you create calculated columns. In a regular query, when you create a calculated column, you cannot refer it it when you create other calculated columns. This is particularly useful if you want to reuse a calculated column multiple times. For example,

-- SELECT 
-- 	teamid,
-- 	w,
-- 	l,
-- 	w + l AS total_games,
-- 	w*100.0 / total_games AS winning_pct
-- FROM teams
-- WHERE yearid = 2016
-- ORDER BY winning_pct DESC;

-- results in the error that "total_games" does not exist. However, I can restructure this query using the LATERAL keyword.

-- SELECT
-- 	teamid,
-- 	w,
-- 	l,
-- 	total_games,
-- 	w*100.0 / total_games AS winning_pct
-- FROM teams t,
-- LATERAL (
-- 	SELECT w + l AS total_games
-- ) AS tg
-- WHERE yearid = 2016
-- ORDER BY winning_pct DESC;

-- a. Write a query which, for each player in the player table, assembles their birthyear, birthmonth, and birthday into a single column called birthdate which is of the date type.

SELECT 
	p.playerid
	, p.namefirst
	, p.namelast
	, bd.birthdate
FROM people AS p,
LATERAL (
    SELECT MAKE_DATE(p.birthyear, p.birthmonth, p.birthday) AS birthdate
) AS bd;

-- b. Use your previous result inside a subquery using LATERAL to calculate for each player their age at debut and age at retirement. (Hint: It might be useful to check out the PostgreSQL date and time functions https://www.postgresql.org/docs/8.4/functions-datetime.html).

SELECT 
	p.playerid
	, p.namefirst
	, p.namelast
	, bd.birthdate
	, p.debut
	, p.finalgame
	, ages.age_at_debut
	, ages.age_at_retirement
FROM people AS  p
CROSS JOIN LATERAL (
	SELECT MAKE_DATE(p.birthyear, p.birthmonth, p.birthday) AS birthdate
) AS bd 
CROSS JOIN LATERAL (
	SELECT 
		EXTRACT(YEAR FROM AGE(p.debut::DATE, bd.birthdate)) AS age_at_debut,
    	EXTRACT(YEAR FROM AGE(p.finalgame::DATE, bd.birthdate)) AS age_at_retirement
) AS ages;


-- c. Who is the youngest player to ever play in the major leagues?

-- FIRSTNAME LAST NAME    BIRTHDAY      DEBUT     FINALGAME   DEBUT AGE   RETIREMENT AGE
--   Joe	  Nuxhall    1928-07-30   1944-06-10  1966-10-02	  15	        38

SELECT 
	p.playerid
	, p.namefirst
	, p.namelast
	, bd.birthdate
	, p.debut
	, p.finalgame
	, ages.age_at_debut
	, ages.age_at_retirement
FROM people AS  p
CROSS JOIN LATERAL (
	SELECT MAKE_DATE(p.birthyear, p.birthmonth, p.birthday) AS birthdate
) AS bd 
CROSS JOIN LATERAL (
	SELECT 
		EXTRACT(YEAR FROM AGE(p.debut::DATE, bd.birthdate)) AS age_at_debut,
    	EXTRACT(YEAR FROM AGE(p.finalgame::DATE, bd.birthdate)) AS age_at_retirement
) AS ages
ORDER BY age_at_debut ASC
LIMIT 1;

-- d. Who is the oldest player to player in the major leagues? You'll likely have a lot of null values resulting in your age at retirement calculation. Check out the documentation on sorting rows here https://www.postgresql.org/docs/8.3/queries-order.html about how you can change how null values are sorted.

-- FIRST NAME  LAST NAME   BIRTHDAY     DEBUT       FINAL GAME  DEBUT AGE   RETIREMENT AGE
-- 	Satchel	     Paige	  1906-07-07   1948-07-09   1965-09-25	    42	          59

SELECT 
	p.playerid
	, p.namefirst
	, p.namelast
	, bd.birthdate
	, p.debut
	, p.finalgame
	, ages.age_at_debut
	, ages.age_at_retirement
FROM people AS  p
CROSS JOIN LATERAL (
	SELECT MAKE_DATE(p.birthyear, p.birthmonth, p.birthday) AS birthdate
) AS bd 
CROSS JOIN LATERAL (
	SELECT 
		EXTRACT(YEAR FROM AGE(p.debut::DATE, bd.birthdate)) AS age_at_debut,
    	EXTRACT(YEAR FROM AGE(p.finalgame::DATE, bd.birthdate)) AS age_at_retirement
) AS ages
ORDER BY ages.age_at_retirement DESC NULLS LAST
LIMIT 1;

-- BONUS 3. For this question, you will want to make use of RECURSIVE CTEs (see https://www.postgresql.org/docs/13/queries-with.html). The RECURSIVE keyword allows a CTE to refer to its own output. Recursive CTEs are useful for navigating network datasets such as social networks, logistics networks, or employee hierarchies (who manages who and who manages that person). To see an example of the last item, see this tutorial: https://www.postgresqltutorial.com/postgresql-recursive-query/. 

-- In the next couple of weeks, you'll see how the graph database Neo4j can easily work with such datasets, but for now we'll see how the RECURSIVE keyword can pull it off (in a much less efficient manner) in PostgreSQL. (Hint: You might find it useful to look at this blog post when attempting to answer the following questions: https://data36.com/kevin-bacon-game-recursive-sql/.)

-- a. Willie Mays holds the record of the most All Star Game starts with 18. How many players started in an All Star Game with Willie Mays? (A player started an All Star Game if they appear in the allstarfull table with a non-null startingpos value).

WITH mays AS (
SELECT p.playerid
FROM people AS P
WHERE namefirst = 'Willie' 
	AND namelast = 'Mays'
),
mays_games AS (
SELECT a.gameid 
FROM allstarfull AS a
WHERE a.playerid = (SELECT playerid FROM mays)
	AND a.startingpos IS NOT NULL
)
SELECT COUNT(DISTINCT playerid) AS player_started_with_mays
FROM allstarfull AS a
WHERE a.gameid IN (SELECT gameid FROM mays_games)
	AND a.startingpos IS NOT NULL
	AND a.playerid <> (SELECT playerid FROM mays);

-- b. How many players didn't start in an All Star Game with Willie Mays but started an All Star Game with another player who started an All Star Game with Willie Mays? For example, Graig Nettles never started an All Star Game with Willie Mayes, but he did star the 1975 All Star Game with Blue Vida who started the 1971 All Star Game with Willie Mays.

WITH mays AS (
SELECT p.playerid
FROM people AS P
WHERE namefirst = 'Willie' 
	AND namelast = 'Mays'
),
degree_1 AS (
SELECT DISTINCT  a.playerid
FROM allstarfull AS a
WHERE a.startingpos IS NOT NULL
	AND a.gameid IN (
		SELECT gameid 
		FROM allstarfull 
		WHERE playerid = (SELECT playerid FROM mays)
		AND startingpos IS NOT NULL
	)
	AND a.playerid <> (SELECT playerid FROM mays)
)
SELECT COUNT(DISTINCT a2.playerid) players_2_degrees_from_mays
FROM degree_1 AS d1
JOIN allstarfull a1 
	ON d1.playerid = a1.playerid
		AND a1.startingpos IS NOT NULL
JOIN allstarfull a2 
	ON a1.gameid = a2.gameid 
		AND a2.startingpos IS NOT NULL
WHERE a2.playerid <> (SELECT playerid FROM mays)
	AND a2.playerid NOT IN (SELECT playerid FROM degree_1);
