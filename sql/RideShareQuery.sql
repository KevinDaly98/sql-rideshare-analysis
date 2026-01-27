# Use the database

USE uberlyftdb;

# View sample sets of each table to help with undertsanding the data

SELECT *
FROM weather
LIMIT 10;

SELECT *
FROM trips
LIMIT 10;

SELECT *
FROM location
LIMIT 10;

# First lets see how many rides are Lyft or Uber

SELECT SUM(CASE
WHEN cab_type = "Uber" THEN 1
ELSE 0 END) AS Uber,
SUM(CASE WHEN cab_type = "Lyft" THEN 1
ELSE 0 END) AS Lyft
FROM trips;

# Total amount of money earned by each company
# Note how Uber has more rides from above, but Lyft has more revenue

SELECT cab_type, SUM(price) AS total_revenue
FROM trips
GROUP BY cab_type;

# AVG price of a ride
# Lyft has a higher price on average, why is this? 

SELECT cab_type, AVG(price) AS avg_price
FROM trips
GROUP BY cab_type;

# AVG distance of a ride

SELECT cab_type, AVG(distance) AS avg_distance
FROM trips
GROUP BY cab_type;

# Most trips for type of journey, based on the different companies, and order based on the average price of each descending
# Notice the difference in the prices and not the distance, clearly more expensive models. Total rides is consistent and distance

SELECT COUNT(*) AS rides, name, cab_type, AVG(price) AS avg_price, AVG(distance) AS avg_distance
FROM trips
GROUP BY name, cab_type
ORDER BY cab_type, avg_price DESC;


# What time is each company the most active?
# 5PM most expensive, work rush / traffic/ demand

SELECT hour, AVG(price) AS avg_hourly_price, 'Lyft' AS cab_type
FROM trips
WHERE cab_type = 'Lyft'
GROUP BY hour
UNION 
SELECT hour, AVG(price) AS avg_hourly_price, 'Uber' AS cab_type
FROM trips
WHERE cab_type = 'Uber'
GROUP BY hour
ORDER BY avg_hourly_price DESC;

# Show the three most expensive times for each

SELECT hour, AVG(price) AS avg_hourly_price, cab_type, ROW_NUMBER() OVER (PARTITION BY cab_type ORDER BY AVG(price) DESC) AS ranking
FROM trips
GROUP BY hour, cab_type
ORDER BY ranking, cab_type
LIMIT 6;

# How much business in the most expensive hours

SELECT hour, COUNT(id) as trips, cab_type
FROM trips
WHERE (hour IN ('11', '0', '22') && cab_type = 'Lyft')
	OR (hour IN ('21', '20', '8') && cab_type = 'Uber')
GROUP BY cab_type, hour
ORDER BY cab_type, hour;

# What is the combined most active time

SELECT hour, COUNT(*) AS rides
FROM trips
GROUP BY hour
ORDER BY rides DESC;

# Whos busier at peak time? Who makes more? Uber has more rides but less revenue
# Could they change pricing model? Two euro gap is large would even a 50 cent increase help?

SELECT COUNT(*) AS rides, SUM(price) as total_revenue, cab_type
FROM trips
WHERE hour = 0
GROUP BY cab_type
ORDER BY rides DESC;

# Lets see how much Uber will make if they up their prices by 5% at peak time. Woudl this have a negative impact on total customers?

WITH cte AS (SELECT COUNT(*) AS trips_tot, AVG(price) * 1.05 AS updated_price, COUNT(*) * (AVG(price) * 1.05) AS updated_revenue, cab_type
FROM trips
WHERE cab_type = 'Uber'
GROUP BY cab_type)
SELECT rides, total_revenue, avg_price, c.updated_price, ROUND(rides * c.updated_price, 2) AS new_revenue, total.cab_type
FROM
(SELECT COUNT(*) AS rides, SUM(price) as total_revenue, AVG(price) AS avg_price, cab_type
FROM trips
WHERE hour = 0
GROUP BY cab_type) total
JOIN cte c
WHERE total.cab_type = 'Uber'
ORDER BY rides;


# Lets check if total rides can be weather deppendent?
# precipIntesnity is raining

SELECT COUNT(t.id) AS total_rides, SUM(CASE
WHEN w.precipIntensity > 0 THEN 1
ELSE 0 END) AS raining_rides
FROM weather w
JOIN trips t ON w.id = t.id;

# Lets see it as a percent

SELECT CONCAT(ROUND((raining_rides / total_rides),2) * 100,'%') AS raining_ride_percent
FROM 
(SELECT COUNT(t.id) AS total_rides, SUM(CASE
WHEN w.precipIntensity > 0 THEN 1
ELSE 0 END) AS raining_rides
FROM weather w
JOIN trips t ON w.id = t.id) weather_trips;


# Is the price higher in the rain?
# Interesting how on Average the price is slightly higher for Uber and lower for Lyft longer distance or bigger surge?

SELECT AVG(t.price) AS avg_price, COUNT(w.id) AS rides, cab_type
FROM trips t
JOIN weather w ON w.id = t.id
WHERE w.precipIntensity > 0
GROUP BY cab_type;

# AVG distance of a ride in rain?
# Uber on average goes slightly further in the rain than Lyft, however both are higher than typical average

SELECT AVG(t.distance) AS avg_distance_rain, cab_type
FROM trips t
JOIN weather w ON w.id = t.id
WHERE w.precipIntensity > 0
GROUP BY cab_type;



