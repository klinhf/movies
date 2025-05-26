USE CinemaDB;

-- 1. User Privileges
	-- Create users
CREATE USER 'admin_cinema'@'localhost' IDENTIFIED BY 'Admincinema1';
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