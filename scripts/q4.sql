-- Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

select 
	case
		when pos = 'OF' then 'Outfield'
		when pos = 'SS' or pos = '1B' or pos = '2B' or pos = '3B' then 'Infield'
		when pos = 'P' or pos = 'C' then 'Battery'
		else 'Unspecified'
	end as pos_area,
	sum(po) as total_putouts
from fielding
where yearID = 2016
group by pos_area
order by total_putouts desc;

