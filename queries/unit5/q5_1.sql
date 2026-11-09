-- 5.1a Three-table join.
-- Question: Who made each booking, which flight was booked,
-- and when was the booking made?
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


-- 5.1b Join through the junction table.
-- Question: Which flights connect to Changi Airport?
-- SIN is the airport code used for this comparison.
SELECT
    f.flight_id,
    f.flight_number,
    a.iata_code,
    a.airport_name
FROM flights f
INNER JOIN flight_routes r
    ON f.flight_id = r.flight_id
INNER JOIN airports a
    ON r.airport_id = a.airport_id
WHERE a.iata_code = 'SIN'
ORDER BY f.flight_id;


-- 5.1c Self join.
-- Question: How do flights 2 and 3 compare with other flights
-- from the same origin country?
SELECT
    f1.flight_id,
    f1.flight_number,
    f1.origin_country,
    f1.seat_capacity,
    f1.is_active,
    f2.flight_id AS comparison_id,
    f2.flight_number AS comparison_flight,
    f2.seat_capacity AS comparison_capacity,
    f2.is_active AS comparison_active
FROM flights f1
INNER JOIN flights f2
    ON f1.origin_country = f2.origin_country
   AND f1.flight_id <> f2.flight_id
WHERE f1.flight_id IN (2, 3)
ORDER BY f1.flight_id, f2.flight_id;