DROP DATABASE IF EXISTS CinemaDB;
CREATE DATABASE CinemaDB;
USE CinemaDB;

SELECT * FROM ScreeningSeats;

DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS BookingSnackDetails;
DROP TABLE IF EXISTS BookingSnacks;
DROP TABLE IF EXISTS Snacks;
DROP TABLE IF EXISTS BookingTickets;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS TicketPrice;
DROP TABLE IF EXISTS Discounts;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS ScreeningSeats;
DROP TABLE IF EXISTS Screenings;
DROP TABLE IF EXISTS SeatMap;
DROP TABLE IF EXISTS SeatType;
DROP TABLE IF EXISTS CinemaRooms;
DROP TABLE IF EXISTS MovieCasts;
DROP TABLE IF EXISTS Casts;
DROP TABLE IF EXISTS Movies;

-- Movies

CREATE TABLE Movies (
  MovieID INT AUTO_INCREMENT PRIMARY KEY,
  MovieTitle VARCHAR(255) NOT NULL,
  Genre VARCHAR(100) NOT NULL,
  DurationMinutes INT NOT NULL
);

-- Casts
CREATE TABLE Casts (
  CastID INT AUTO_INCREMENT PRIMARY KEY,
  CastName VARCHAR(100) NOT NULL
);

-- MovieCasts
CREATE TABLE MovieCasts (
  MovieID INT NOT NULL,
  CastID INT NOT NULL,
  Role VARCHAR(100) NOT NULL,
  PRIMARY KEY (MovieID, CastID),
  FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE,
  FOREIGN KEY (CastID) REFERENCES Casts(CastID) ON DELETE CASCADE
);

-- CinemaRooms
CREATE TABLE CinemaRooms (
  RoomID INT AUTO_INCREMENT PRIMARY KEY,
  RoomName VARCHAR(100) NOT NULL,
  Capacity INT NOT NULL,
  RoomType VARCHAR(50) NOT NULL
);

-- SeatType
CREATE TABLE SeatType (
  SeatTypeID INT AUTO_INCREMENT PRIMARY KEY,
  Type VARCHAR(50) NOT NULL,
  Description VARCHAR(255)
);

-- SeatMap
CREATE TABLE SeatMap (
  SeatID INT AUTO_INCREMENT PRIMARY KEY,
  SeatRow CHAR(1) NOT NULL,
  SeatCol INT NOT NULL,
  RoomID INT NOT NULL,
  SeatTypeID INT NOT NULL,
  UNIQUE (RoomID, SeatRow, SeatCol),
  FOREIGN KEY (RoomID) REFERENCES CinemaRooms(RoomID) ON DELETE CASCADE,
  FOREIGN KEY (SeatTypeID) REFERENCES SeatType(SeatTypeID)
);

-- Screenings
CREATE TABLE Screenings (
  ScreeningID INT AUTO_INCREMENT PRIMARY KEY,
  ScreeningDate DATE NOT NULL,
  ScreeningTime TIME NOT NULL,
  MovieID INT NOT NULL,
  RoomID INT NOT NULL,
  FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE,
  FOREIGN KEY (RoomID) REFERENCES CinemaRooms(RoomID) ON DELETE CASCADE
);

-- ScreeningSeats
CREATE TABLE ScreeningSeats (
  ScreeningID INT NOT NULL,
  SeatID INT NOT NULL,
  Status ENUM('Available', 'Booked') NOT NULL DEFAULT 'Available',
  PRIMARY KEY (ScreeningID, SeatID),
  FOREIGN KEY (ScreeningID) REFERENCES Screenings(ScreeningID) ON DELETE CASCADE,
  FOREIGN KEY (SeatID) REFERENCES SeatMap(SeatID) ON DELETE CASCADE
);

-- Customers
CREATE TABLE Customers (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerName VARCHAR(100) NOT NULL,
  PhoneNumber VARCHAR(20) NOT NULL,
  CustomerEmail VARCHAR(100) NOT NULL
);

-- Discounts
CREATE TABLE Discounts (
  DiscountID INT AUTO_INCREMENT PRIMARY KEY,
  Code VARCHAR(50) NOT NULL UNIQUE,
  Percentage DECIMAL(5,2) NOT NULL,
  ValidUntil DATE NOT NULL
);

-- TicketPrice
CREATE TABLE TicketPrice (
  PricingID INT AUTO_INCREMENT PRIMARY KEY,
  SeatTypeID INT NOT NULL UNIQUE,
  Price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (SeatTypeID) REFERENCES SeatType(SeatTypeID) ON DELETE CASCADE
);

-- Bookings
CREATE TABLE Bookings (
  BookingID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT NOT NULL,
  BookingDate DATETIME NOT NULL,
  IsCancelled BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- BookingTickets
CREATE TABLE BookingTickets (
  BookingTicketsID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  ScreeningID INT NULL,
  SeatID INT NOT NULL,
  PricingID INT NOT NULL,
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE CASCADE,
  FOREIGN KEY (ScreeningID) REFERENCES Screenings(ScreeningID),
  FOREIGN KEY (SeatID) REFERENCES SeatMap(SeatID),
  FOREIGN KEY (PricingID) REFERENCES TicketPrice(PricingID)
);

-- Snacks
CREATE TABLE Snacks (
  SnackID INT AUTO_INCREMENT PRIMARY KEY,
  SnackName VARCHAR(100) NOT NULL,
  Price DECIMAL(10,2) NOT NULL
);

-- BookingSnacks
CREATE TABLE BookingSnacks (
  BookingSnackID INT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  TotalAmount DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE CASCADE
);

-- BookingSnackDetails
CREATE TABLE BookingSnackDetails (
  BookingSnackDetailID INT AUTO_INCREMENT PRIMARY KEY,
  BookingSnackID INT NOT NULL,
  SnackID INT NOT NULL,
  Quantity INT NOT NULL,
  FOREIGN KEY (BookingSnackID) REFERENCES BookingSnacks(BookingSnackID) ON DELETE CASCADE,
  FOREIGN KEY (SnackID) REFERENCES Snacks(SnackID) ON DELETE CASCADE
);

-- Payments
CREATE TABLE Payments (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  PaymentDate DATETIME NOT NULL,
  Amount DECIMAL(10,2) NOT NULL,
  PaymentMethod VARCHAR(50) NOT NULL,
  Status ENUM('Pending', 'Paid', 'Failed') DEFAULT 'Pending',
  CustomerID INT NOT NULL,
  BookingID INT NOT NULL UNIQUE,
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE CASCADE
);

-- Invoice
CREATE TABLE Invoice (
  InvoiceID INT AUTO_INCREMENT PRIMARY KEY,
  TotalAmount DECIMAL(10,2) NOT NULL,
  InvoiceDate DATETIME NOT NULL,
  PaymentID INT NOT NULL UNIQUE,
  FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID) ON DELETE CASCADE
);

