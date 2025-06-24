-- create table u_cumulated(
-- userid text,
-- dates_active date[],
-- date date,
-- primary key (userid, date)
-- )
-- drop table u_cumulated
-- insert into u_cumulated
WITH yesterday AS (
  SELECT * 
  FROM u_cumulated 
  WHERE date = DATE '2023-01-31'
),
today AS (
  SELECT 
    cast(user_id as text) as user_id,
    DATE(CAST(event_time AS TIMESTAMP)) AS date_active
  FROM events
  WHERE 
    DATE(CAST(event_time AS TIMESTAMP)) = DATE '2023-02-01'
    AND user_id IS NOT NULL
  GROUP BY user_id, DATE(CAST(event_time AS TIMESTAMP))
)
select 
		coalesce(t.user_id, y.userid) as user_id,
		case when y.dates_active is null then array[t.date_active]
			 when t.date_active is null then y.dates_active
			 else  array[t.date_active] || y.dates_active 
			 end as dates_active,
		coalesce(t.date_active, y.date + interval '1 day') as date
from today t full outer join yesterday y on
t.user_id=y.userid

