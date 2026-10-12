-- 3.2A.1 Broken filter.
-- Question: Which bookings have a reason other than Passenger no show?
-- Problem: This also excludes bookings with a NULL reason.
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE cancellation_reason <> 'Passenger no show'
ORDER BY booking_id;


-- 3.2A.2 Compare the counts.
-- Question: Do the bookings with other reasons and the passenger
-- no-show bookings account for every booking?
SELECT
    (SELECT COUNT(*)
     FROM bookings
     WHERE cancellation_reason <> 'Passenger no show')
        AS other_reason_count,

    (SELECT COUNT(*)
     FROM bookings
     WHERE cancellation_reason = 'Passenger no show')
        AS no_show_count,

    (SELECT COUNT(*)
     FROM bookings)
        AS total_bookings;


-- 3.2A.3 Count the missing rows.
-- Question: How many bookings were left out of both counts?
SELECT COUNT(*) AS missing_reason_count
FROM bookings
WHERE cancellation_reason IS NULL;


-- 3.2A.4 Repair the filter.
-- Question: Which bookings do not have a recorded passenger no-show reason, including bookings where the reason is missing?
-- include NULL explicitly.
SELECT booking_id,
       booking_status,
       COALESCE(cancellation_reason, 'No reason provided') AS reason
FROM bookings
WHERE cancellation_reason <> 'Passenger no show'
   OR cancellation_reason IS NULL
ORDER BY booking_id;


-- 3.2A.5 Check the repaired count.
-- Question: Does the repaired count plus the no-show count now account for every booking?
SELECT
    (SELECT COUNT(*)
     FROM bookings
     WHERE cancellation_reason <> 'Passenger no show'
        OR cancellation_reason IS NULL)
        AS repaired_count,

    (SELECT COUNT(*)
     FROM bookings
     WHERE cancellation_reason = 'Passenger no show')
        AS no_show_count,

    (SELECT COUNT(*)
     FROM bookings)
        AS total_bookings;


-- 3.2B.1 Broken alias query.
-- Question: Which bookings have a fare per kilogram above 2?
-- This query intentionally produces an error.
SELECT booking_id,
       fare_paid,
       bags_kg,
       fare_paid / bags_kg AS fare_per_bag_kg
FROM bookings
WHERE fare_per_bag_kg > 2;


-- 3.2B.2 First repair: repeat the expression.
-- Question: Which bookings have a fare per kilogram above 2?
SELECT booking_id,
       fare_paid,
       bags_kg,
       fare_paid / bags_kg AS fare_per_bag_kg
FROM bookings
WHERE fare_paid / bags_kg > 2
ORDER BY booking_id;


-- 3.2B.3 Second repair: use a CTE.
-- Question: Which bookings have a fare per kilogram above 2?
-- The CTE makes the alias available to the outer query.
WITH booking_fares AS (
    SELECT booking_id,
           fare_paid,
           bags_kg,
           fare_paid / bags_kg AS fare_per_bag_kg
    FROM bookings
)
SELECT booking_id, fare_paid, bags_kg, fare_per_bag_kg
FROM booking_fares
WHERE fare_per_bag_kg > 2
ORDER BY booking_id;