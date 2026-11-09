-- 5.2A.1 LEFT JOIN.
-- Question: What bookings does each flight have,
-- including flights with no bookings?
SELECT
    f.flight_id,
    f.flight_number,
    b.booking_id
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id, b.booking_id;


-- 5.2A.2 INNER JOIN.
-- Question: Which flights have matching bookings?
SELECT
    f.flight_id,
    f.flight_number,
    b.booking_id
FROM flights f
INNER JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id, b.booking_id;


-- 5.2A.3 Count unique flights in the LEFT JOIN.
-- Question: How many flights are included?
SELECT COUNT(DISTINCT f.flight_id) AS left_join_flights
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id;


-- 5.2A.4 Count unique flights in the INNER JOIN.
-- Question: How many flights have bookings?
SELECT COUNT(DISTINCT f.flight_id) AS inner_join_flights
FROM flights f
INNER JOIN bookings b
    ON f.flight_id = b.flight_id;


-- 5.2A.5 Count excluded flights.
-- Question: How many flights does the INNER JOIN leave out?
SELECT COUNT(*) AS excluded_flights
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
WHERE b.booking_id IS NULL;


-- 5.2A.6 Identify excluded flights.
-- Question: Which flights have no bookings?
SELECT
    f.flight_id,
    f.flight_number,
    f.is_active
FROM flights f
LEFT JOIN bookings b
    ON f.flight_id = b.flight_id
WHERE b.booking_id IS NULL
ORDER BY f.flight_id;


-- 5.2B.1 RIGHT JOIN.
-- Question: Does reversing the tables return the same
-- records as the LEFT JOIN?
-- Compare this output with 5.2A.1 in the same order.
SELECT
    f.flight_id,
    f.flight_number,
    b.booking_id
FROM bookings b
RIGHT JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY f.flight_id, b.booking_id;


-- 5.2B.2 FULL OUTER JOIN.
-- Question: Are there unmatched flights or unmatched bookings?
SELECT
    f.flight_id,
    f.flight_number,
    b.booking_id,
    b.flight_id AS booking_flight_id
FROM flights f
FULL OUTER JOIN bookings b
    ON f.flight_id = b.flight_id
ORDER BY f.flight_id, b.booking_id;


-- 5.2C.1 NOT EXISTS.
-- Question: Which flights have no bookings in this dataset?
SELECT
    f.flight_id,
    f.flight_number
FROM flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.flight_id = f.flight_id
)
ORDER BY f.flight_id;


-- 5.2C.2 EXCEPT.
-- Question: Which flights remain after removing
-- the flights that have bookings?
-- Compare these rows with the NOT EXISTS result.
SELECT flight_id, flight_number
FROM flights

EXCEPT

SELECT f.flight_id, f.flight_number
FROM flights f
INNER JOIN bookings b
    ON f.flight_id = b.flight_id

ORDER BY flight_id;