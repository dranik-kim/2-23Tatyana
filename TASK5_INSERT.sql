-- 1. Table to store hotel details+
CREATE TABLE IF NOT EXISTS hotel.hotel (
    hotel_id SERIAL PRIMARY KEY, -- Unique identifier for each hotel
    name VARCHAR(50) NOT NULL, -- Hotel name
    address VARCHAR(50) NOT NULL, -- Hotel address
    contact VARCHAR(12) NOT NULL, -- Contact phone number
    rating SMALLINT CHECK(rating > 0) DEFAULT 0 -- Hotel rating with default value 0
);

-- 2. Table to store countries+
CREATE TABLE IF NOT EXISTS hotel.country (
    country_id SERIAL PRIMARY KEY, -- Unique identifier for each country
    name VARCHAR(50) NOT NULL -- Country name
);

-- 3. Table to store available services at hotels+
CREATE TABLE IF NOT EXISTS hotel.service (
    service_id SERIAL PRIMARY KEY, -- Unique identifier for each service
    name VARCHAR(50) NOT NULL, -- Service name
    description VARCHAR(50) NOT NULL, -- Brief description of the service
    price DECIMAL(10, 2) NOT NULL CHECK(price > 0) -- Price of the service
);

-- 4. Table to store amenities that can be assigned to rooms
CREATE TABLE IF NOT EXISTS hotel.amenity (
    amenity_id SERIAL PRIMARY KEY, -- Unique identifier for each amenity
    name VARCHAR(50) NOT NULL, -- Amenity name
    status VARCHAR(50) NOT NULL DEFAULT 'available' -- Amenity status with default 'available'
);

-- 5. Table to store cities with reference to their country
CREATE TABLE IF NOT EXISTS hotel.city (
    city_id SERIAL PRIMARY KEY, -- Unique city identifier
    country_id INT NOT NULL, -- Reference to country
    name VARCHAR(50) NOT NULL, -- City name
CONSTRAINT fk_country FOREIGN KEY (country_id) -- Foreign key to country table
REFERENCES hotel.country(country_id)
);

-- 6. Table to store addresses linked to cities
CREATE TABLE IF NOT EXISTS hotel.address (
    address_id SERIAL PRIMARY KEY, -- Unique address ID
    city_id INT NOT NULL, -- Reference to city
    address VARCHAR(50) NOT NULL, -- Address line
CONSTRAINT fk_city FOREIGN KEY (city_id) -- Foreign key to city table
REFERENCES hotel.city(city_id)
);

-- 7. Table to store different room types for each hotel
CREATE TABLE IF NOT EXISTS hotel.room_type (
    type_id SERIAL PRIMARY KEY, -- Room type ID
    hotel_id INT NOT NULL, -- Reference to hotel
    name VARCHAR(50) NOT NULL, -- Room type name (e.g. Deluxe, Suite)
    description TEXT NOT NULL, -- Detailed description of room type
    rating DECIMAL(10, 2) NOT NULL CHECK(rating > 0) DEFAULT 0,  -- Room type rating with default 0
CONSTRAINT fk_hotel FOREIGN KEY (hotel_id) -- Foreign key to hotel table
REFERENCES hotel.hotel(hotel_id)
);

-- 8. Table to store individual rooms in hotels+
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

-- 9. Table to store customer information+
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

-- 10. Table to store staff working at hotels
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

-- 11. Table to record bookings made by customers
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

-- 12. Table to record payments for bookings
CREATE TABLE IF NOT EXISTS hotel.payment (
    payment_id SERIAL PRIMARY KEY, -- Payment ID
    booking_id INT NOT NULL, -- Reference to booking
    amount DECIMAL(10, 2) NOT NULL CHECK(amount > 0), -- Payment amount
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE, -- Payment date with default to current date
    method VARCHAR(50) NOT NULL, -- Payment method (e.g. credit card, cash)
CONSTRAINT fk_booking FOREIGN KEY (booking_id) -- Foreign key to booking
REFERENCES hotel.booking(booking_id)
);

-- 13. Table to track service requests related to bookings
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

