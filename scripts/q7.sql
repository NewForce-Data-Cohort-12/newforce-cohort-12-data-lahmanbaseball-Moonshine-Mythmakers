-- 7: From 1970 - 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
-- largest wins no world series
select yearid, name, wswin, w, l
from teams
where yearid >= 1970 and yearid <= 2016 and yearid != 1981 and wswin = 'N'
order by w desc
limit 1;
-- smallest wins with world series
select yearid, name, wswin, w, l
from teams
where yearid >= 1970 and yearid <= 2016 and yearid != 1981 and wswin = 'Y'
order by w asc
limit 1;
