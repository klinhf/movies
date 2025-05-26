USE CinemaDB;

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