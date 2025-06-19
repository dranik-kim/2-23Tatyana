-- Table to store hotel details
CREATE TABLE IF NOT EXISTS hotel.hotel (
    hotel_id SERIAL PRIMARY KEY, -- Unique identifier for each hotel
    name VARCHAR(50) NOT NULL, -- Hotel name
    address VARCHAR(50) NOT NULL, -- Hotel address
    contact VARCHAR(12) NOT NULL, -- Contact phone number
    rating SMALLINT CHECK(rating > 0) DEFAULT 0 -- Hotel rating with default value 0
);

-- Table to store countries
CREATE TABLE IF NOT EXISTS hotel.country (
    country_id SERIAL PRIMARY KEY, -- Unique identifier for each country
    name VARCHAR(50) NOT NULL -- Country name
);

-- Table to store available services at hotels
CREATE TABLE IF NOT EXISTS hotel.service (
    service_id SERIAL PRIMARY KEY, -- Unique identifier for each service
    name VARCHAR(50) NOT NULL, -- Service name
    description VARCHAR(50) NOT NULL, -- Brief description of the service
    price DECIMAL(10, 2) NOT NULL CHECK(price > 0) -- Price of the service
);

-- Table to store amenities that can be assigned to rooms
CREATE TABLE IF NOT EXISTS hotel.amenity (
    amenity_id SERIAL PRIMARY KEY, -- Unique identifier for each amenity
    name VARCHAR(50) NOT NULL, -- Amenity name
    status VARCHAR(50) NOT NULL DEFAULT 'available' -- Amenity status with default 'available'
);

-- Table to store cities with reference to their country
CREATE TABLE IF NOT EXISTS hotel.city (
    city_id SERIAL PRIMARY KEY, -- Unique city identifier
    country_id INT NOT NULL, -- Reference to country
    name VARCHAR(50) NOT NULL, -- City name
CONSTRAINT fk_country FOREIGN KEY (country_id) -- Foreign key to country table
REFERENCES hotel.country(country_id)
);

-- Table to store addresses linked to cities
CREATE TABLE IF NOT EXISTS hotel.address (
    address_id SERIAL PRIMARY KEY, -- Unique address ID
    city_id INT NOT NULL, -- Reference to city
    address VARCHAR(50) NOT NULL, -- Address line
CONSTRAINT fk_city FOREIGN KEY (city_id) -- Foreign key to city table
REFERENCES hotel.city(city_id)
);

-- Table to store different room types for each hotel
CREATE TABLE IF NOT EXISTS hotel.room_type (
    type_id SERIAL PRIMARY KEY, -- Room type ID
    hotel_id INT NOT NULL, -- Reference to hotel
    name VARCHAR(50) NOT NULL, -- Room type name (e.g. Deluxe, Suite)
    description TEXT NOT NULL, -- Detailed description of room type
    rating DECIMAL(10, 2) NOT NULL CHECK(rating > 0) DEFAULT 0,  -- Room type rating with default 0
CONSTRAINT fk_hotel FOREIGN KEY (hotel_id) -- Foreign key to hotel table
REFERENCES hotel.hotel(hotel_id)
);

-- Table to store individual rooms in hotels
CREATE TABLE IF NOT EXISTS hotel.room (
    room_id SERIAL PRIMARY KEY, -- Unique room ID
    hotel_id INT NOT NULL, -- Reference to hotel
    type_id INT NOT NULL, -- Reference to room type
    room_number SMALLINT UNIQUE NOT NULL CHECK(room_number > 100),  -- Unique room number greater than 100
    rating DECIMAL(10, 2) CHECK(rating > 0) DEFAULT 0, -- Room rating with default 0
    status VARCHAR(50) NOT NULL DEFAULT 'available', -- Room status with default 'available'
CONSTRAINT fk_hotel FOREIGN KEY (hotel_id) -- Foreign key to hotel
REFERENCES hotel.hotel(hotel_id),
CONSTRAINT fk_type FOREIGN KEY (type_id) -- Foreign key to room_type
REFERENCES hotel.room_type(type_id)
);

