-- =================================================================
-- EX603 Assignment 2 — schema.sql
-- Theme: Airline booking
-- Author: TJ Gray
-- Target: PostgreSQL 14+
-- =================================================================

-- Reset in reverse creation order.
DROP TABLE IF EXISTS flight_routes CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS airports CASCADE;
DROP TABLE IF EXISTS flights CASCADE;
DROP TABLE IF EXISTS passengers CASCADE;

-- 1. passengers: root table; booking references it later.
CREATE TABLE passengers (
    passenger_id INTEGER GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL,
    birth_date DATE,
    address VARCHAR(300),
    CONSTRAINT pk_passengers PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passengers_email UNIQUE (email)
);

-- 2. flights: root table; flight_id identifies one scheduled occurrence.
CREATE TABLE flights (
    flight_id INTEGER GENERATED ALWAYS AS IDENTITY,
    flight_number VARCHAR(12) NOT NULL,
    flight_date DATE NOT NULL,
    duration_min INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_flights PRIMARY KEY (flight_id),
    CONSTRAINT chk_flights_duration_positive CHECK (duration_min > 0)
);

-- 3. airports: root table; the code can change without changing identity.
CREATE TABLE airports (
    airport_id INTEGER GENERATED ALWAYS AS IDENTITY,
    airport_name VARCHAR(160) NOT NULL,
    airport_code VARCHAR(8) NOT NULL,
    airport_city VARCHAR(120) NOT NULL,
    CONSTRAINT pk_airports PRIMARY KEY (airport_id),
    CONSTRAINT uq_airports_code UNIQUE (airport_code)
);

-- 4. bookings: depends on passengers and flights.
CREATE TABLE bookings (
    booking_id INTEGER GENERATED ALWAYS AS IDENTITY,
    passenger_id INTEGER,
    flight_id INTEGER,
    fare_paid NUMERIC(10,2) NOT NULL,
    booking_date DATE NOT NULL,
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),
    CONSTRAINT fk_bookings_passenger
        FOREIGN KEY (passenger_id)
        REFERENCES passengers (passenger_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_bookings_flight
        FOREIGN KEY (flight_id)
        REFERENCES flights (flight_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_bookings_fare_nonnegative CHECK (fare_paid >= 0)
);

-- 5. flight_routes: depends on flights and airports; each row records
--    one airport's role for one flight.
CREATE TABLE flight_routes (
    flight_id INTEGER NOT NULL,
    airport_id INTEGER NOT NULL,
    airport_role VARCHAR(12) NOT NULL,
    CONSTRAINT pk_flight_routes PRIMARY KEY (flight_id, airport_id),
    CONSTRAINT fk_flight_routes_flight
        FOREIGN KEY (flight_id)
        REFERENCES flights (flight_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_flight_routes_airport
        FOREIGN KEY (airport_id)
        REFERENCES airports (airport_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_flight_routes_role
        CHECK (airport_role IN ('departure', 'arrival'))
);