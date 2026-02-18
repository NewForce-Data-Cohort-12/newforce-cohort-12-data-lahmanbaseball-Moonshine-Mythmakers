-- 8: Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
-- top
select p.park_name, t.name AS team_name, ROUND(hg.attendance::numeric / hg.games, 2) AS avg_attendance
from homegames hg
join parks p
using(park)
join teams t
on hg.team = t.teamid and hg.year = t.yearid
where hg.year = 2016 and hg.games >= 10
order by avg_attendance desc
limit 5;

-- botton
select p.park_name, t.name AS team_name, ROUND(hg.attendance::numeric / hg.games, 2) AS avg_attendance
from homegames hg
join parks p
using(park)
join teams t
on hg.team = t.teamid and hg.year = t.yearid
where hg.year = 2016 and hg.games >= 10
order by avg_attendance asc
limit 5;
