# BookMyShow Ticketing Backend – Database Design

## Objective
Design a MySQL backend for a high-concurrency movie ticketing system where many users may compete for the same seat.

## Entities
- users – customers
- theatres – cinema locations
- screens – screens inside theatres
- seats – physical seats
- movies – movie catalogue
- shows – a movie scheduled on a screen at a date/time
- show_seats – seat inventory for each show
- bookings – booking/order
- booking_seats – seats belonging to a booking
- seat_holds – temporary holds
- payments – payment transactions

## Concurrency strategy
MySQL is the persistent source of truth. Redis is used for short-lived seat locks.

A seat lock uses an atomic operation such as:

SET seat-lock:{show_id}:{seat_id} {hold_token} NX EX 300

NX means only the first concurrent request can create the lock. EX 300 gives the hold a five-minute TTL. If payment is not completed, Redis expires the lock automatically.

MySQL provides a second integrity layer:
- UNIQUE(show_id, seat_id) prevents duplicate show-seat inventory.
- Composite foreign keys ensure a booking/hold references a seat belonging to the same show.
- InnoDB transactions make booking/payment state changes atomic.
- UNIQUE(gateway_payment_id) makes payment webhook processing idempotent.

## Normalization
1NF: atomic attributes and no comma-separated seat lists.
2NF: relationship-specific data is stored in junction tables such as booking_seats.
3NF: theatre, screen, seat, movie and payment attributes are stored in their own tables rather than being repeated in bookings.
BCNF: determinants represented by primary/candidate keys and unique constraints; show-seat identity is enforced by (show_id, seat_id).

## P2
The query in sql/queries.sql returns all movies and show timings for a theatre/date.

## Load-test design
Test A: 100 concurrent users attempt the same show/seat. Expected result: exactly one Redis lock succeeds; the rest fail.
Test B: 100 concurrent users attempt 10 different seats. Expected result: at most 10 active holds.
Test C: send the same payment webhook 100 times with one gateway_payment_id. Expected result: one payment record and no duplicate payment processing.

## Run
1. Create the database and tables with schema.sql.
2. Insert sample data with sample_data.sql.
3. Run P2 and integrity queries from queries.sql.
4. Redis is required only for the runtime locking implementation; the schema itself is MySQL.

## Submission

This branch contains the final submission for the BookMyShow database design assignment.