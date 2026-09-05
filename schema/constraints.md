The constraints implemented that protect my data start with the passengers table. The primary key is set to passenger id, an assigned integer, and does not rely on email or name that could be duplicated by passengers. 

The flights table uses the same construct to have an assigned flight_id for the primary key, as different flights may have the same flight number, occur on the same date, and be the same duration. 

Bookings uses a booking_id for the primary key, ensuring each bookings is unique. For foreign keys, it uses both passenger_id and flight_id. This ensures that if a passenger makes multiple bookings for the same flight, they are always truly unique bookings. 

For airports, I made the decision to use airport_id as a primary key, a system generated key, rather than rely on the name or the airport desintation code (for example BOS). Although airport names and codes are candidate keys as they are generally unique, upon research I discovered that these can change. The airport_id as a system generated primary key to avoid errors in the database if the name or code is changed by regulators in the future. 

For my junction table, flight routes, I used airport_id and flight_id as foreign keys. This creates a unique primary key (airport_id, flight_id) for each flight. This preserves the many to many relationship across airports and flights. 

Regarding the ON DELETE behavior, a few scenarios may occur: 
- A passenger requests their data is deleted and I need to comply due to GDPR or other privacy regulations. In this scenario, the passenger row would be deleted, but it would not cascade. The FK of passenger_id in the bookings table would be set to NULL so I can retain historical bookings information for audit and financial purposes. 
- An airport may close down or the airline may stop offering a specific flight, and the flight row needs to be deleted. This scenario, the removal of a flight will not cascade to bookings. The FK in the bookings table will be set to NULL with ON DELETE SET NULL. However, this would be allowed to ON DELETE CASCADE to flight_routes so that the flight_routes row is also deleted. 