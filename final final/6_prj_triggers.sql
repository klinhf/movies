USE CinemaDB;

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