-- 14. Table to assign amenities to rooms
CREATE TABLE IF NOT EXISTS hotel.room_amenity (
    id SERIAL PRIMARY KEY, -- Unique ID for room amenity entry
    room_id INT NOT NULL, -- Reference to room
    amenity_id INT NOT NULL, -- Reference to amenity
CONSTRAINT fk_room FOREIGN KEY (room_id) -- Foreign key to room
REFERENCES hotel.room(room_id),
CONSTRAINT fk_amenity FOREIGN KEY (amenity_id) -- Foreign key to amenity
REFERENCES hotel.amenity(amenity_id)
);

-- INSERTING DATA

-- 1. Table hotels
WITH new_hotel AS (
	SELECT 
		'Sunset Inn' AS name, 
		'123 Sunset Blvd' AS address, 
		'555-1234' AS contact, 
		4.3 AS rating
	UNION ALL 
	SELECT 
		'Mariott Hotel', 
		'456 Ocean Dr', 
		'555-5678', 
		4.6
	UNION ALL
	SELECT 
		'Hilton Hotel', 
		'789 Central Ave',
		'555-8765', 
		4.7
	UNION ALL 
	SELECT 
		'Grand Hyatt Incheon', 
		'321 Airport Rd', 
		'555-4321', 
		4.5
	UNION ALL 
	SELECT 
		'InterContinental Hotels', 
		'654 Embassy St', 
		'555-2468', 
		4.4
	UNION ALL 
	SELECT 
		'Four Seasons Hotel', 
		'987 Luxury Ln', 
		'555-1357', 
		4.8
),
inserted_hotels AS (
	INSERT INTO hotel.hotel (name, address, contact, rating)
	SELECT name, address, contact, rating
	FROM new_hotel nh
	WHERE NOT EXISTS (
		SELECT 1 FROM hotel.hotel h WHERE lower(h.name) = lower(nh.name)
	)
	RETURNING hotel_id, name
)
SELECT * FROM inserted_hotels;

-- 2. Table countries
WITH new_country AS (
    SELECT 'Russia' AS name
    UNION ALL 
    SELECT 'Kazakhstan'
    UNION ALL 
    SELECT 'Italy'
    UNION ALL 
    SELECT 'Spain'
    UNION ALL 
    SELECT 'USA'
    UNION ALL 
    SELECT 'Uzbekistan'
),
inserted_countries AS (
    INSERT INTO hotel.country (name)
    SELECT name
    FROM new_country nc 
    WHERE NOT EXISTS (
        SELECT 1 FROM hotel.country c WHERE lower(c.name) = lower(nc.name)
    )
    RETURNING country_id, name
)
SELECT * FROM inserted_countries;

-- 3. Table service
WITH new_service AS (
    SELECT 'Room Cleaning' AS name, 
           1 AS hotel_id, 
           'Daily room cleaning service' AS description, 
           15.00 AS price
    UNION ALL
    SELECT 'Laundry', 1, 'Laundry service for guests', 25.00
    UNION ALL
    SELECT 'Airport Shuttle', 1, 'Transport to/from the airport', 40.00
    UNION ALL
    SELECT 'Spa Treatment', 1, 'Relaxing massage and spa services', 80.00
    UNION ALL
    SELECT 'Breakfast Buffet', 1, 'All-you-can-eat morning buffet', 20.00
),
inserted_service AS (
    INSERT INTO hotel.service (name, description, price)
    SELECT ns.name, ns.description, ns.price
    FROM new_service ns
    WHERE NOT EXISTS (
        SELECT 1 
        FROM hotel.service s 
        WHERE lower(s.name) = lower(ns.name)
    )
    RETURNING service_id, name, description, price
)
SELECT * FROM inserted_service;

-- 4. Table amenities
WITH new_amenity AS (
	SELECT 'Toiletries' AS name, 'Included' AS status
	UNION ALL
	SELECT 'Free Breakfast', 'Not included'
	UNION ALL
	SELECT 'Massage', 'Included'
	UNION ALL 
	SELECT 'Gaming station', 'Not included'
),
inserted_amenity AS (
	INSERT INTO hotel.amenity (name, status)
	SELECT na.name, na.status
	FROM new_amenity na
	WHERE NOT EXISTS (
		SELECT 1
		FROM hotel.amenity a
		WHERE lower(a.name) = lower(na.name)
	)
	RETURNING amenity_id, name
)
SELECT * FROM inserted_amenity;