-- Users
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin_cinema', 'ticket_clerk') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Movies (MovieTitle, Genre, DurationMinutes) VALUES
('Crayon Shin-chan: Shrouded in Mystery! The Flowers of Tenkasu Academy', 'Family', 104),
('Night Of The Zoopocalypse', 'Family', 91),
('ThunderBolts', 'Action', 126),
('Doraemon: Nobita Art World Tales', 'Family', 105),
('Detective Kien: The Headless Horror', 'Thriller', 131),
('A Minecraft Movie', 'Family', 101),
('Holy Night: Demon Hunters', 'Action', 91),
('Tunnel: Sun in the Dark', 'History', 128),
('Peg O’ My Heart', 'Crime', 98),
('Until Dawn', 'Horror', 104);


INSERT INTO Casts (CastName) VALUES
('Don Lee'),
('Ma Dong Seok'),
('Florence Pugh'),
('SLewis Pullman'),
('Jason Momoa'),
('Ella Rubin'),
('Michael Cimino'),
('David Harbour'),
('Bryn McAuley'),
('Seo Hyun');


INSERT INTO MovieCasts (MovieID, CastID, Role) VALUES
(1, 1, 'Lead'),
(1, 2, 'Supporting'),
(2, 3, 'Lead'),
(3, 4, 'Lead'),
(4, 5, 'Antagonist'),
(5, 6, 'Detective'),
(6, 7, 'Heroine'),
(7, 8, 'Demon'),
(8, 9, 'Father'),
(9, 10, 'Ghost');


INSERT INTO CinemaRooms (RoomName, Capacity, RoomType) VALUES
('Room A', 30, 'Basic'),
('Room B', 30, 'Basic'),
('Room C', 20, 'Standard'),
('Room D', 20, 'Standard'),
('Room E', 10, 'VIP'),
('Room F', 10, 'VIP');


INSERT INTO SeatType (Type, Description) VALUES
('Standard', 'Standard seat'),
('VIP', 'Reclining leather seat with extra legroom'),
('Couple', 'Double seat for two people');

-- Room A (RoomID = 1)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 1, 1), ('A', 2, 1, 1), ('A', 3, 1, 1), ('A', 4, 1, 1), ('A', 5, 1, 1),
('A', 6, 1, 1), ('A', 7, 1, 1), ('A', 8, 1, 1), ('A', 9, 1, 1), ('A', 10, 1, 1),
('B', 1, 1, 1), ('B', 2, 1, 1), ('B', 3, 1, 1), ('B', 4, 1, 1), ('B', 5, 1, 1),
('B', 6, 1, 1), ('B', 7, 1, 1), ('B', 8, 1, 1), ('B', 9, 1, 1), ('B', 10, 1, 1),
('C', 1, 1, 2), ('C', 2, 1, 2), ('C', 3, 1, 2), ('C', 4, 1, 2), ('C', 5, 1, 2),
('C', 6, 1, 2), ('C', 7, 1, 2), ('C', 8, 1, 2), ('C', 9, 1, 2), ('C', 10, 1, 2);
-- Room B (RoomID = 2)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 2, 1), ('A', 2, 2, 1), ('A', 3, 2, 1), ('A', 4, 2, 1), ('A', 5, 2, 1),
('A', 6, 2, 1), ('A', 7, 2, 1), ('A', 8, 2, 1), ('A', 9, 2, 1), ('A', 10, 2, 1),
('B', 1, 2, 1), ('B', 2, 2, 1), ('B', 3, 2, 1), ('B', 4, 2, 1), ('B', 5, 2, 1),
('B', 6, 2, 1), ('B', 7, 2, 1), ('B', 8, 2, 1), ('B', 9, 2, 1), ('B', 10, 2, 1),
('C', 1, 2, 2), ('C', 2, 2, 2), ('C', 3, 2, 2), ('C', 4, 2, 2), ('C', 5, 2, 2),
('C', 6, 2, 2), ('C', 7, 2, 2), ('C', 8, 2, 2), ('C', 9, 2, 2), ('C', 10, 2, 2);
-- Room C (RoomID = 3)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 3, 1), ('A', 2, 3, 1), ('A', 3, 3, 1), ('A', 4, 3, 1), ('A', 5, 3, 1),
('B', 1, 3, 1), ('B', 2, 3, 1), ('B', 3, 3, 1), ('B', 4, 3, 1), ('B', 5, 3, 1),
('C', 1, 3, 1), ('C', 2, 3, 1), ('C', 3, 3, 1), ('C', 4, 3, 1), ('C', 5, 3, 1),
('D', 1, 3, 3), ('D', 2, 3, 3), ('D', 3, 3, 3), ('D', 4, 3, 3), ('D', 5, 3, 3);
-- Room D (RoomID = 4)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 4, 1), ('A', 2, 4, 1), ('A', 3, 4, 1), ('A', 4, 4, 1), ('A', 5, 4, 1),
('A', 6, 4, 1), ('A', 7, 4, 1), ('A', 8, 4, 1), ('A', 9, 4, 1), ('A', 10, 4, 1),
('B', 1, 4, 1), ('B', 2, 4, 1), ('B', 3, 4, 1), ('B', 4, 4, 1), ('B', 5, 4, 1),
('B', 6, 4, 3), ('B', 7, 4, 3), ('B', 8, 4, 3), ('B', 9, 4, 3), ('B', 10, 4, 3);
-- Room E (RoomID = 5)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 5, 2), ('A', 2, 5, 2), ('A', 3, 5, 2), ('A', 4, 5, 2), ('A', 5, 5, 2),
('B', 1, 5, 3), ('B', 2, 5, 3), ('B', 3, 5, 3), ('B', 4, 5, 3), ('B', 5, 5, 3);
-- Room F (RoomID = 6)
INSERT INTO SeatMap (SeatRow, SeatCol, RoomID, SeatTypeID) VALUES
('A', 1, 6, 2), ('A', 2, 6, 2), ('A', 3, 6, 2), ('A', 4, 6, 2), ('A', 5, 6, 2),
('A', 6, 6, 3), ('A', 7, 6, 3), ('A', 8, 6, 3), ('A', 9, 6, 3), ('A', 10, 6, 3);


INSERT INTO Screenings (ScreeningDate, ScreeningTime, MovieID, RoomID) VALUES
('2025-05-11', '18:00:00', 1, 1),
('2025-05-12', '12:30:00', 2, 2),
('2025-05-12', '15:00:00', 3, 3),
('2025-05-12', '17:00:00', 4, 4),
('2025-05-13', '19:00:00', 5, 5),
('2025-05-10', '11:00:00', 6, 6),
('2025-05-22', '16:30:00', 7, 1),
('2025-05-14', '18:30:00', 8, 2),
('2025-05-23', '20:00:00', 9, 3),
('2025-05-10', '11:30:00', 10, 4);


