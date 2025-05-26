Use CinemaDB;
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