-- 5. Table cities
WITH new_city AS (
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'russia') AS country_id,
		'Moscow' AS name
	UNION ALL 
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'kazakhstan'),
		'Astana'
	UNION ALL 
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'italy'),
		'Rome'
	UNION ALL
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'spain'),
		'Mexico'
	UNION ALL 
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'usa'),
		'Washington'
	UNION ALL
	SELECT 
		(SELECT country_id FROM hotel.country WHERE lower(name) = 'uzbekistan'),
		'Tashkent'
),
inserted_city AS (
	INSERT INTO hotel.city (country_id, name)
	SELECT country_id, name
	FROM new_city nci
	WHERE NOT EXISTS (
		SELECT 1 
		FROM hotel.city ci 
		WHERE lower(ci.name) = lower(nci.name)
	)
	RETURNING city_id, name
)
SELECT * FROM inserted_city;

-- 6. Table addresses
WITH new_address AS (
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'moscow') AS city_id,
		'123 Red Square' AS address,
		1 AS address_id
	UNION ALL
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'astana'),
		'456 Nazarbayev Ave',
		2
	UNION ALL
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'rome'),
		'789 Colosseum Rd',
		3
	UNION ALL
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'mexico'),
		'321 Sun St',
		4
	UNION ALL
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'washington'),
		'654 Capitol Hill',
		5
	UNION ALL
	SELECT 
		(SELECT city_id FROM hotel.city WHERE lower(name) = 'tashkent'),
		'987 Independence Sq',
		6
),
inserted_address AS (
	INSERT INTO hotel.address (city_id, address, address_id)
	SELECT city_id, address, address_id
	FROM new_address na
	WHERE NOT EXISTS (
		SELECT 1 
		FROM hotel.address a 
		WHERE lower(a.address) = lower(na.address)
		  AND a.city_id = na.city_id
	)
	RETURNING address_id, city_id, address, address_id
)
SELECT * FROM inserted_address;

-- 7. Table room_types
WITH new_room_type AS (
	SELECT 
		(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'sunset inn' LIMIT 1) AS hotel_id,
		'Standard' AS name,
		'Basic room with standard amenities' AS description,
		3.5 AS rating
	UNION ALL
	SELECT 
		(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'mariott hotel' LIMIT 1),
		'Deluxe',
		'Spacious room with premium amenities and views',
		5.0
),
inserted_room_type AS (
	INSERT INTO hotel.room_type (name, hotel_id, description, rating)
	SELECT name, hotel_id, description, rating
	FROM new_room_type nrt
	WHERE NOT EXISTS (
		SELECT 1 
		FROM hotel.room_type rt
		WHERE rt.hotel_id = nrt.hotel_id AND lower(rt.name) = lower(nrt.name)
	)
	RETURNING type_id, name, hotel_id
)
SELECT * FROM inserted_room_type;

-- 8. Table rooms
WITH new_room AS (
    SELECT 
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'sunset inn') AS hotel_id,
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'standard') AS type_id,
        1 AS room_id,
        105 AS room_number,
        4.5 AS rating,
        'available' AS status
    UNION ALL
    SELECT 
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'sunset inn'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'deluxe'),
        2,
        213,
        4.6,
        'available'
    UNION ALL
    SELECT 
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'mariott hotel'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'deluxe'),
        3,
        120,
        5.0,
        'unavailable'
    UNION ALL 
    SELECT
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'mariott hotel'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'standard'),
        4,
        109,
        4.2,
        'unavailable'
    UNION ALL
    SELECT
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'hilton hotel'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'deluxe'),
        5,
        116,
        5.0,
        'unavailable'
    UNION ALL
    SELECT
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'hilton hotel'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'standard'),
        6,
        101,
        4.5,
        'available'
    UNION ALL
    SELECT 
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'grand hyatt incheon'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'standard'),
        7,
        201,
        3.6,
        'available'
    UNION ALL
    SELECT 
        (SELECT hotel_id FROM hotel.hotel WHERE lower("name") = 'grand hyatt incheon'),
        (SELECT type_id FROM hotel.room_type WHERE lower("name") = 'deluxe'),
        7,
        215,
        5.0,
        'unavailable'
),
inserted_room AS (
    INSERT INTO hotel.room (hotel_id, type_id, room_number, rating, status)
    SELECT hotel_id, type_id, room_number, rating, status
    FROM new_room nr
    WHERE hotel_id IS NOT NULL AND type_id IS NOT NULL
      AND NOT EXISTS (
        SELECT 1 
        FROM hotel.room r 
        WHERE r.hotel_id = nr.hotel_id AND r.room_number = nr.room_number
    )
    RETURNING room_id, hotel_id, room_number
)
SELECT * FROM inserted_room;

