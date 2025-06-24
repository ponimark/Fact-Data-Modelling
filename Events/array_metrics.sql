-- create table array_metrics(
-- 	user_id numeric,
-- 	month_start date,
-- 	metric_name text,
-- 	metric_array real[],
-- 	primary key(user_id,month_start,metric_name)
-- )

insert into array_metrics
with daily_agg as(
	select 
			user_id,
			date(event_time) as date,
		count(1) as num_site_hit
		from events
		where date(event_time)=date '2023-01-04'
		and user_id is not null
		group by user_id,date(event_time)
),
yesterday as(
select * from array_metrics 
	where month_start = date '2023-01-01'
)
select 
		coalesce(d.user_id,y.user_id) as user_id,
		coalesce(y.month_start,date_trunc('month',d.date)) as month_start,
		'site_hits' as metric_name,
		case when y.metric_array is not null	
		then	y.metric_array || array[coalesce(d.num_site_hit, 0)]
		when	y.metric_array is null then array_fill (0, array[coalesce(date - date(date_trunc('month', date)),0)]) || array[coalesce(d.num_site_hit, 0)]
		end as metric_array
from daily_agg d full outer join yesterday y on
	d.user_id=y.user_id
	on conflict(user_id, month_start, metric_name)
	do
	update set metric_array = excluded.metric_array


