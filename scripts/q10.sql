-- Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
select p.namefirst, p.namelast, b.yearid, b.sb as stolen, b.cs as caught, (b.sb+b.cs) as attempts, ((b.sb * 100)/(b.sb+b.cs)) as success_pct
from batting as b
join people as p
using(playerid)
where (b.sb + b.cs) >= 20 and b.yearid = 2016
order by success_pct desc
limit 1;