INSERT INTO ScreeningSeats (ScreeningID, SeatID, Status) VALUES
(1, 1, 'Available'), (1, 2, 'Available'), (1, 3, 'Available'), (1, 4, 'Available'), (1, 5, 'Available'),
(1, 6, 'Available'), (1, 7, 'Available'), (1, 8, 'Available'), (1, 9, 'Available'), (1, 10, 'Available'),
(1, 11, 'Available'), (1, 12, 'Available'), (1, 13, 'Available'), (1, 14, 'Available'), (1, 15, 'Available'),
(1, 16, 'Available'), (1, 17, 'Available'), (1, 18, 'Available'), (1, 19, 'Available'), (1, 20, 'Available'),
(1, 21, 'Available'), (1, 22, 'Available'), (1, 23, 'Available'), (1, 24, 'Available'), (1, 25, 'Available'),
(1, 26, 'Available'), (1, 27, 'Available'), (1, 28, 'Available'), (1, 29, 'Available'), (1, 30, 'Available'),

(2, 31, 'Available'), (2, 32, 'Booked'), (2, 33, 'Booked'), (2, 34, 'Booked'), (2, 35, 'Booked'),
(2, 36, 'Available'), (2, 37, 'Available'), (2, 38, 'Available'), (2, 39, 'Available'), (2, 40, 'Available'),
(2, 41, 'Available'), (2, 42, 'Available'), (2, 43, 'Available'), (2, 44, 'Available'), (2, 45, 'Available'),
(2, 46, 'Available'), (2, 47, 'Available'), (2, 48, 'Available'), (2, 49, 'Available'), (2, 50, 'Available'),
(2, 51, 'Available'), (2, 52, 'Available'), (2, 53, 'Available'), (2, 54, 'Available'), (2, 55, 'Available'),
(2, 56, 'Available'), (2, 57, 'Available'), (2, 58, 'Available'), (2, 59, 'Available'), (2, 60, 'Available'),

(3, 61, 'Available'), (3, 62, 'Available'), (3, 63, 'Available'), (3, 64, 'Available'), (3, 65, 'Available'),
(3, 66, 'Available'), (3, 67, 'Available'), (3, 68, 'Available'), (3, 69, 'Available'), (3, 70, 'Available'),
(3, 71, 'Available'), (3, 72, 'Available'), (3, 73, 'Available'), (3, 74, 'Available'), (3, 75, 'Available'),
(3, 76, 'Available'), (3, 77, 'Available'), (3, 78, 'Available'), (3, 79, 'Available'), (3, 80, 'Available'),

(4, 81, 'Available'), (4, 82, 'Available'), (4, 83, 'Available'), (4, 84, 'Available'), (4, 85, 'Available'),
(4, 86, 'Available'), (4, 87, 'Available'), (4, 88, 'Available'), (4, 89, 'Available'), (4, 90, 'Available'),
(4, 91, 'Available'), (4, 92, 'Available'), (4, 93, 'Available'), (4, 94, 'Available'), (4, 95, 'Available'),
(4, 96, 'Available'), (4, 97, 'Available'), (4, 98, 'Available'), (4, 99, 'Available'), (4, 100, 'Available'),

(5, 101, 'Available'), (5, 102, 'Available'), (5, 103, 'Available'), (5, 104, 'Available'), (5, 105, 'Available'),
(5, 106, 'Available'), (5, 107, 'Booked'), (5, 108, 'Booked'), (5, 109, 'Available'), (5, 110, 'Available'),

(6, 111, 'Available'), (6, 112, 'Available'), (6, 113, 'Available'), (6, 114, 'Available'), (6, 115, 'Available'),
(6, 116, 'Available'), (6, 117, 'Available'), (6, 118, 'Booked'), (6, 119, 'Booked'), (6, 120, 'Booked'),

(7, 1, 'Available'), (7, 2, 'Available'), (7, 3, 'Available'), (7, 4, 'Available'), (7, 5, 'Available'),
(7, 6, 'Available'), (7, 7, 'Available'), (7, 8, 'Available'), (7, 9, 'Available'), (7, 10, 'Available'),
(7, 11, 'Available'), (7, 12, 'Available'), (7, 13, 'Available'), (7, 14, 'Available'), (7, 15, 'Available'),
(7, 16, 'Available'), (7, 17, 'Available'), (7, 18, 'Available'), (7, 19, 'Available'), (7, 20, 'Available'),
(7, 21, 'Available'), (7, 22, 'Available'), (7, 23, 'Available'), (7, 24, 'Available'), (7, 25, 'Available'),
(7, 26, 'Available'), (7, 27, 'Available'), (7, 28, 'Available'), (7, 29, 'Available'), (7, 30, 'Available'),

(8, 31, 'Available'), (8, 32, 'Available'), (8, 33, 'Available'), (8, 34, 'Available'), (8, 35, 'Available'),
(8, 36, 'Available'), (8, 37, 'Available'), (8, 38, 'Available'), (8, 39, 'Available'), (8, 40, 'Booked'),
(8, 41, 'Available'), (8, 42, 'Available'), (8, 43, 'Available'), (8, 44, 'Available'), (8, 45, 'Available'),
(8, 46, 'Available'), (8, 47, 'Available'), (8, 48, 'Available'), (8, 49, 'Available'), (8, 50, 'Available'),
(8, 51, 'Available'), (8, 52, 'Available'), (8, 53, 'Available'), (8, 54, 'Available'), (8, 55, 'Available'),
(8, 56, 'Available'), (8, 57, 'Available'), (8, 58, 'Available'), (8, 59, 'Available'), (8, 60, 'Available'),

(9, 61, 'Available'), (9, 62, 'Available'), (9, 63, 'Available'), (9, 64, 'Available'), (9, 65, 'Available'),
(9, 66, 'Available'), (9, 67, 'Available'), (9, 68, 'Available'), (9, 69, 'Available'), (9, 70, 'Available'),
(9, 71, 'Available'), (9, 72, 'Available'), (9, 73, 'Available'), (9, 74, 'Available'), (9, 75, 'Available'),
(9, 76, 'Available'), (9, 77, 'Available'), (9, 78, 'Available'), (9, 79, 'Available'), (9, 80, 'Available'),

(10, 81, 'Available'), (10, 82, 'Available'), (10, 83, 'Booked'), (10, 84, 'Booked'), (10, 85, 'Available'),
(10, 86, 'Available'), (10, 87, 'Available'), (10, 88, 'Available'), (10, 89, 'Available'), (10, 90, 'Available'),
(10, 91, 'Available'), (10, 92, 'Available'), (10, 93, 'Available'), (10, 94, 'Available'), (10, 95, 'Available'),
(10, 96, 'Available'), (10, 97, 'Available'), (10, 98, 'Available'), (10, 99, 'Available'), (10, 100, 'Available');


