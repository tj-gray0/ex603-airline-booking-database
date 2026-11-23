-- Task 6.3A: What are the three highest-fare bookings for each flight?
-- If fares tie at third place, the lower booking ID gets the spot
-- so the review list has at most three bookings per flight.
WITH ranked_fares AS (
    SELECT
        flight_id,
        booking_id,
        fare_paid,
        ROW_NUMBER() OVER (
            PARTITION BY flight_id ORDER BY fare_paid DESC, booking_id
        ) AS fare_rank,
        FIRST_VALUE(fare_paid) OVER (
            PARTITION BY flight_id ORDER BY fare_paid DESC, booking_id
        ) AS highest_fare
    FROM bookings
)
SELECT flight_id, fare_rank, booking_id, fare_paid, highest_fare
FROM ranked_fares
WHERE fare_rank <= 3
ORDER BY flight_id, fare_rank;

-- Task 6.3B: How did the passenger no-show rate change by booking month?
WITH monthly_rates AS (
    SELECT
        DATE_TRUNC('month', booked_at)::date AS booking_month,
        COUNT(*) AS total_bookings,
        SUM(CASE WHEN cancellation_reason = 'Passenger no show' THEN 1 ELSE 0 END)
            AS no_show_bookings,
        100.0 * SUM(CASE WHEN cancellation_reason = 'Passenger no show' THEN 1 ELSE 0 END)
            / COUNT(*) AS no_show_rate
    FROM bookings
    GROUP BY DATE_TRUNC('month', booked_at)::date
),
monthly_comparison AS (
    SELECT
        booking_month,
        total_bookings,
        no_show_bookings,
        no_show_rate,
        LAG(booking_month) OVER (ORDER BY booking_month) AS previous_month,
        LAG(no_show_rate) OVER (ORDER BY booking_month) AS previous_rate
    FROM monthly_rates
)
SELECT
    booking_month,
    total_bookings,
    no_show_bookings,
    ROUND(no_show_rate, 2) AS no_show_rate_pct,
    previous_month,
    COALESCE(booking_month > previous_month + INTERVAL '1 month', FALSE) AS missing_months,
    CASE WHEN booking_month = previous_month + INTERVAL '1 month'
        THEN ROUND(100.0 * (no_show_rate - previous_rate) / NULLIF(previous_rate, 0), 2)
    END AS rate_pct_change
FROM monthly_comparison
ORDER BY booking_month;
