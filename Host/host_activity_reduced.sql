insert into host_activity_reduced
with base as(
select host,
	   user_id,
	   date(event_time) as date,
	   count(1) as site_hit
	   from events
	   where user_id is not null
	   group by 1,2,3
	   order by date,host
	   
),
agg as(
select 
		host,
		date,
		sum(site_hit) as site_hit,
		count(1) as count_users
		from base d
		where date=date '2023-01-22'
		group by 1,2
		order by date
),
yesterday as(
select * from host_activity_reduced
where start_date=date'2023-01-01'
)
select 
		coalesce(h.host,a.host) as host,
		 coalesce(h.start_date,date_trunc('month',a.date)) as month_start,
		case when h.site_hit is not null	
		then h.site_hit || array[coalesce(a.site_hit,0)]
		when h.site_hit is null
		then array_fill(0, array[coalesce(date - date(date_trunc('month', date)),0)]) 
		|| array[coalesce(a.site_hit, 0)]
		end as site_hit,
		case when h.visitors is not null	
		then	h.visitors || array[coalesce(a.count_users,0)]
		when	h.visitors is null 
		then array_fill (0, array[coalesce(date - date(date_trunc('month', date)),0)])
		|| array[coalesce(a.count_users, 0)]
		end as visitors
from agg a full outer join yesterday h on
	h.host=a.host
on conflict (host, start_date)
	do
	update set site_hit = excluded.site_hit,
	 visitors = excluded.visitors
	

