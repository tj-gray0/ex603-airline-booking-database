-- 4.1a Platform summary.
-- Question: How many bookings and passengers are there, and what are the total, average, lowest, and highest fares?
SELECT
    COUNT(*) AS total_bookings,
    SUM(fare_paid) AS total_fares,
    ROUND(AVG(fare_paid), 2) AS average_fare,
    MIN(fare_paid) AS minimum_fare,
    MAX(fare_paid) AS maximum_fare,
    COUNT(DISTINCT passenger_id) AS distinct_passengers
FROM bookings;

-- 4.1b Group by producer.
-- Question: How many bookings does each flight have, and what is its average fare?
SELECT
    flight_id,
    COUNT(*) AS total_bookings,
    ROUND(AVG(fare_paid), 2) AS average_fare
FROM bookings
GROUP BY flight_id
ORDER BY total_bookings DESC, flight_id;


-- 4.1c Filter groups with HAVING.
-- Question: What are the no-show rates for flights with at least 15 bookings?
SELECT
    flight_id,
    COUNT(*) AS total_bookings,
    SUM(CASE
        WHEN cancellation_reason = 'Passenger no show' THEN 1
        ELSE 0
    END) AS no_show_bookings,
    ROUND(
        100.0 * SUM(CASE
            WHEN cancellation_reason = 'Passenger no show' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS no_show_rate_pct
FROM bookings
GROUP BY flight_id
HAVING COUNT(*) >= 15
ORDER BY no_show_rate_pct DESC, flight_id;


-- 4.1d Group by two dimensions.
-- Question: How do booking counts, average fares, and no-show rates vary by booking country and flight?
SELECT
    booking_country,
    flight_id,
    COUNT(*) AS total_bookings,
    ROUND(AVG(fare_paid), 2) AS average_fare,
    ROUND(
        100.0 * SUM(CASE
            WHEN cancellation_reason = 'Passenger no show' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS no_show_rate_pct
FROM bookings
GROUP BY booking_country, flight_id
ORDER BY booking_country, flight_id;