-- 12. In this question, you will explore the connection between number of wins and attendance.
	
-- Does there appear to be any correlation between attendance at home games and number of wins?
		-- Overall yes, though there are many confounding variables. First, 'number of wins' is not an entirely reliable metric because the number of games played in a season is variable. Using percent of games won provides a more standard metric. When all data is compared at once, higher attendance at home games does correlate with a higher win percentage for the season. But partitioning the data into buckets reveals some interesting exceptions.
		-- The win rate changes dramatically at different magnitudes of crowd size. For small crowds (less than 1000 attendees on average), higher average attendance actually correlates with a ~4% decrease in win rate. For medium crowds (1000 to 9999 attendees on average), win rate stays consistent on average, regardless of the average number of attendees. However, for large crowds (10000+ attendees on average), larger average crowd size correlates with a ~6% increase in win rate.
		-- Crowd size also affects each individual team differently. I examined the win rate vs average home game attendance for the ten oldest teams in the dataset. PHI and BOS won about 10% more games on average in years where their average home attendance was at its peak. CIN, SLN, CHA, CLE, and NYA won between 5% and 10% more games in peak attendance years. Of the remaining teams, DET showed a win rate increase of less than 5%, PIT showed no change in win rate, and CHN actually saw a ~3% decrease in win rate for larger crowd sizes.
		-- I also partitioned the data into four different time periods (19th century, early 20th century, late 20th century, and 21st century) to see if there was any meaningful difference in win rate vs crowd size over time. The 19th century showed ~8% increase in win rate at peak crowd size. The early 20th century, late 20th century, and 21st century all showed ~13% increase at peak crowd size. Since crowd sizes were smaller in the 19th century, this aligns with the previous finding that for average crowd sizes under 1000, higher attendance correlates with a lower win rate.


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

-- Adds columns to show the yearly average wins per attendee, and removes years with no attendance data
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, w
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS home_attendance
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT *
	, ROUND(w::NUMERIC / home_attendance::NUMERIC, 6) AS avg_wins_per_attendee
FROM yearly_attendance
WHERE home_attendance <> 0;

-- Add games column from homegames table and calculate avg attendance per home game
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, w
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT *
	, ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) AS avg_home_attendance
FROM yearly_attendance
WHERE total_home_attendance <> 0;

-- Categorizing average attendance by order of magnitude:
	-- Less than 1000 = Small
	-- 1000 to 9999 = Medium
	-- 10000+ = Large
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, w
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT *
	, ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) AS avg_home_attendance
	-- , ROUND(w::NUMERIC / total_home_attendance::NUMERIC, 6) AS avg_wins_per_attendee
	, CASE
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) < 1000 THEN 'Small'
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) BETWEEN 1000 AND 9999 THEN 'Medium'
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) >= 10000 THEN 'Large'
		END AS avg_crowd_size
FROM yearly_attendance
WHERE total_home_attendance <> 0
ORDER BY team, year;

-- Finding percent of games won each year
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, w AS wins
		, g AS games
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT *
	, ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) AS avg_home_attendance
	-- , ROUND(w::NUMERIC / total_home_attendance::NUMERIC, 6) AS avg_wins_per_attendee
	, ROUND(wins::NUMERIC * 100 / games::NUMERIC, 2) AS pct_games_won
	, CASE
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) < 1000 THEN 'Small'
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) BETWEEN 1000 AND 9999 THEN 'Medium'
		WHEN ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) >= 10000 THEN 'Large'
		END AS avg_crowd_size
FROM yearly_attendance
WHERE total_home_attendance <> 0
ORDER BY team, year;

-- Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- Finding rows for teams that won the world series
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
		, wswin
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	WHERE wswin = 'Y'
	ORDER BY year, team
)
SELECT *
	, ROUND(total_home_attendance::NUMERIC / home_games::NUMERIC, 2) AS avg_home_attendance
FROM yearly_attendance;

