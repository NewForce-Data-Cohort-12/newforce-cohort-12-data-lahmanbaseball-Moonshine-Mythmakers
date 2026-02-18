-- 3: Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

select s.schoolname, p.namefirst, p.namelast, sum(salaries.salary) as total_salary
from schools as s
join collegeplaying as c
using(schoolid)
join people as p
using(playerid)
join salaries as salaries
using(playerid)
where schoolname = 'Vanderbilt University'
group by c.playerid, c.schoolid, s.schoolname, p.namefirst, p.namelast
order by total_salary desc;
