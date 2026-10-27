-- 4.2A Conditional aggregation.
-- Question: How many bookings does each flight have, and how many are passenger no-shows?
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
ORDER BY no_show_bookings DESC, flight_id;


-- 4.2B Regional subtotals and a grand total using ROLLUP.
-- Question: What are the booking counts and no-show rates for each booking country and for the whole platform?
-- Country rows are regional subtotals. The Platform total row is the grand total.
SELECT
    COALESCE(booking_country, 'Platform total') AS region,
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
GROUP BY ROLLUP (booking_country)
ORDER BY booking_country;


-- 4.2C Two-step pipeline using a CTE.
-- Question: What is the combined no-show rate for flights with at least 15 bookings?
WITH flight_summary AS (
    SELECT
        flight_id,
        COUNT(*) AS total_bookings,
        SUM(CASE
            WHEN cancellation_reason = 'Passenger no show' THEN 1
            ELSE 0
        END) AS no_show_bookings
    FROM bookings
    GROUP BY flight_id
)
SELECT
    COUNT(*) AS qualifying_flights,
    SUM(total_bookings) AS total_bookings,
    SUM(no_show_bookings) AS no_show_bookings,
    ROUND(
        100.0 * SUM(no_show_bookings) / SUM(total_bookings),
        2
    ) AS no_show_rate_pct
FROM flight_summary
WHERE total_bookings >= 15;