-- Adding the following year for each world series win
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
		, wswin
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT 
	team
	, ws_win.year AS win_year
	, ws_win.wswin
	, ROUND(ws_win.total_home_attendance::NUMERIC / ws_win.home_games::NUMERIC, 2) AS ws_win_avg_home_attendance
	, ws_next_year.year AS next_year
	, ws_next_year.wswin
	, ROUND(ws_next_year.total_home_attendance::NUMERIC / ws_next_year.home_games::NUMERIC, 2) AS next_year_avg_home_attendance
FROM yearly_attendance AS ws_win
	FULL JOIN yearly_attendance AS ws_next_year
	USING(team)
WHERE ws_win.wswin = 'Y'
	AND ws_win.year + 1 = ws_next_year.year
	AND ROUND(ws_win.total_home_attendance::NUMERIC / ws_win.home_games::NUMERIC, 2) <> 0
	AND ROUND(ws_next_year.total_home_attendance::NUMERIC / ws_next_year.home_games::NUMERIC, 2) <> 0;

-- Calculating difference in avg attendance from each win year to the next year
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
		, wswin
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT 
	team
	, ws_win.year AS win_year
	, ws_win.wswin
	, ROUND(ws_win.total_home_attendance::NUMERIC / ws_win.home_games::NUMERIC, 2) AS ws_win_avg_home_attendance
	, ws_next_year.year AS next_year
	, ws_next_year.wswin
	, ROUND(ws_next_year.total_home_attendance::NUMERIC / ws_next_year.home_games::NUMERIC, 2) AS next_year_avg_home_attendance
	, ROUND(ws_next_year.total_home_attendance::NUMERIC / ws_next_year.home_games::NUMERIC, 2) -
		ROUND(ws_win.total_home_attendance::NUMERIC / ws_win.home_games::NUMERIC, 2)
		AS attendance_growth
FROM yearly_attendance AS ws_win
	FULL JOIN yearly_attendance AS ws_next_year
	USING(team)
WHERE ws_win.wswin = 'Y'
	AND ws_win.year + 1 = ws_next_year.year
	AND ROUND(ws_win.total_home_attendance::NUMERIC / ws_win.home_games::NUMERIC, 2) <> 0
	AND ROUND(ws_next_year.total_home_attendance::NUMERIC / ws_next_year.home_games::NUMERIC, 2) <> 0;

-- Finding the same data for teams that made the playoffs
WITH yearly_attendance AS (
	SELECT DISTINCT
		year
		, team
		, SUM(hg.games) OVER(PARTITION BY team, year) AS home_games
		, SUM(hg.attendance) OVER(PARTITION BY team, year) AS total_home_attendance
		, divwin
		, wcwin
	FROM homegames AS hg
	INNER JOIN teams
	ON year = yearid AND team = teamid
	ORDER BY year, team
)
SELECT 
	team
	, po_win.year AS win_year
	, po_win.divwin
	, po_win.wcwin
	, ROUND(po_win.total_home_attendance::NUMERIC / po_win.home_games::NUMERIC, 2) AS po_win_avg_home_attendance
	, po_next_year.year AS po_next_year
	, po_next_year.divwin
	, po_next_year.wcwin
	, ROUND(po_next_year.total_home_attendance::NUMERIC / po_next_year.home_games::NUMERIC, 2) AS po_next_year_avg_home_attendance
	, ROUND(po_next_year.total_home_attendance::NUMERIC / po_next_year.home_games::NUMERIC, 2) -
		ROUND(po_win.total_home_attendance::NUMERIC / po_win.home_games::NUMERIC, 2)
		AS attendance_growth
FROM yearly_attendance AS po_win
	FULL JOIN yearly_attendance AS po_next_year
	USING(team)
WHERE (po_win.wcwin = 'Y' OR po_win.divwin = 'Y')
	AND po_win.year + 1 = po_next_year.year
	AND ROUND(po_win.total_home_attendance::NUMERIC / po_win.home_games::NUMERIC, 2) <> 0
	AND ROUND(po_next_year.total_home_attendance::NUMERIC / po_next_year.home_games::NUMERIC, 2) <> 0;