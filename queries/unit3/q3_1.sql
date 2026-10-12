-- 3.1a Active flights with at least 180 seats.
-- Question: Which active flights have the largest seat capacity?
-- Requirements: SELECT, WHERE, ORDER BY, LIMIT.
SELECT flight_id, flight_number, seat_capacity
FROM flights
WHERE is_active = TRUE
  AND seat_capacity >= 180
ORDER BY seat_capacity DESC, flight_id
LIMIT 10;


-- 3.1b All booking statuses.
-- Question: What different booking statuses are in the data?
-- Requirement: DISTINCT.
SELECT DISTINCT booking_status
FROM bookings
ORDER BY booking_status;


-- 3.1c Numeric range filter.
-- Question: Which bookings have fares between 10 and 20?
-- Requirements: WHERE, BETWEEN.
SELECT booking_id, passenger_id, fare_paid
FROM bookings
WHERE fare_paid BETWEEN 10 AND 20
ORDER BY fare_paid, booking_id;


-- 3.1d Filter using a list.
-- Question: Which bookings are cancelled or disputed?
-- Requirements: WHERE, IN.
SELECT booking_id, booking_status, cancellation_reason
FROM bookings
WHERE booking_status IN ('cancelled', 'disputed')
ORDER BY booking_id;


-- 3.1e Find flights using a text pattern.
-- Question: Which flight numbers start with VN21?
-- Requirement: LIKE.
SELECT flight_id, flight_number
FROM flights
WHERE flight_number LIKE 'VN21%'
ORDER BY flight_number;


-- 3.1f Identify missing reasons and display a useful label.
-- Question: Which bookings have no cancellation reason recorded?
-- Requirements: IS NULL, COALESCE.
SELECT booking_id,
       booking_status,
       COALESCE(cancellation_reason, 'No reason provided') AS reason
FROM bookings
WHERE cancellation_reason IS NULL
ORDER BY booking_id;


-- 3.1g Calculated columns and plain-language categories.
-- Question: What is each booking's fare per kilogram of baggage,
-- and which fare category does it fall into?
-- Requirements: calculated column, CASE.
SELECT booking_id,
       fare_paid,
       bags_kg,
       ROUND(fare_paid / bags_kg, 2) AS fare_per_bag_kg,
       CASE
           WHEN fare_paid = 0 THEN 'No fare paid'
           WHEN fare_paid < 20 THEN 'Under 20'
           ELSE '20 or more'
       END AS fare_category
FROM bookings
ORDER BY booking_id;