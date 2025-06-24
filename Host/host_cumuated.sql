-- create table host_cumulated(
-- 			host text,
-- 			metric_name text,
-- 			dates_hit date[],
-- 			date date,
-- 			primary key(host,date,metric_name)
			
-- )
insert into host_cumulated
with dates as(
select * from generate_series(date '2023-01-01',date '2023-01-31',interval '1 day') as date
),
host as(
select  
		host,
		min(cast(event_time as date)) as first_hit
		from events
		where host is not null 
		group by 1
),
merged as(
select h.host,
	   date(d.date)
	   from host h join dates d on h.first_hit<=d.date
),
joined as(
select 
		m.*,
		date(event_time) as event_time
		from merged m join events e on m.date=cast(e.event_time as date)
),
windowed as(
select f.host,
		'site hit' as metric_name,
		array_remove(
					array_agg(
					case when 
						f.event_time is not null then f.date
						else null
						end
						) over (partition by f.host order by f.date),
						null
						) as dates_hit,
						f.date as date
						from joined f left join host_cumulated h on f.date=h.date and f.host=h.host
),
deduped as (
select *,
row_number() over (partition by host,metric_name,date order by date) as rn
from windowed
)
SELECT 
  host,
  metric_name,
  ARRAY(
    SELECT DISTINCT d
    FROM unnest(dates_hit) AS d
	order by d  
  ) AS deduped_dates,
  date
FROM deduped
WHERE rn = 1;




		