INSERT INTO Customers (CustomerName, PhoneNumber, CustomerEmail) VALUES
('Alice Johnson', '1234567890','alice@gmail.com'),
('Bob Smith', '2345678901','bob@gmail.com'),
('Charlie Nguyen', '3456789012','charlie@gmail.com'),
('Diana Lee', '4567890123','diana@gmail.com'),
('Ethan Kim', '5678901234','ethan@gmail.com'),
('Fiona Chen', '6789012345','fiona@gmail.com'),
('George Pham', '7890123456','george@gmail.com'),
('Hannah Tran', '8901234567','hannah@gmail.com'),
('Ivan Do', '9012345678','ivan@gmail.com'),
('Jenny Vu', '0123456789','jenny@gmail.com');


INSERT INTO Discounts (Code, Percentage, ValidUntil) VALUES
('NO', 0.00, '2030-12-31'),
('NEW10', 10.00, '2025-12-31'),
('VIP20', 20.00, '2025-11-30'),
('STUDENT15', 15.00, '2025-10-31'),
('WEEKEND5', 5.00, '2025-09-30'),
('FLASH25', 25.00, '2025-08-31');


INSERT INTO TicketPrice (SeatTypeID, Price) VALUES
(1, 100000), -- Standard
(2, 120000), -- VIP
(3, 180000); -- Couple


INSERT INTO Bookings (CustomerID, BookingDate, IsCancelled) VALUES
(4, '2025-05-10 10:22:00', FALSE),
(3, '2025-05-11 11:20:00', FALSE),
(1, '2025-05-12 12:24:00', FALSE),
(9, '2025-05-13 13:20:00', FALSE),
(10, '2025-05-14 14:25:00', FALSE);

INSERT INTO BookingTickets (BookingID, ScreeningID, SeatID, PricingID) VALUES
(1, 6, 118, 3),
(1, 6, 119, 3),
(1, 6, 120, 3),
(2, 10, 83, 1),
(2, 10, 84, 1),
(3, 2, 32, 1),
(3, 2, 33, 1),
(3, 2, 34, 1),
(3, 2, 35, 1),
(4, 5, 107, 3),
(4, 5, 108, 3),
(5, 8, 40, 1);


INSERT INTO Snacks (SnackName, Price) VALUES
('Popcorn', 30000),
('Coke', 20000),
('Nachos', 40000),
('Hotdog', 50000),
('Water', 15000);


INSERT INTO BookingSnacks (BookingID, TotalAmount) VALUES
(1, 60000),
(2, 40000),
(3, 60000),
(4, 30000);


INSERT INTO BookingSnackDetails (BookingSnackID, SnackID, Quantity)
VALUES
(1, 2, 3),
(2, 3, 1),
(3, 1, 2),
(4, 1, 1);


INSERT INTO Payments (PaymentDate, Amount, PaymentMethod, Status, CustomerID, BookingID)
VALUES
('2025-05-10 10:30:00', 600000, 'Credit Card', 'Paid', 4, 1),
('2025-05-11 11:30:00', 240000, 'Debit Card', 'Paid', 3, 2),
('2025-05-12 12:30:00', 460000, 'Cash', 'Paid', 1, 3),
('2025-05-13 13:30:00', 390000, 'Credit Card', 'Paid', 9, 4),
('2025-05-14 14:30:00', 100000, 'Cash', 'Paid', 10, 5);

INSERT INTO Invoice (TotalAmount, InvoiceDate, PaymentID) VALUES
(600000, '2025-05-10 10:30:00', 1),
(240000, '2025-05-11 11:30:00', 2),
(460000, '2025-05-12 12:30:00', 3),
(390000, '2025-05-13 13:30:00', 4),
(100000, '2025-05-14 14:30:00', 5);

INSERT INTO Users (username, password, role) 
VALUES ('admin_cinema', 'Admincinema1', 'admin_cinema');

-- Insert ticket clerk user
INSERT INTO Users (username, password, role) 
VALUES ('ticket_clerk', 'Ticketclerk1', 'ticket_clerk');

-- Speed up search by movie title
CREATE INDEX idx_movie_title ON Movies (MovieTitle);

-- Speed up search by genre
CREATE INDEX idx_movie_genre ON Movies (Genre);

-- Speed up query for screenings by date
CREATE INDEX idx_screening_date ON Screenings (ScreeningDate);

-- Speed up seat search by Room and Status
CREATE INDEX idx_seat_room_status ON ScreeningSeats (ScreeningID, Status);

-- Speed up customer search by phone number
CREATE INDEX idx_customer_phone ON Customers (PhoneNumber);

-- Speed up invoice search by date
CREATE INDEX idx_invoice_date ON Invoice (InvoiceDate);

-- Speed up ticket bookings by customer
CREATE INDEX idx_booking_customer ON Bookings (CustomerID);

-- 1. View available seats for each screenings
CREATE VIEW vw_TodayScreenings AS
	SELECT s.ScreeningID, m.MovieTitle, s.ScreeningTime, s.RoomID, s.ScreeningDate
FROM Screenings s
JOIN Movies m ON s.MovieID = m.MovieID
WHERE s.ScreeningDate = CURDATE()
ORDER BY s.ScreeningTime;

-- 2. View available seats for each screening
CREATE VIEW vw_AvailableSeatsPerScreening AS
	SELECT m.MovieTitle, s.ScreeningTime, s.ScreeningDate, ss.SeatID, s.ScreeningID
	FROM Screenings s
	JOIN Movies m ON s.MovieID = m.MovieID
	JOIN ScreeningSeats ss ON s.ScreeningID = ss.ScreeningID
	WHERE ss.Status = 'Available';

-- 3. View daily revenue
CREATE VIEW vw_DailyRevenue AS
	SELECT
		DATE(p.PaymentDate) AS RevenueDate,
		SUM(p.Amount) AS TotalRevenue,
		COUNT(p.PaymentID) AS NumberOfPayments
	FROM Payments p
	GROUP BY DATE(p.PaymentDate)
	ORDER BY TotalRevenue DESC;

-- 4. View booking history of customer
CREATE VIEW vw_UserBookingHistory AS
	SELECT  c.CustomerID, c.CustomerName, c.PhoneNumber, b.BookingID, b.BookingDate,
			m.MovieTitle, s.ScreeningDate, s.ScreeningTime, s.RoomID
	FROM Customers c
	JOIN Bookings b ON c.CustomerID = b.CustomerID
	JOIN BookingTickets bt ON bt.BookingID = b.BookingID
	JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
	JOIN Movies m ON s.MovieID = m.MovieID;

