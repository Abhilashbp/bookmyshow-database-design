CREATE DATABASE IF NOT EXISTS bookmyshow;
USE bookmyshow;

CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE theatres (
    theatre_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE screens (
    screen_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    theatre_id BIGINT NOT NULL,
    screen_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_screens_theatre FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id),
    CONSTRAINT uq_screen_name_per_theatre UNIQUE (theatre_id, screen_name),
    CONSTRAINT chk_screen_capacity CHECK (capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE seats (
    seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    screen_id BIGINT NOT NULL,
    row_label VARCHAR(5) NOT NULL,
    seat_number INT NOT NULL,
    seat_type VARCHAR(30) NOT NULL DEFAULT 'REGULAR',
    CONSTRAINT fk_seats_screen FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
    CONSTRAINT uq_seat_position UNIQUE (screen_id, row_label, seat_number),
    CONSTRAINT chk_seat_number CHECK (seat_number > 0)
) ENGINE=InnoDB;

CREATE TABLE movies (
    movie_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    language VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    certificate VARCHAR(20),
    release_date DATE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_movie_duration CHECK (duration_minutes > 0)
) ENGINE=InnoDB;

CREATE TABLE shows (
    show_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT NOT NULL,
    screen_id BIGINT NOT NULL,
    show_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_shows_movie FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    CONSTRAINT fk_shows_screen FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
    CONSTRAINT uq_screen_show_time UNIQUE (screen_id, show_date, start_time),
    CONSTRAINT chk_show_time CHECK (end_time > start_time),
    INDEX idx_shows_screen_date_time (screen_id, show_date, start_time)
) ENGINE=InnoDB;

CREATE TABLE show_seats (
    show_seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    show_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_show_seats_show FOREIGN KEY (show_id) REFERENCES shows(show_id),
    CONSTRAINT fk_show_seats_seat FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
    CONSTRAINT uq_show_seat UNIQUE (show_id, seat_id),
    CONSTRAINT uq_show_seat_pair UNIQUE (show_id, show_seat_id),
    CONSTRAINT chk_show_seat_status CHECK (status IN ('AVAILABLE','HELD','BOOKED')),
    CONSTRAINT chk_show_seat_price CHECK (price >= 0),
    INDEX idx_show_seats_status (show_id, status)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    show_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(10,2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_bookings_show FOREIGN KEY (show_id) REFERENCES shows(show_id),
    CONSTRAINT uq_booking_show UNIQUE (booking_id, show_id),
    CONSTRAINT chk_booking_status CHECK (status IN ('PENDING','CONFIRMED','CANCELLED','EXPIRED')),
    CONSTRAINT chk_booking_amount CHECK (total_amount >= 0),
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_show (show_id)
) ENGINE=InnoDB;

CREATE TABLE booking_seats (
    booking_seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    show_id BIGINT NOT NULL,
    show_seat_id BIGINT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_booking_seats_booking
        FOREIGN KEY (booking_id, show_id) REFERENCES bookings(booking_id, show_id),
    CONSTRAINT fk_booking_seats_show_seat
        FOREIGN KEY (show_id, show_seat_id) REFERENCES show_seats(show_id, show_seat_id),
    CONSTRAINT uq_booking_show_seat UNIQUE (booking_id, show_seat_id),
    CONSTRAINT chk_booking_seat_price CHECK (price >= 0),
    INDEX idx_booking_seats_show_seat (show_id, show_seat_id)
) ENGINE=InnoDB;

CREATE TABLE seat_holds (
    hold_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    hold_token VARCHAR(100) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    show_id BIGINT NOT NULL,
    show_seat_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_seat_holds_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_seat_holds_show_seat
        FOREIGN KEY (show_id, show_seat_id) REFERENCES show_seats(show_id, show_seat_id),
    CONSTRAINT chk_hold_status CHECK (status IN ('ACTIVE','RELEASED','EXPIRED','CONVERTED')),
    INDEX idx_seat_holds_expiry (status, expires_at),
    INDEX idx_seat_holds_show_seat (show_id, show_seat_id, status)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    gateway_payment_id VARCHAR(100) NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CONSTRAINT chk_payment_status CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    INDEX idx_payments_booking (booking_id)
) ENGINE=InnoDB;
