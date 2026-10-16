--===========================================
--Analysis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           sis queries for prague-weather-etl 
--Data: weather_hourly, 5 city in Czech from Oct 2025 to Sep 2026
--Timestamp are in UTC, convert to Prague time if necessary
--===========================================

-- The average temperature each year
select 
    extract(year from observed_at) as year,
    ROUND(AVG(temperature_c), 2) as avg_temp_year
from weather_hourly 
group by year
order by avg_temp_year DESC;


--Get the city with the most rainy day (more than 1 mm a day)

with daily as (
	select 
		city, 
		(observed_at at TIME zone 'Europe/Prague')::date as day,
		sum(precip_mm) as rainy_mm 
	from weather_hourly wh 
	group by city, day
)
select 
	city,
	COUNT(*) filter (where rainy_mm > 1) rainy_day 
from daily
group by city  
order by rainy_day DESC

--Hottest hours recorded in every city 

WITH ranked AS (
    SELECT city,
           observed_at AT TIME ZONE 'Europe/Prague' AS local_time,
           temperature_c,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY temperature_c DESC NULLS LAST) AS rn
    FROM weather_hourly
)
SELECT city, local_time, temperature_c
FROM ranked
WHERE rn = 1
ORDER BY temperature_c DESC;

--Monthly average temperature per city

select 
	city,
	extract(month from (observed_at at time zone 'Europe/Prague')) as month, 
	ROUND(AVG(temperature_c),1) avg_temp
from weather_hourly wh 
group by city, month
order by city, month

--Day with freezing minimum (<0 degree) but has warm maximum (>10 degree)

select city,
       (observed_at at time zone 'Europe/Prague')::date as day,
       MIN(temperature_c) as min_c,
       MAX(temperature_c) as max_c
from weather_hourly
group by city, day
having MIN(temperature_c) < 0 AND MAX(temperature_c) > 10
order by day, city;

--Rank cities by total precipitation each month 
with total_precip as (
select 
	city, 
	date_trunc('month', observed_at at time zone 'Europe/Prague')::date as month,
	sum(precip_mm) total_precip
from weather_hourly
group by city, month
)
select 
city,
total_precip,
rank() over(partition by month order by total_precip DESC)
from total_precip

--Get the most consecutive dry day per city 

with daily as(
	select city,
		   date_trunc('day', observed_at at time zone 'Europe/Prague')::date  as day,
		   sum(precip_mm) as rain_mm
	from weather_hourly wh 
	group by city, day
),
dry as(
	select city, day, 
		   day - (row_number() over(partition by city order by day))::int as streak_id 
	from daily
	where rain_mm < 0.1	
),
streak as(
	select city, MAX(day) as start_day, MIN(day) as end_day, COUNT(*) as dry_day
	from dry
	group by city, streak_id 
)
select distinct on (city) city, start_day, end_day, dry_day
from streak
order by city, dry_day desc 

-- 7 days rolling average temperature for Prague 
with avg_temp as(
	select (observed_at at time zone 'Europe/Prague')::date as day,
		   avg(temperature_c) avg_temp_day
	from weather_hourly wh
	where city = 'Prague'
	group by day
)
select day, 
	   round(avg_temp_day, 1) as avg_temp,
	   round(avg(avg_temp_day) over(order by day rows between 6 preceding and current row), 1) as rolling_avg 
from avg_temp 
order by day


--Month-over-month temperature change per city
with month_temp as(
select city,
	   date_trunc('month', observed_at at time zone 'Europe/Prague')::date as month,
	   avg(temperature_c) as avg_month_temp
from weather_hourly wh 
group by city, month 
)
select city, month, 
	   round(avg_month_temp,1) avg_month_temp, 
	   round(avg_month_temp - lag(avg_month_temp) over(partition by city order by month),1) as month_change 
from month_temp
order by month, city 


--Windiest city in the evening rush hour (16:00–19:00 Prague time)
with hour_time as(
	select
		city, 
		wind_kmh,
		extract(hour from observed_at at time zone 'Europe/Prague') as hour 
	from weather_hourly
)
select 
	   city,
	   rank() over(order by city) as wind_rank
from hour_time
where hour >= 16 and hour <= 19
group by city 
order by wind_rank DESC

--Same as above 
 select city, 
		round(avg(wind_kmh),1) avg_wind
 from weather_hourly wh 
 where extract(hour from observed_at at time zone 'Europe/Prague') between 16 and 18 
 group by city
