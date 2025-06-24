with host as(
select * from host_cumulated where date='2023-01-31'
),
series as(
select * from generate_series(date '2023-01-01',date '2023-01-31',interval '1 day') as series_date
),
place_holder as
(
select 
		case when 
					dates_hit @> array[series_date::date]
					then
					cast(pow(2,30 - (date - series_date::date)) as bigint)
					else 0
					end as placeholder,
					*
					from host cross join series
)
select host,
		metric_name,
		cast(cast(sum(placeholder) as bigint) as bit(31)),
		bit_count (cast(cast(sum(placeholder) as bigint) as bit(31))) >0 as monthly_active,
		bit_count (cast ('11111110000000000000000000000000' as bit(31)) &
				   cast(cast(sum(placeholder) as bigint) as bit(31))) > 0 as weekly_active,
		bit_count (cast('10000000000000000000000000000000' as bit(31)) &
					cast(cast(sum(placeholder) as bigint) as bit(31))) > 0	as daily_active
				from place_holder 
				group by 1,2
		