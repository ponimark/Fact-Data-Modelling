insert into user_devices_cumulated 
WITH dates AS (
  SELECT * FROM generate_series(DATE '2023-01-01', DATE '2023-01-31', Interval '1 day') AS date
),
events_devices as(
select e.user_id,d.browser_type,d.device_id,min(cast(event_time as date)) as first_login
from events e join devices d on e.device_id=d.device_id 
where user_id is not null
group by 1,2,3
),
date_merged as(
select 
		a.user_id,
		a.device_id,
		a.browser_type,
		cast(y.date as date) as date
		from dates y join events_devices a on a.first_login<=y.date
),
final_merged as(
	select 
			m.user_id,
			m.device_id,
			m.browser_type, 
			m.date,
			cast(e.event_time as date) as event_date
			from date_merged m left join events e on m.date=cast(e.event_time as date) 
			and m.user_id=e.user_id 
			and m.device_id=e.device_id
),
deduped as (
select *,
row_number() over (partition by user_id,device_id,browser_type,date) as rn
from final_merged
)
select cast(d.user_id as text) as user_id,
		cast(d.device_id as text) as device_id,
		d.browser_type as browser,
		array_remove(
  					array_agg(
    				CASE 
					      WHEN d.event_date IS NOT NULL THEN d.date
					      	ELSE NULL
					   			 END
					 		 ) OVER (PARTITION BY d.user_id, d.device_id, d.browser_type 
							  order by d.date),
					 		 NULL
							) AS date_active,

					d.date as date
					from deduped d left join user_devices_cumulated u on d.date=u.date 
			and cast(d.user_id as text)=u.user_id 
			and cast(d.device_id as text)=u.device_id
			where rn=1
			order by user_id,date

				