-- 5. View number of tickets sold by movie
CREATE VIEW vw_TicketsSoldByMovie AS
	SELECT m.MovieID, m.MovieTitle, COUNT(*) AS TicketSold
	FROM Movies m
	JOIN Screenings s ON m.MovieID = s.MovieID
	JOIN ScreeningSeats ss ON s.ScreeningID = ss.ScreeningID
	WHERE ss.Status NOT LIKE 'Available'
	GROUP BY m.MovieID, m.MovieTitle;

-- 6. View frequent customers
CREATE VIEW vw_FrequentCustomers AS
	SELECT c.CustomerID, c.CustomerName, c.PhoneNumber, COUNT(b.BookingID) AS TotalBookings
	FROM Customers c
	JOIN Bookings b ON c.CustomerID = b.CustomerID
	GROUP BY c.CustomerID, c.CustomerName, c.PhoneNumber
	ORDER BY TotalBookings DESC;

-- 7. View revenue by room    
CREATE VIEW vw_RoomRevenueStats AS
	SELECT cr.RoomID, cr.RoomName,
		COUNT(DISTINCT bt.BookingID) AS TotalBookings,
		SUM(p.Amount) AS TotalRevenue
	FROM CinemaRooms cr 
	JOIN Screenings s ON cr.RoomID = s.RoomID
	JOIN BookingTickets bt ON s.ScreeningID = bt.ScreeningID
	JOIN Bookings b ON bt.BookingID = b.BookingID
	JOIN Payments p ON b.BookingID = p.BookingID
	GROUP BY cr.RoomID, cr.RoomName
	ORDER BY TotalRevenue DESC;

