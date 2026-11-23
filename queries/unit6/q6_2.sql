-- Task 6.2A: How did fares change from booking to booking for flight 2?
WITH fare_neighbors AS (
    SELECT
        flight_id,
        booking_id,
        booked_at,
        fare_paid,
        LAG(fare_paid) OVER (
            PARTITION BY flight_id ORDER BY booked_at, booking_id
        ) AS previous_fare,
        LEAD(fare_paid) OVER (
            PARTITION BY flight_id ORDER BY booked_at, booking_id
        ) AS next_fare
    FROM bookings
)
SELECT
    flight_id,
    booking_id,
    booked_at,
    fare_paid,
    previous_fare,
    next_fare,
    fare_paid - previous_fare AS fare_change
FROM fare_neighbors
WHERE flight_id = 2
ORDER BY booked_at, booking_id;

-- Task 6.2B: How close did the platform get to 50 bookings in Q1 2023,
-- and what did recent booking activity look like along the way?
WITH daily_bookings AS (
    SELECT booked_at::date AS booking_date, COUNT(*) AS booking_count
    FROM bookings
    WHERE booked_at >= '2023-01-01' AND booked_at < '2023-04-01'
    GROUP BY booked_at::date
),
booking_trend AS (
    SELECT
        booking_date,
        booking_count,
        SUM(booking_count) OVER (
            ORDER BY booking_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_bookings,
        ROUND(AVG(booking_count) OVER (
            ORDER BY booking_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) AS avg_per_active_day
    FROM daily_bookings
)
SELECT
    booking_date,
    booking_count,
    running_bookings,
    avg_per_active_day,
    50 AS target_bookings,
    running_bookings - 50 AS difference_from_target
FROM booking_trend
ORDER BY booking_date;

-- Task 6.2C: Where did a flight go more than 90 days between recorded bookings?
WITH booking_gaps AS (
    SELECT
        flight_id,
        booking_id,
        booked_at,
        LAG(booked_at) OVER (
            PARTITION BY flight_id ORDER BY booked_at, booking_id
        ) AS previous_booking_at
    FROM bookings
)
SELECT
    flight_id,
    previous_booking_at,
    booked_at AS next_booking_at,
    booked_at - previous_booking_at AS booking_gap
FROM booking_gaps
WHERE booked_at - previous_booking_at > INTERVAL '90 days'
ORDER BY booking_gap DESC, flight_id, booking_id;