-- 9. Table customers
WITH new_customer AS (
    SELECT 'Adelya' AS first_name, 'Kalidullina' AS last_name, '87771402702' AS contact, 'adelya@mail.ru' AS email, 1 AS address_id
    UNION ALL
    SELECT 'Tanya', 'Kim', '87771541415', 'tanya@mail.ru', 2
    UNION ALL
    SELECT 'Lunara', 'Bolat', '87753403301', 'lunara@mail.ru', 3
    UNION ALL
    SELECT 'Assylai', 'Tynys', '87728571222', 'assylai@mail.ru', 4
    UNION ALL
    SELECT 'Sabina', 'Kyssaiyn', '87759834599', 'sabina@mail.ru', 5
),
inserted_customer AS (
    INSERT INTO hotel.customer (first_name, last_name, contact, email, address_id)
    SELECT first_name, last_name, contact, email, address_id
    FROM new_customer nc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM hotel.customer c
        WHERE c.email = nc.email OR c.contact = nc.contact
    )
    RETURNING customer_id, first_name, last_name, contact, email, address_id
)
SELECT * FROM inserted_customer;

-- 10. Table staff
WITH new_staff AS (
    SELECT 
    	'Aida' AS first_name, 
    	'Sapi' AS last_name, 
    	'Manager' AS position, 
    	'87762363289' AS contact,
    	(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'sunset inn') AS hotel_id
    UNION ALL
    SELECT 
    	'Asylzada', 'Sarbalina', 'Receptionist', '87704367292',
    	(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'mariott hotel')
    UNION ALL
    SELECT 
    	'Serik', 'Nauryzbaev', 'Housekeeping', '87795431213',
    	(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'sunset inn')
    UNION ALL
    SELECT 
    	'Daniyar', 'Tukenov', 'Housekeeping', '87754778042',
    	(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'mariott hotel')
    UNION ALL
    SELECT 
    	'Ruslan', 'Tauken', 'Chef', '87016253039',
    	(SELECT hotel_id FROM hotel.hotel WHERE lower(name) = 'sunset inn')
),
inserted_staff AS (
    INSERT INTO hotel.staff (first_name, last_name, position, contact, hotel_id)
    SELECT ns.first_name, ns.last_name, ns.position, ns.contact, ns.hotel_id
    FROM new_staff ns
    WHERE NOT EXISTS (
        SELECT 1 
        FROM hotel.staff s
        WHERE s.contact = ns.contact
    )
    RETURNING staff_id, first_name, last_name, position, contact, hotel_id
)
SELECT * FROM inserted_staff;

-- 11. Table bookings
WITH new_booking AS (
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Adelya') AS customer_id,
    	7 AS room_id,
    	DATE '2025-06-01' AS check_in_date,
    	DATE '2025-06-02' AS check_out_date,
    	'Confirmed' AS status
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Tanya'),
    	2, DATE '2025-06-03', DATE '2025-06-05', 'Checked-in'
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Lunara'),
    	4, DATE '2025-06-02', DATE '2025-06-03', 'Confirmed'
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Assylai'),
    	9, DATE '2025-06-05', DATE '2025-06-06', 'Confirmed'
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Sabina'),
    	5, DATE '2025-06-08', DATE '2025-06-09', 'Checked-in'
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Tanya'),
    	8, DATE '2025-06-10', DATE '2025-06-12', 'Confirmed'
    UNION ALL
    SELECT 
    	(SELECT customer_id FROM hotel.customer WHERE first_name = 'Lunara'),
    	3, DATE '2025-06-12', DATE '2025-06-14', 'Checked-in'
),
inserted_bookings AS (
    INSERT INTO hotel.booking (customer_id, room_id, check_in_date, check_out_date, status)
    SELECT customer_id, room_id, check_in_date, check_out_date, status
    FROM new_booking nb
    WHERE NOT EXISTS (
        SELECT 1 
        FROM hotel.booking b
        WHERE b.room_id = nb.room_id AND b.check_in_date = nb.check_in_date
    )
    RETURNING booking_id, customer_id, room_id, check_in_date, check_out_date, status
)
SELECT * FROM inserted_bookings;