-- 1. Function to calculate fill rate of each screening    
DELIMITER $$
CREATE FUNCTION fn_FillRate(in_screeningID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE TotalSeats INT;
    DECLARE BookedSeats INT;
    DECLARE FillRate DECIMAL(5,2);
    SELECT COUNT(*) INTO totalSeats
    FROM ScreeningSeats
    WHERE ScreeningID = in_screeningID;
	SELECT COUNT(*) INTO BookedSeats
    FROM ScreeningSeats
    WHERE ScreeningID = in_screeningID AND Status = 'Booked';
    IF TotalSeats > 0 THEN SET FillRate = (BookedSeats / TotalSeats) * 100;
    ELSE SET FillRate = 0.00;
    END IF;
    RETURN FillRate;
END $$
DELIMITER ;

-- 2. Function to get revenue by movie/screening/customer 
DELIMITER $$

CREATE FUNCTION fn_GetRevenue(scope VARCHAR(10), ID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE TotalRevenue DECIMAL(10,2);
    IF LOWER(scope) = 'movie' THEN
        SELECT SUM(Unique_Payments.Amount) INTO TotalRevenue
        FROM (
            SELECT DISTINCT p.PaymentID, p.Amount
            FROM Payments p
            JOIN BookingTickets bt ON bt.BookingID = p.BookingID
            JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
            WHERE s.MovieID = ID
        ) AS Unique_Payments;
    ELSEIF LOWER(scope) = 'screening' THEN
        SELECT SUM(Unique_Payments.Amount) INTO TotalRevenue
        FROM (
            SELECT DISTINCT p.PaymentID, p.Amount
            FROM Payments p
            JOIN BookingTickets bt ON bt.BookingID = p.BookingID
            JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
            WHERE s.ScreeningID = ID
        ) AS unique_payments;
    ELSEIF LOWER(scope) = 'customer' THEN
        SELECT SUM(payments.Amount) INTO TotalRevenue
        FROM Payments p
        WHERE p.CustomerID = ID;
    ELSE
        SET TotalRevenue = 0.00;
    END IF;
    RETURN IFNULL(TotalRevenue, 0.00);
END $$
DELIMITER ;

-- 3. Function to calculate number of snack sold by snackID
DELIMITER $$
CREATE FUNCTION fn_TotalSnackSold(in_snackID INT)
Returns INT
DETERMINISTIC
Begin 
	DECLARE TotalSnack INT;
    Select Sum(Quantity) into TotalSnack
    FROM BookingSnackDetails
    WHERE SnackID = in_snackID;
	RETURN IFNULL (TotalSnack, 0);
END $$
DELIMITER ;

-- 4. Function check for valid discount or not
DELIMITER $$
CREATE FUNCTION fn_ValidateDiscount(in_code VARCHAR(10))
RETURNS TINYINT
DETERMINISTIC
BEGIN
    DECLARE IsValid TINYINT DEFAULT 0;
    SELECT COUNT(*)
    INTO IsValid
    FROM Discounts d
    WHERE d.Code = in_code AND CURDATE() <= ValidUntil;
    RETURN IsValid;
END $$
DELIMITER ;

-- 1. Stored procedure to apply a discount code to a specific booking ticket
ALTER TABLE BookingTickets
ADD COLUMN FinalPrice DECIMAL(10,2) DEFAULT NULL;

ALTER TABLE BookingTickets
ADD COLUMN DiscountID INT DEFAULT NULL;
DELIMITER $$
CREATE PROCEDURE ApplyDiscountCode (
    IN p_Code VARCHAR(50),
    IN p_BookingTicketsID INT
)
BEGIN
    DECLARE v_DiscountID INT;
    DECLARE v_Percentage DECIMAL(5,2);
    DECLARE v_OriginalPrice DECIMAL(10,2);
    DECLARE v_DiscountedPrice DECIMAL(10,2);
    DECLARE v_PricingID INT;

    -- Get DiscountID and percentage from discount code
    SELECT DiscountID, Percentage
    INTO v_DiscountID, v_Percentage
    FROM Discounts
    WHERE Code = p_Code AND ValidUntil >= CURDATE()
    LIMIT 1;

    -- If discount code is valid
    IF v_DiscountID IS NOT NULL THEN

        -- Get PricingID and original price from BookingTickets and TicketPrice
        SELECT bt.PricingID, tp.Price
        INTO v_PricingID, v_OriginalPrice
        FROM BookingTickets bt
        JOIN TicketPrice tp ON bt.PricingID = tp.PricingID
        WHERE bt.BookingTicketsID = p_BookingTicketsID;

        -- Calculate discounted price
        SET v_DiscountedPrice = v_OriginalPrice * (1 - v_Percentage / 100);

        -- Update booking ticket with final price and discount
        UPDATE BookingTickets
        SET DiscountID = v_DiscountID,
            FinalPrice = v_DiscountedPrice
        WHERE BookingTicketsID = p_BookingTicketsID;

        -- Show discounted price
        SELECT CONCAT('Discounted Price: ', FORMAT(v_DiscountedPrice, 2)) AS DiscountedPrice;

	-- If discount code is invalid or expired
    ELSE
        SELECT 'Invalid or expired discount code' AS Message;
    END IF;
END$$

DELIMITER ;

-- 2. Stored procedure to book a ticket with optional snack and discount
DELIMITER $$

CREATE PROCEDURE BookTicketsWithOptionalSnack (
  IN p_CustomerName VARCHAR(100),
  IN p_Phone VARCHAR(20),
  IN p_Email VARCHAR(100),
  IN p_PaymentMethod VARCHAR(50),
  IN p_SeatJSON JSON,   
  IN p_SnackJSON JSON,       
  IN p_DiscountCode VARCHAR(50)
)
BEGIN
  DECLARE v_CustomerID INT;
  DECLARE v_BookingID INT;
  DECLARE v_SeatTypeID INT;
  DECLARE v_PricingID INT;
  DECLARE v_TicketPrice DECIMAL(10,2);
  DECLARE v_DiscountID INT DEFAULT 1;
  DECLARE v_DiscountPercent DECIMAL(5,2) DEFAULT 0;
  DECLARE v_FinalPrice DECIMAL(10,2);
  DECLARE v_TotalTicketAmount DECIMAL(10,2) DEFAULT 0;
  DECLARE v_TotalSnackAmount DECIMAL(10,2) DEFAULT 0;
  DECLARE v_PaymentID INT;
  DECLARE v_BookingSnackID INT;
  DECLARE v_SnackID INT;
  DECLARE v_SnackPrice DECIMAL(10,2);
  DECLARE v_SeatStatus VARCHAR(20);
  DECLARE v_ErrorMessage VARCHAR(255);

  DECLARE v_ScreeningID INT;
  DECLARE v_SeatID INT;
  DECLARE v_SnackName VARCHAR(100);
  DECLARE v_Quantity INT;

  DECLARE i INT DEFAULT 0;
  DECLARE seat_count INT;
  DECLARE snack_count INT;

  -- Check if the customer already exists
  SELECT CustomerID INTO v_CustomerID
  FROM Customers
  WHERE PhoneNumber = p_Phone
  LIMIT 1;

  IF v_CustomerID IS NULL THEN
    INSERT INTO Customers (CustomerName, PhoneNumber, CustomerEmail)
    VALUES (p_CustomerName, p_Phone, p_Email);
    SET v_CustomerID = LAST_INSERT_ID();
  END IF;

  -- Create a new booking
  INSERT INTO Bookings (CustomerID, BookingDate)
  VALUES (v_CustomerID, NOW());
  SET v_BookingID = LAST_INSERT_ID();

  -- Apply discount code (if any)
  IF p_DiscountCode IS NOT NULL THEN
    SELECT DiscountID, Percentage
    INTO v_DiscountID, v_DiscountPercent
    FROM Discounts
    WHERE Code = p_DiscountCode AND ValidUntil >= CURDATE()
    LIMIT 1;
    IF v_DiscountID IS NULL THEN
      SET v_DiscountID = 1;
      SET v_DiscountPercent = 0;
    END IF;
  END IF;

  -- Handle seats from JSON
  SET seat_count = JSON_LENGTH(p_SeatJSON);
  SET i = 0;

  WHILE i < seat_count DO
    SET v_ScreeningID = JSON_EXTRACT(p_SeatJSON, CONCAT('$[', i, '][0]'));
    SET v_SeatID = JSON_EXTRACT(p_SeatJSON, CONCAT('$[', i, '][1]'));

    -- Check seat status
    SELECT Status INTO v_SeatStatus
    FROM ScreeningSeats
    WHERE ScreeningID = v_ScreeningID AND SeatID = v_SeatID;

    IF v_SeatStatus = 'Booked' THEN
      SET v_ErrorMessage = CONCAT('Seat ', v_SeatID, ' is already booked. Please choose another seat.');
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_ErrorMessage;
    END IF;

    -- Get necessary information
    SELECT sm.SeatTypeID
    INTO v_SeatTypeID
    FROM SeatMap sm
    JOIN ScreeningSeats ss ON sm.SeatID = ss.SeatID
    WHERE ss.ScreeningID = v_ScreeningID AND ss.SeatID = v_SeatID;

    SELECT PricingID, Price
    INTO v_PricingID, v_TicketPrice
    FROM TicketPrice
    WHERE SeatTypeID = v_SeatTypeID;

    SET v_FinalPrice = v_TicketPrice * (1 - v_DiscountPercent / 100);
    SET v_TotalTicketAmount = v_TotalTicketAmount + v_FinalPrice;

    -- Insert into BookingTickets
    INSERT INTO BookingTickets (BookingID, ScreeningID, SeatID, PricingID, FinalPrice, DiscountID)
    VALUES (v_BookingID, v_ScreeningID, v_SeatID, v_PricingID, v_FinalPrice, v_DiscountID);

    -- Update seat status
    UPDATE ScreeningSeats
    SET Status = 'Booked'
    WHERE ScreeningID = v_ScreeningID AND SeatID = v_SeatID;

    SET i = i + 1;
  END WHILE;

  -- Handle snack (if selected)
  IF p_SnackJSON IS NOT NULL AND JSON_LENGTH(p_SnackJSON) > 0 THEN
    INSERT INTO BookingSnacks (BookingID, TotalAmount)
    VALUES (v_BookingID, 0);
    SET v_BookingSnackID = LAST_INSERT_ID();

    SET i = 0;
    SET snack_count = JSON_LENGTH(p_SnackJSON);

    WHILE i < snack_count DO
      SET v_SnackName = JSON_UNQUOTE(JSON_EXTRACT(p_SnackJSON, CONCAT('$[', i, '][0]')));
      SET v_Quantity = JSON_EXTRACT(p_SnackJSON, CONCAT('$[', i, '][1]'));

      SELECT SnackID, Price
      INTO v_SnackID, v_SnackPrice
      FROM Snacks
      WHERE SnackName = v_SnackName
      LIMIT 1;

      IF v_SnackID IS NOT NULL THEN
        INSERT INTO BookingSnackDetails (BookingSnackID, SnackID, Quantity)
        VALUES (v_BookingSnackID, v_SnackID, v_Quantity);

        SET v_TotalSnackAmount = v_TotalSnackAmount + (v_SnackPrice * v_Quantity);
      END IF;

      SET i = i + 1;
    END WHILE;

    UPDATE BookingSnacks
    SET TotalAmount = v_TotalSnackAmount
    WHERE BookingSnackID = v_BookingSnackID;
  END IF;

  -- Payment
  INSERT INTO Payments (PaymentDate, Amount, PaymentMethod, Status, CustomerID, BookingID)
  VALUES (NOW(), v_TotalTicketAmount + v_TotalSnackAmount, p_PaymentMethod, 'Paid', v_CustomerID, v_BookingID);
  SET v_PaymentID = LAST_INSERT_ID();

  -- Invoice
  INSERT INTO Invoice (TotalAmount, InvoiceDate, PaymentID)
  VALUES (v_TotalTicketAmount + v_TotalSnackAmount, NOW(), v_PaymentID);
END$$

DELIMITER ;

-- 3. Stored procedure to cancel a booking

DELIMITER $$

CREATE PROCEDURE CancelBooking (
    IN p_BookingID INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_ScreeningID INT;
    DECLARE v_SeatID INT;
    DECLARE cur CURSOR FOR
        SELECT ScreeningID, SeatID FROM BookingTickets WHERE BookingID = p_BookingID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Only proceed if booking is not cancelled
    IF EXISTS (SELECT 1 FROM Bookings WHERE BookingID = p_BookingID AND IsCancelled = FALSE) THEN
        
        UPDATE Bookings
        SET IsCancelled = TRUE
        WHERE BookingID = p_BookingID;
        
        OPEN cur;
        
        read_loop: LOOP
            FETCH cur INTO v_ScreeningID, v_SeatID;
            IF done THEN
                LEAVE read_loop;
            END IF;
            
            DELETE FROM BookingTickets
            WHERE BookingID = p_BookingID AND ScreeningID = v_ScreeningID AND SeatID = v_SeatID;
            
            UPDATE ScreeningSeats
            SET Status = 'Available'
            WHERE ScreeningID = v_ScreeningID AND SeatID = v_SeatID;
        END LOOP;
        
        CLOSE cur;
        
        SELECT CONCAT('Booking ', p_BookingID, ' has been cancelled successfully.') AS Message;
        
    ELSE
        SELECT CONCAT('Booking ', p_BookingID, ' does not exist or is already cancelled.') AS Message;
    END IF;
END $$

DELIMITER ;

-- 4. Stored procedure to create a new screening
DELIMITER $$

CREATE PROCEDURE CreateScreening (
	IN p_ScreeningDate DATE,
    IN p_ScreeningTime TIME, 
    IN p_MovieID INT,
    IN p_RoomID INT
)
BEGIN
	DECLARE v_NextID INT;

    -- Find next ScreeningID
    SELECT IFNULL(MAX(ScreeningID), 0) + 1 INTO v_NextID FROM Screenings;

    -- Insert new screening
    INSERT INTO Screenings (ScreeningID, ScreeningDate, ScreeningTime, MovieID, RoomID)
    VALUES (v_NextID, p_ScreeningDate, p_ScreeningTime, p_MovieID, p_RoomID);
END $$

DELIMITER ;

-- 5. Stored procedure to update the seat status (Booked or Available)
DELIMITER $$

CREATE PROCEDURE UpdateSeatStatus (
	IN p_SeatID INT,
    IN p_ScreeningID INT,
    IN p_AvailableStatus ENUM('Available', 'Booked')
)
BEGIN 
    UPDATE ScreeningSeats 
    SET Status = p_AvailableStatus 
    WHERE SeatID = p_SeatID AND ScreeningID = p_ScreeningID;
END $$

DELIMITER ;

--  6. Stored procedure to create a new discount code
DELIMITER $$

CREATE PROCEDURE CreateDiscount (
	IN p_Code VARCHAR(50),
    IN p_Percentage DECIMAL(10,2),
    IN p_ValidUntil DATE
) 
BEGIN 
	DECLARE v_NewID INT;

    -- Get next DiscountID
    SELECT IFNULL(MAX(DiscountID), 0) + 1 INTO v_NewID FROM Discounts;

    -- Insert new discount record
	INSERT INTO Discounts (DiscountID, Code, Percentage, ValidUntil)
    VALUES (v_NewID, p_Code, p_Percentage, p_ValidUntil);
END $$

DELIMITER ;

-- 1. Trigger to update invoice date after a payment is made
DELIMITER $$
CREATE TRIGGER trg_UpdateInvoiceAfterPayment
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
  UPDATE Invoice
  SET InvoiceDate = NEW.PaymentDate
  WHERE PaymentID = NEW.PaymentID;
END$$
DELIMITER ;

-- 2. Trigger to prevent booking tickets for past showtimes
DELIMITER $$

CREATE TRIGGER trg_PreventLateBooking
BEFORE INSERT ON BookingTickets
FOR EACH ROW
BEGIN
  DECLARE v_ShowDate DATE;
  DECLARE v_ShowTime TIME;

  SELECT ScreeningDate, ScreeningTime
  INTO v_ShowDate, v_ShowTime
  FROM Screenings
  WHERE ScreeningID = NEW.ScreeningID;

  IF CONCAT(v_ShowDate, ' ', v_ShowTime) <= NOW() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot book tickets for a showtime that has already started';
  END IF;
END$$

DELIMITER ;


-- 3. Trigger to log changes made to screenings
CREATE TABLE ScreeningChangesLog (
  ScreeningChangesID INT AUTO_INCREMENT PRIMARY KEY,
  ScreeningID INT,
  ChangedAt DATETIME,
  OldDate DATE,
  OldTime TIME,
  NewDate DATE,
  NewTime TIME,
  OldRoomID INT,
  NewRoomID INT,
  FOREIGN KEY (ScreeningID) REFERENCES Screenings(ScreeningID) ON DELETE CASCADE
);

DELIMITER $$
CREATE TRIGGER trg_LogScreeningChanges
BEFORE UPDATE ON Screenings
FOR EACH ROW
BEGIN
  IF OLD.ScreeningDate != NEW.ScreeningDate 
     OR OLD.ScreeningTime != NEW.ScreeningTime 
     OR OLD.RoomID != NEW.RoomID THEN
     
    INSERT INTO ScreeningChangesLog (
      ScreeningID, ChangedAt,
      OldDate, OldTime, NewDate, NewTime,
      OldRoomID, NewRoomID
    )
    VALUES (
      OLD.ScreeningID, NOW(),
      OLD.ScreeningDate, OLD.ScreeningTime,
      NEW.ScreeningDate, NEW.ScreeningTime,
      OLD.RoomID, NEW.RoomID
    );
    
  END IF;
END$$

DELIMITER ;

-- 4. Trigger to log high-revenue invoices
CREATE TABLE RevenueAlerts (
  AlertID INT AUTO_INCREMENT PRIMARY KEY,
  InvoiceID INT,
  Amount DECIMAL(10,2),
  AlertTime DATETIME,
  FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID) ON DELETE CASCADE
);

DELIMITER $$
CREATE TRIGGER trg_NotifyHighRevenue
AFTER INSERT ON Invoice
FOR EACH ROW
BEGIN
  IF NEW.TotalAmount > 5000000 THEN
    INSERT INTO RevenueAlerts (InvoiceID, Amount, AlertTime)
    VALUES (NEW.InvoiceID, NEW.TotalAmount, NOW());
  END IF;
END$$
DELIMITER ;

DROP USER 'admin_cinema'@'localhost';
CREATE USER 'admin_cinema'@'localhost' IDENTIFIED BY 'Admincinema1';
DROP USER 'ticket_clerk'@'localhost';
CREATE USER 'ticket_clerk'@'localhost' IDENTIFIED BY 'Ticketclerk1';

	-- Grant full privileges (admin access to entire system)
GRANT ALL PRIVILEGES ON CinemaDB.* TO 'admin_cinema'@'localhost';
GRANT EXECUTE ON PROCEDURE CinemaDB.BookTicketsWithOptionalSnack TO 'admin_cinema'@'localhost';
GRANT EXECUTE ON PROCEDURE CinemaDB.CancelBooking TO 'admin_cinema'@'localhost';
GRANT EXECUTE ON PROCEDURE CinemaDB.ApplyDiscountCode TO 'admin_cinema'@'localhost';

	-- Allow viewing and adding customers, no UPDATE needed
GRANT SELECT, INSERT ON CinemaDB.Customers TO 'ticket_clerk'@'localhost';

	-- Allow creating bookings, adding tickets, and snacks
GRANT SELECT, INSERT ON CinemaDB.Bookings TO 'ticket_clerk'@'localhost';
GRANT SELECT, INSERT ON CinemaDB.BookingTickets TO 'ticket_clerk'@'localhost';
GRANT SELECT, INSERT ON CinemaDB.BookingSnacks TO 'ticket_clerk'@'localhost';
GRANT SELECT, INSERT ON CinemaDB.BookingSnackDetails TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Movies TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Screenings TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.CinemaRooms TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.ScreeningSeats TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.SeatMap TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Snacks TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Discounts TO 'ticket_clerk'@'localhost';
GRANT EXECUTE ON PROCEDURE CinemaDB.BookTicketsWithOptionalSnack TO 'ticket_clerk'@'localhost';


	-- Allow updating seat status when booking
GRANT SELECT, UPDATE ON CinemaDB.ScreeningSeats TO 'ticket_clerk'@'localhost';

	-- Allow creating payments
GRANT SELECT, INSERT ON CinemaDB.Payments TO 'ticket_clerk'@'localhost';

	-- Allow viewing ticket and snack prices for selling
GRANT SELECT ON CinemaDB.TicketPrice TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Snacks TO 'ticket_clerk'@'localhost';

	-- Allow viewing screening and seat information
GRANT SELECT ON CinemaDB.Screenings TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.SeatMap TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.SeatType TO 'ticket_clerk'@'localhost';
GRANT SELECT ON CinemaDB.Movies TO 'ticket_clerk'@'localhost';


-- 2. Public view without revealing personal information (phone/email)
CREATE VIEW vw_PublicCustomerInfo AS
SELECT 
    CustomerID,
    CustomerName,
    CASE 
        WHEN LOCATE('@', CustomerEmail) > 2 THEN 
            CONCAT(
                LEFT(CustomerEmail, 2),
                REPEAT('*', LOCATE('@', CustomerEmail) - 2),
                SUBSTRING(CustomerEmail, LOCATE('@', CustomerEmail))
            )
        ELSE 
            CONCAT(
                LEFT(CustomerEmail, 1),
                '*',
                SUBSTRING(CustomerEmail, LOCATE('@', CustomerEmail))
            )
    END AS MaskedEmail,
    CONCAT(
        LEFT(PhoneNumber, 3),
        '***',
        RIGHT(PhoneNumber, 4)
    ) AS MaskedPhoneNumber
FROM Customers;


-- 3. Log user actions
	-- Create log table
CREATE TABLE UserActionLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    UserName VARCHAR(100),
    ActionType VARCHAR(50),
    TableAffected VARCHAR(100),
    ActionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Details TEXT
);

DELIMITER $$
	-- Trigger for Bookings
CREATE TRIGGER trg_after_booking_insert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'INSERT', 
    'Bookings', 
    CONCAT('BookingID: ', NEW.BookingID)
	);
