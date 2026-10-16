--===========================================
--Analysis queries for prague-weather-etl 
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