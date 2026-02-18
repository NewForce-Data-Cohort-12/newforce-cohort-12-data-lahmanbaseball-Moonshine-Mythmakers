-- 2: Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

select namefirst, namelast, height, g_all as games_played, teams.name
from people
join appearances
using(playerid)
join teams
using(teamid)
order by height asc
limit 1;