-- Table to store customer information
CREATE TABLE IF NOT EXISTS hotel.customer (
    customer_id SERIAL PRIMARY KEY, -- Customer unique ID
    address_id INT NOT NULL, -- Reference to customer address
    first_name VARCHAR(50) NOT NULL, -- Customer first name
    last_name VARCHAR(50) NOT NULL, -- Customer last name
    contact VARCHAR(12) NOT NULL, -- Contact number
    email VARCHAR(50) NOT NULL, -- Email address
CONSTRAINT fk_address FOREIGN KEY (address_id) -- Foreign key to address
REFERENCES hotel.address(address_id)
);

-- Table to store staff working at hotels
CREATE TABLE IF NOT EXISTS hotel.staff (
    staff_id SERIAL PRIMARY KEY, -- Staff ID
    hotel_id INT NOT NULL, -- Reference to hotel
    first_name VARCHAR(50) NOT NULL, -- Staff first name
    last_name VARCHAR(50) NOT NULL, -- Staff last name
    position VARCHAR(50) NOT NULL, -- Job position/title
    contact VARCHAR(12) NOT NULL, -- Contact phone
CONSTRAINT fk_hotel FOREIGN KEY (hotel_id) -- Foreign key to hotel
REFERENCES hotel.hotel(hotel_id)
);

-- Table to record bookings made by customers
CREATE TABLE IF NOT EXISTS hotel.booking (
    booking_id SERIAL PRIMARY KEY, -- Booking unique ID
    customer_id INT NOT NULL, -- Reference to customer
    room_id INT NOT NULL, -- Reference to room booked
    check_in_date DATE CHECK(check_in_date > '2024-01-01'), -- Check-in date, must be after Jan 1, 2024
    check_out_date DATE CHECK(check_out_date > '2024-01-01'), -- Check-out date, must be after Jan 1, 2024
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- Booking status with default 'pending'
CONSTRAINT fk_customer FOREIGN KEY (customer_id) -- Foreign key to customer
REFERENCES hotel.customer(customer_id),
CONSTRAINT fk_room FOREIGN KEY (room_id) -- Foreign key to room
REFERENCES hotel.room(room_id)
);

-- Table to record payments for bookings
CREATE TABLE IF NOT EXISTS hotel.payment (
    payment_id SERIAL PRIMARY KEY, -- Payment ID
    booking_id INT NOT NULL, -- Reference to booking
    amount DECIMAL(10, 2) NOT NULL CHECK(amount > 0), -- Payment amount
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE, -- Payment date with default to current date
    method VARCHAR(50) NOT NULL, -- Payment method (e.g. credit card, cash)
CONSTRAINT fk_booking FOREIGN KEY (booking_id) -- Foreign key to booking
REFERENCES hotel.booking(booking_id)
);

-- Table to track service requests related to bookings
CREATE TABLE IF NOT EXISTS hotel.service_request (
    request_id SERIAL PRIMARY KEY, -- Service request ID
    booking_id INT NOT NULL, -- Reference to booking
    service_id INT NOT NULL, -- Reference to service requested
    staff_id INT NOT NULL, -- Staff assigned to fulfill request
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of request, default to now
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- Status of request, default 'pending'
CONSTRAINT fk_booking FOREIGN KEY (booking_id) -- Foreign key to booking
REFERENCES hotel.booking(booking_id),
CONSTRAINT fk_service FOREIGN KEY (service_id) -- Foreign key to service
REFERENCES hotel.service(service_id),
CONSTRAINT fk_staff FOREIGN KEY (staff_id) -- Foreign key to staff
REFERENCES hotel.staff(staff_id)
);

-- Table to assign amenities to rooms
CREATE TABLE IF NOT EXISTS hotel.room_amenity (
    id SERIAL PRIMARY KEY, -- Unique ID for room amenity entry
    room_id INT NOT NULL, -- Reference to room
    amenity_id INT NOT NULL, -- Reference to amenity
CONSTRAINT fk_room FOREIGN KEY (room_id) -- Foreign key to room
REFERENCES hotel.room(room_id),
CONSTRAINT fk_amenity FOREIGN KEY (amenity_id) -- Foreign key to amenity
REFERENCES hotel.amenity(amenity_id)
);