-- 12. Table payment
WITH new_payment AS (
    SELECT 
        8 AS booking_id, 
        250.00 AS amount, 
        DATE '2025-06-09' AS payment_date, 
        'Cash' AS method
    UNION ALL
    SELECT 
        9, 400.00, DATE '2025-06-11', 'Cash'
    UNION ALL
    SELECT 
        10, 150.00, DATE '2025-06-12', 'Card'
    UNION ALL
    SELECT 
        11, 300.00, DATE '2025-06-14', 'Cash'
    UNION ALL
    SELECT 
        12, 600.00, DATE '2025-06-17', 'Card'
),
inserted_payment AS (
    INSERT INTO hotel.payment (booking_id, amount, payment_date, method)
    SELECT np.booking_id, np.amount, np.payment_date, np.method
    FROM new_payment np
    WHERE NOT EXISTS (
        SELECT 1
        FROM hotel.payment p
        WHERE p.booking_id = np.booking_id
    )
    RETURNING payment_id, booking_id, amount, payment_date, method
)
SELECT * FROM inserted_payment;

-- 13. Table service_request
WITH new_service_request AS (
    SELECT 
        1 AS request_id,
        8 AS booking_id,
        1 AS service_id,
        1 AS staff_id,
        '2024-01-01 09:00:00'::timestamp AS request_time,
        'Available' AS status
    UNION ALL
    SELECT 
        2, 9, 2, 2, '2024-01-01 10:30:00'::timestamp, 'Available'
    UNION ALL
    SELECT 
        3, 10, 3, 3, '2024-01-01 00:00:00'::timestamp, 'Not available'
    UNION ALL
    SELECT 
        4, 11, 4, 4, '2024-01-01 13:00:00'::timestamp, 'Available'
    UNION ALL
    SELECT 
        5, 12, 5, 5, '2024-01-01 16:00:00'::timestamp, 'Not available'
),
inserted_service_request AS (
    INSERT INTO hotel.service_request (request_id, booking_id, service_id, staff_id, request_time, status)
    SELECT request_id, booking_id, service_id, staff_id, request_time, status
    FROM new_service_request nsr
    WHERE NOT EXISTS (
        SELECT 1 
        FROM hotel.service_request sr
        WHERE sr.booking_id = nsr.booking_id
          AND sr.service_id = nsr.service_id
          AND sr.request_time = nsr.request_time
    )
    RETURNING request_id, booking_id, service_id, staff_id, request_time, status
)
SELECT * FROM inserted_service_request;

-- 14. Room_amenities
WITH new_room_amenity AS (
	SELECT 2 AS room_id, 3 AS amenity_id
	UNION ALL 
	SELECT 3, 2
	UNION ALL 
	SELECT 4, 1
	UNION ALL 
	SELECT 5, 3
	UNION ALL 
	SELECT 6, 2
	UNION ALL 
	SELECT 7, 1
	UNION ALL 
	SELECT 8, 1
	UNION ALL 
	SELECT 9, 4
),
inserted_room_amenity AS (
	INSERT INTO hotel.room_amenity (room_id, amenity_id)
	SELECT nra.room_id, nra.amenity_id
	FROM new_room_amenity nra
	WHERE NOT EXISTS (
		SELECT 1 
		FROM hotel.room_amenity ra
		WHERE ra.room_id = nra.room_id AND ra.amenity_id = nra.amenity_id
	)
	RETURNING id, room_id, amenity_id
)
SELECT * FROM inserted_room_amenity;

