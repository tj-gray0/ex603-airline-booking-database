Passengers 
- passenger_id INT (PK)
- name VARCHAR
- email VARCHAR, NOT NULL, UNIQUE 
- birth_date DATE
- address VARCHAR

Passengers(passenger_id, name, email, birth_date, address) 

Flights 
- flight_id INT (PK)
- flight_number VARCHAR
- flight_date DATE
- duration INT
- is_active BOOLEAN

Flights(flight_id, flight_number, flight_date, duration, is_active)

Bookings 
- booking_id VARCHAR (PK)
- passenger_id INT (FK)
- flight_id INT (FK)
- fare_paid INT
- booking_date DATE

Bookings(booking_id, passenger_id, flight_id, fare_paid, booking_date)

Airports 
- airport_id VARCHAR (PK)
- airport_name VARCHAR
- airport_code VARCHAR
- airport_city VARCHAR

Airports(airport_id, airport_name, airport_code, airport_city)

Flight_routes
- flight_id INT (FK)
- airport_id VARCHAR (FK)
- airport_role VARCHAR
- (flight_id, airport_id) PK 

FLIGHTS M --- N AIRPORTS