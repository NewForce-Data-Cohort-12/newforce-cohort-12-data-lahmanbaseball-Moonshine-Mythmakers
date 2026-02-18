-- In these exercises, you'll explore a couple of other advanced features of PostgreSQL.

-- In this question, you'll get to practice correlated subqueries and learn about the LATERAL keyword. Note: This could be done using window functions, but we'll do it in a different way in order to revisit correlated subqueries and see another keyword - LATERAL.
-- a. First, write a query utilizing a correlated subquery to find the team with the most wins from each league in 2016.

-- If you need a hint, you can structure your query as follows:

-- SELECT DISTINCT lgid, ( ) FROM teams t WHERE yearid = 2016;
select distinct lgid,
from teams as t
where yearid = 2016;

select teamid, lgid, w
from teams
where yearid = 2016
order by w desc;

----------------A:
SELECT
    t.lgid,
    t.teamid,
    t.w AS wins
FROM teams t
WHERE t.yearid = 2016
  AND t.w = (
        SELECT MAX(t2.w)
        FROM teams t2
        WHERE t2.yearid = 2016
          AND t2.lgid = t.lgid
    )
ORDER BY t.lgid;

SELECT MAX(t2.w)
        FROM teams t2
        WHERE t2.yearid = 2016

------------------------
SELECT teamid, w, l, total_games, w*100.0 / total_games AS winning_pct FROM teams t, LATERAL ( SELECT w + l AS total_games ) AS tg WHERE yearid = 2016 ORDER BY winning_pct DESC;

select namefirst, namelast, birthmonth, birthday, birthyear from people, 
	lateral(select birthday+birt as birthdate)
