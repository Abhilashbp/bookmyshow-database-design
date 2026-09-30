USE bookmyshow;

-- P2: List all shows on a given date at a given theatre.
SELECT
    t.name AS theatre_name,
    m.title AS movie_name,
    sc.screen_name,
    s.show_date,
    s.start_time,
    s.end_time
FROM shows s
JOIN movies m ON s.movie_id = m.movie_id
JOIN screens sc ON s.screen_id = sc.screen_id
JOIN theatres t ON sc.theatre_id = t.theatre_id
WHERE t.theatre_id = 1
  AND s.show_date = '2026-10-01'
ORDER BY s.start_time;

-- Integrity test: the following must fail because (show_id, seat_id) is unique.
-- INSERT INTO show_seats (show_id, seat_id, price) VALUES (1, 1, 250.00);

-- Verify booking.
SELECT
    b.booking_id, u.name AS customer, m.title AS movie,
    b.status AS booking_status, b.total_amount,
    st.row_label, st.seat_number, bs.price
FROM bookings b
JOIN users u ON b.user_id=u.user_id
JOIN shows sh ON b.show_id=sh.show_id
JOIN movies m ON sh.movie_id=m.movie_id
JOIN booking_seats bs ON b.booking_id=bs.booking_id
JOIN show_seats ss ON bs.show_id=ss.show_id AND bs.show_seat_id=ss.show_seat_id
JOIN seats st ON ss.seat_id=st.seat_id
WHERE b.booking_id=@booking_id;
