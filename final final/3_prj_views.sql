USE CinemaDB;
-- 1. View screenings on selected day
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
	JOIN Screeningseats ss ON s.ScreeningID = ss.ScreeningID
	WHERE ss.Status = 'Available';

-- 3. View daily revenue
CREATE VIEW vw_DailyRevenue AS
	SELECT
		DATE(p.PaymentDate) AS RevenueDate,
		SUM(p.Amount) AS TotalRevenue,
		COUNT(p.PaymentID) AS NumberOfPayments
	FROM payments p
	GROUP BY DATE(p.PaymentDate)
	ORDER BY TotalRevenue DESC;

-- 4. View booking history of customer
CREATE VIEW vw_UserBookingHistory AS
	SELECT  c.CustomerID, c.CustomerName, c.PhoneNumber, b.BookingID, b.BookingDate,
			m.MovieTitle, s.ScreeningDate, s.ScreeningTime, s.RoomID
	FROM Customers c
	JOIN Bookings b ON c.CustomerID = b.CustomerID
	JOIN Bookingtickets bt ON bt.BookingID = b.BookingID
	JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
	JOIN Movies m ON s.MovieID = m.MovieID;

-- 5. View number of tickets sold by movie
CREATE VIEW vw_TicketsSoldByMovie AS
	SELECT m.MovieID, m.MovieTitle, COUNT(*) AS TicketSold
	FROM movies m
	JOIN screenings s ON m.MovieID = s.MovieID
	JOIN screeningseats ss ON s.ScreeningID = ss.ScreeningID
	WHERE ss.Status NOT LIKE 'Available'
	GROUP BY m.MovieID, m.MovieTitle;

-- 6. View frequent customers
CREATE VIEW vw_FrequentCustomers AS
	SELECT c.CustomerID, c.CustomerName, c.PhoneNumber, COUNT(b.BookingID) AS TotalBookings
	FROM customers c
	JOIN Bookings b ON c.CustomerID = b.CustomerID
	GROUP BY c.CustomerID, c.CustomerName, c.PhoneNumber
	ORDER BY TotalBookings DESC;

-- 7. View revenue by room    
CREATE VIEW vw_RoomRevenueStats AS
	SELECT cr.RoomID, cr.RoomName,
		COUNT(DISTINCT bt.BookingID) AS TotalBookings,
		SUM(p.Amount) AS TotalRevenue
	FROM cinemarooms cr 
	JOIN screenings s ON cr.RoomID = s.RoomID
	JOIN Bookingtickets bt ON s.ScreeningID = bt.ScreeningID
	JOIN Bookings b ON bt.BookingID = b.BookingID
	JOIN payments p ON b.BookingID = p.BookingID
	GROUP BY cr.RoomID, cr.RoomName
	ORDER BY TotalRevenue DESC;
