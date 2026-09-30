USE bookmyshow;

INSERT INTO users (name, email, phone) VALUES
('Abhilash', 'abhilash@example.com', '9876543210'),
('Rahul', 'rahul@example.com', '9876543211'),
('Priya', 'priya@example.com', '9876543212');

INSERT INTO theatres (name, address, city) VALUES
('PVR Orion Mall', 'Brigade Gateway, Dr Rajkumar Road', 'Bangalore'),
('INOX Garuda Mall', 'Magrath Road', 'Bangalore');

INSERT INTO screens (theatre_id, screen_name, capacity) VALUES
(1, 'Screen 1', 10),
(1, 'Screen 2', 10),
(2, 'Screen 1', 10);

INSERT INTO seats (screen_id, row_label, seat_number, seat_type) VALUES
(1,'A',1,'REGULAR'),(1,'A',2,'REGULAR'),(1,'A',3,'REGULAR'),
(1,'A',4,'PREMIUM'),(1,'A',5,'PREMIUM'),
(1,'B',1,'REGULAR'),(1,'B',2,'REGULAR'),(1,'B',3,'REGULAR'),
(1,'B',4,'PREMIUM'),(1,'B',5,'PREMIUM'),
(2,'A',1,'REGULAR'),(2,'A',2,'REGULAR'),(2,'A',3,'REGULAR'),
(2,'A',4,'PREMIUM'),(2,'A',5,'PREMIUM'),
(2,'B',1,'REGULAR'),(2,'B',2,'REGULAR'),(2,'B',3,'REGULAR'),
(2,'B',4,'PREMIUM'),(2,'B',5,'PREMIUM');

INSERT INTO movies (title, language, duration_minutes, certificate, release_date) VALUES
('Avengers: Endgame','English',181,'UA','2019-04-26'),
('Kantara','Kannada',148,'UA','2022-09-30');

INSERT INTO shows (movie_id, screen_id, show_date, start_time, end_time) VALUES
(1,1,'2026-10-01','10:00:00','13:01:00'),
(1,1,'2026-10-01','14:00:00','17:01:00'),
(2,2,'2026-10-01','18:00:00','20:28:00');

INSERT INTO show_seats (show_id, seat_id, price)
SELECT 1, seat_id, CASE WHEN seat_type='PREMIUM' THEN 350.00 ELSE 250.00 END
FROM seats WHERE screen_id=1;

INSERT INTO show_seats (show_id, seat_id, price)
SELECT 2, seat_id, CASE WHEN seat_type='PREMIUM' THEN 350.00 ELSE 250.00 END
FROM seats WHERE screen_id=1;

INSERT INTO show_seats (show_id, seat_id, price)
SELECT 3, seat_id, CASE WHEN seat_type='PREMIUM' THEN 350.00 ELSE 250.00 END
FROM seats WHERE screen_id=2;

-- Example confirmed booking for user 1 on show 1 using A1 and A2.
START TRANSACTION;
INSERT INTO bookings (user_id, show_id, status, total_amount)
VALUES (1,1,'CONFIRMED',500.00);
SET @booking_id = LAST_INSERT_ID();

INSERT INTO booking_seats (booking_id, show_id, show_seat_id, price)
VALUES (@booking_id,1,1,250.00), (@booking_id,1,2,250.00);

UPDATE show_seats
SET status='BOOKED'
WHERE show_id=1 AND show_seat_id IN (1,2);

COMMIT;

INSERT INTO payments (booking_id, gateway_payment_id, amount, status)
VALUES (@booking_id, 'PAY-DEMO-0001', 500.00, 'SUCCESS');
