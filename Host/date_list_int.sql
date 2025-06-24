with users as(
select * from user_devices_cumulated where date=date '2023-01-31'
),
series as(
select * from generate_series(date'2023-01-01',date'2023-01-31', interval '1day') as series_date
),
placeholder as(
select
			case when 
				dates_active @> array[series_date::date]
				then cast(pow(2,32 - (date - series_date::date)) as bigint)
				else 0
				end as place_holder,
				* from users cross join series
)
select user_id,
		device_id,
		browser,
		cast(cast(sum(place_holder) as bigint) as bit(32)),
		bit_count (cast(cast(sum(place_holder) as bigint) as bit(32))) >0 as monthly_active,
		bit_count (cast('11111110000000000000000000000000' as bit(32)) &
	    cast(cast(sum(place_holder) as bigint) as bit(32))) >0 as weekly_active,
		bit_count (cast('10000000000000000000000000000000' as bit(32)) &
		cast(cast(sum(place_holder) as bigint) as bit(32))) > 0 as is_daily_active
		from placeholder
		group by 1,2,3
