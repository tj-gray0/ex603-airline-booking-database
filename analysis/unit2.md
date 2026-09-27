# Unit 2 Analysis 

## Foreign keys and ON DELETE behavior

The foreign keys in my schema use the following ON DELETE choices:

- bookings.passenger_id references passengers.passenger_id with ON DELETE SET NULL
- bookings.flight_id references flights.flight_id with ON DELETE SET NULL
- flight_routes.flight_id references flights.flight_id with ON DELETE CASCADE
- flight_routes.airport_id references airports.airport_id with ON DELETE CASCADE

The first choice was to retain bookings when a passenger is removed. There may be a scenario where a passenger requests their information be deleted, but the booking record is still useful for financial reporting. In this case, the passenger row is deleted and the passenger_id in bookings is set to NULL. The fare paid and booking date would remain. If I used ON DELETE CASCADE here, I would also lose the bookings associated with that passenger. The passenger_id in bookings allows NULL for this reason.

For flights, I kept the is_active flag from my initial design. If the airline stops offering a flight, the preferred approach would be to set is_active to FALSE and keep the flight information. If the flight row does need to be deleted, the flight_id in bookings is set to NULL. This protects the booking records from being deleted along with the flight. However, the same deletion will cascade to flight_routes, since those rows describe the airports associated with a flight that no longer exists. Using RESTRICT on that relationship would mean removing the route rows separately before deleting the flight.

For airports, I selected ON DELETE CASCADE to remove the associated flight_routes rows. An airport may close or be removed from the airline's system. The cascade is limited to the junction table, so it does not remove the flights or bookings. The alternative, ON DELETE RESTRICT, would prevent deleting an airport while any flight_routes row still references it.

One trade-off with these choices is that keeping a booking row does not keep all of its original information. If flight_id is set to NULL, that booking can no longer be joined to the flight. Deleting an airport also removes its historical route associations. I can still retain the fare and booking date, but some route reporting would be lost. This is part of why keeping flights with is_active set to FALSE is useful.

## CHECK constraints

The flights table uses chk_flights_duration_positive, which checks that duration_min is greater than zero. A flight with a negative duration or a duration of zero would be invalid data. Without this check, a typing error or an incorrect import could create that record. The duration is also required with NOT NULL.

The bookings table uses chk_bookings_fare_nonnegative, which checks that fare_paid is greater than or equal to zero. A negative fare could be entered by mistake, for example if an imported amount had the wrong sign. This design allows a fare of zero, but rejects negative amounts. I also used NUMERIC(10,2) for fare_paid so the amount is stored with two decimal places.

The flight_routes table uses chk_flight_routes_role to limit airport_role to departure or arrival. This is needed because the role is a text value, and without a check someone could enter depart, origin, or another value that means the same thing. That would make filtering by airport_role inconsistent. The role belongs in the junction table because the same airport can be a departure airport for one flight and an arrival airport for another.


## Primary keys and UNIQUE constraints

I kept the system generated primary keys from my initial reasoning. Names can be duplicated, email addresses can change, and the same flight number can be used for flights on different dates. The assigned ID lets each record keep its identity when other information changes.

For flight_routes, the primary key is the combination of flight_id and airport_id. Both are also foreign keys. This allows many flights to be associated with many airports, while preventing the same flight and airport pair from being entered twice. Passenger email and airport code also have UNIQUE constraints, but these are separate from the primary keys.

## Changes from the Unit 1 ERD

The schema still has the original five tables. The main changes are in the types and constraints that needed to be decided when writing the SQL:

- booking_id and airport_id use generated INTEGER keys. My Unit 1 write-up described assigned keys, but the original ERD showed these as VARCHAR. The airport_id in flight_routes also uses INTEGER to match.
- fare_paid uses NUMERIC(10,2), and duration was renamed duration_min so the unit is clear.
- passenger_id and flight_id in bookings allow NULL to support the ON DELETE SET NULL choices.
- The SQL defines the text lengths, NOT NULL columns, defaults, and named constraints that were not all specified in the original ERD.