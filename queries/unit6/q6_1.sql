-- Task 6.1A: How does each booking fare compare with its flight's average?
SELECT
    flight_id,
    booking_id,
    fare_paid,
    ROUND(AVG(fare_paid) OVER (PARTITION BY flight_id), 2) AS flight_avg_fare,
    ROUND(fare_paid - AVG(fare_paid) OVER (PARTITION BY flight_id), 2) AS difference_from_avg
FROM bookings
ORDER BY flight_id, booking_id;

-- Task 6.1A: What does the same average look like with one row per flight?
SELECT
    flight_id,
    ROUND(AVG(fare_paid), 2) AS flight_avg_fare,
    COUNT(*) AS booking_count
FROM bookings
GROUP BY flight_id
ORDER BY flight_id;

-- Task 6.1B: How do three ranking methods handle flights with the same booking count?
WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS booking_count
    FROM flights f
    LEFT JOIN bookings b ON b.flight_id = f.flight_id
    GROUP BY f.flight_id, f.flight_number
)
SELECT
    flight_id,
    flight_number,
    booking_count,
    ROW_NUMBER() OVER (ORDER BY booking_count DESC, flight_id) AS row_number,
    RANK() OVER (ORDER BY booking_count DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY booking_count DESC) AS dense_rank
FROM flight_counts
ORDER BY booking_count DESC, flight_id;

-- Task 6.1C: How does splitting flights into four booking bands treat ties?
WITH flight_counts AS (
    SELECT
        f.flight_id,
        f.flight_number,
        COUNT(b.booking_id) AS booking_count
    FROM flights f
    LEFT JOIN bookings b ON b.flight_id = f.flight_id
    GROUP BY f.flight_id, f.flight_number
)
SELECT
    flight_id,
    flight_number,
    booking_count,
    NTILE(4) OVER (ORDER BY booking_count DESC, flight_id) AS booking_band
FROM flight_counts
ORDER BY booking_count DESC, flight_id;
