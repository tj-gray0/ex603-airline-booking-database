-- 5.3A.1 CROSS JOIN.
-- Question: What are all possible flight and airport combinations?
-- These are possible combinations, not the actual routes.
SELECT
    f.flight_id,
    f.flight_number,
    a.iata_code
FROM flights f
CROSS JOIN airports a
ORDER BY f.flight_id, a.iata_code;


-- 5.3A.2 Check the multiplication.
-- Question: Does the CROSS JOIN count equal the number
-- of flights multiplied by the number of airports?
SELECT
    (SELECT COUNT(*) FROM flights) AS flight_count,
    (SELECT COUNT(*) FROM airports) AS airport_count,

    (SELECT COUNT(*) FROM flights)
        * (SELECT COUNT(*) FROM airports) AS expected_rows,

    (SELECT COUNT(*)
     FROM flights
     CROSS JOIN airports) AS actual_rows;


-- 5.3B Execution plan.
-- Question: How does PostgreSQL plan to join bookings,
-- passengers, and flights?
EXPLAIN
SELECT
    b.booking_id,
    p.passenger_name,
    f.flight_number,
    b.booked_at
FROM bookings b
INNER JOIN passengers p
    ON b.passenger_id = p.passenger_id
INNER JOIN flights f
    ON b.flight_id = f.flight_id
ORDER BY b.booking_id;