END $$

CREATE TRIGGER trg_after_booking_update
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'UPDATE', 
    'Bookings', 
    CONCAT('BookingID: ', NEW.BookingID)
    );
END $$

CREATE TRIGGER trg_after_booking_delete
AFTER DELETE ON Bookings
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'DELETE', 
    'Bookings', 
    CONCAT('BookingID: ', OLD.BookingID)
    );
END $$

	-- Trigger for Customers:
CREATE TRIGGER trg_after_customer_insert
AFTER INSERT ON Customers
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'INSERT', 
    'Customers', 
    CONCAT('CustomerID: ', NEW.CustomerID)
    );
END $$

CREATE TRIGGER trg_after_customer_update
AFTER UPDATE ON Customers
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'UPDATE', 
    'Customers', 
    CONCAT('CustomerID: ', NEW.CustomerID)
    );
END $$

CREATE TRIGGER trg_after_customer_delete
AFTER DELETE ON Customers
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'DELETE', 
    'Customers', 
    CONCAT('CustomerID: ', OLD.CustomerID)
    );
END $$

	-- Trigger for BookingTickets:
CREATE TRIGGER trg_after_bookingtickets_insert
AFTER INSERT ON BookingTickets
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'INSERT', 
    'BookingTickets', 
    CONCAT('BookingTicketsID: ', NEW.BookingTicketsID)
    );
