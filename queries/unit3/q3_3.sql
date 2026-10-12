-- 3.3.1 First version: NOT IN subquery.
-- Question: Which passengers have no recorded passenger no-show bookings?
SELECT passenger_id, passenger_name
FROM passengers
WHERE passenger_id NOT IN (
    SELECT passenger_id
    FROM bookings
    WHERE cancellation_reason = 'Passenger no show'
)
ORDER BY passenger_id;


-- 3.3.2 Second version: CTE.
-- Question: Which passengers have no recorded passenger no-show bookings?
-- First identify the passengers with no-show bookings.
WITH no_show_passengers AS (
    SELECT passenger_id
    FROM bookings
    WHERE cancellation_reason = 'Passenger no show'
)
SELECT passenger_id, passenger_name
FROM passengers
WHERE passenger_id NOT IN (
    SELECT passenger_id
    FROM no_show_passengers
)
ORDER BY passenger_id;


-- 3.3.3 Third version: NOT EXISTS.
-- Question: Which passengers have no recorded passenger no-show bookings?
-- Check whether a matching no-show booking exists for each passenger.
SELECT p.passenger_id, p.passenger_name
FROM passengers p
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.passenger_id = p.passenger_id
      AND b.cancellation_reason = 'Passenger no show'
)
ORDER BY p.passenger_id;


-- 3.3.4 Compare the actual result rows.
-- Question: Are there any differences between the three versions?
-- EXCEPT returns rows in the first result that are missing
-- from the second. Check both directions for each comparison.
WITH no_show_passengers AS (
    SELECT passenger_id
    FROM bookings
    WHERE cancellation_reason = 'Passenger no show'
),
first_result AS (
    SELECT passenger_id, passenger_name
    FROM passengers
    WHERE passenger_id NOT IN (
        SELECT passenger_id
        FROM bookings
        WHERE cancellation_reason = 'Passenger no show'
    )
),
second_result AS (
    SELECT passenger_id, passenger_name
    FROM passengers
    WHERE passenger_id NOT IN (
        SELECT passenger_id
        FROM no_show_passengers
    )
),
third_result AS (
    SELECT p.passenger_id, p.passenger_name
    FROM passengers p
    WHERE NOT EXISTS (
        SELECT 1
        FROM bookings b
        WHERE b.passenger_id = p.passenger_id
          AND b.cancellation_reason = 'Passenger no show'
    )
)
SELECT
    (SELECT COUNT(*) FROM (
        SELECT * FROM first_result
        EXCEPT
        SELECT * FROM second_result
    ) AS differences) AS first_minus_second,

    (SELECT COUNT(*) FROM (
        SELECT * FROM second_result
        EXCEPT
        SELECT * FROM first_result
    ) AS differences) AS second_minus_first,

    (SELECT COUNT(*) FROM (
        SELECT * FROM first_result
        EXCEPT
        SELECT * FROM third_result
    ) AS differences) AS first_minus_third,

    (SELECT COUNT(*) FROM (
        SELECT * FROM third_result
        EXCEPT
        SELECT * FROM first_result
    ) AS differences) AS third_minus_first;


-- 3.3.5 A condition that would break equivalence.
-- If bookings.passenger_id allowed NULL and a no-show booking
-- contained a NULL passenger_id, both NOT IN versions would
-- return no rows. NOT EXISTS would still return passengers
-- without a matching no-show booking.
-- The supplied dataset prevents this with NOT NULL.