END $$

CREATE TRIGGER trg_after_bookingtickets_update
AFTER UPDATE ON BookingTickets
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'UPDATE', 
    'BookingTickets', 
    CONCAT('BookingTicketsID: ', NEW.BookingTicketsID)
    );
END $$

CREATE TRIGGER trg_after_bookingtickets_delete
AFTER DELETE ON BookingTickets
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'DELETE', 
    'BookingTickets', 
    CONCAT('BookingTicketsID: ', OLD.BookingTicketsID)
    );
END $$

	-- Trigger for BookingSnackDetails:
CREATE TRIGGER trg_after_bookingsnackdetails_insert
AFTER INSERT ON BookingSnackDetails
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'INSERT', 
    'BookingSnackDetails', 
    CONCAT('BookingSnackDetailID: ', NEW.BookingSnackDetailID)
    );
END $$

CREATE TRIGGER trg_after_bookingsnackdetails_update
AFTER UPDATE ON BookingSnackDetails
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'UPDATE', 
    'BookingSnackDetails', 
    CONCAT('BookingSnackDetailID: ', NEW.BookingSnackDetailID)
    );
END $$

CREATE TRIGGER trg_after_bookingsnackdetails_delete
AFTER DELETE ON BookingSnackDetails
FOR EACH ROW
BEGIN
  INSERT INTO UserActionLog (UserName, ActionType, TableAffected, Details)
  VALUES (
	SESSION_USER(), 
    'DELETE', 
    'BookingSnackDetails', 
    CONCAT('BookingSnackDetailID: ', OLD.BookingSnackDetailID)
    );
END $$

DELIMITER ;
