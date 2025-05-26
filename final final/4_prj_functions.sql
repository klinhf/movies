Use CinemaDB;
-- 1. Function to calculate fill rate of each screening
DELIMITER $$
CREATE FUNCTION fn_FillRate(in_screeningID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE totalSeats INT;
    DECLARE bookedSeats INT;
    DECLARE fillRate DECIMAL(5,2);
    SELECT COUNT(*) INTO totalSeats
    FROM screeningseats
    WHERE ScreeningID = in_screeningID;
	SELECT COUNT(*) INTO bookedSeats
    FROM screeningseats
    WHERE ScreeningID = in_screeningID AND Status = 'Booked';
    IF totalSeats > 0 THEN SET fillRate = (bookedSeats / totalSeats) * 100;
    ELSE SET fillRate = 0.00;
    END IF;
    RETURN fillRate;
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
        SELECT SUM(unique_payments.Amount) INTO TotalRevenue
        FROM (
            SELECT DISTINCT p.PaymentID, p.Amount
            FROM payments p
            JOIN BookingTickets bt ON bt.BookingID = p.BookingID
            JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
            WHERE s.MovieID = ID
        ) AS unique_payments;
    ELSEIF LOWER(scope) = 'screening' THEN
        SELECT SUM(unique_payments.Amount) INTO TotalRevenue
        FROM (
            SELECT DISTINCT p.PaymentID, p.Amount
            FROM payments p
            JOIN BookingTickets bt ON bt.BookingID = p.BookingID
            JOIN Screenings s ON bt.ScreeningID = s.ScreeningID
            WHERE s.ScreeningID = ID
        ) AS unique_payments;
    ELSEIF LOWER(scope) = 'customer' THEN
        SELECT SUM(payments.Amount) INTO TotalRevenue
        FROM payments p
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
    Select Sum(quantity) into TotalSnack
    From BookingSnackDetails
    Where SnackID = in_snackID;
	Return IFNULL (TotalSnack, 0);
END $$
DELIMITER ;

-- 4. Function check for valid discount or not
DELIMITER $$
CREATE FUNCTION fn_ValidateDiscount(in_code VARCHAR(10))
RETURNS TINYINT
DETERMINISTIC
BEGIN
    DECLARE isValid TINYINT DEFAULT 0;
    SELECT COUNT(*)
    INTO isValid
    FROM discounts d
    WHERE d.Code = in_code AND CURDATE() <= ValidUntil;
    RETURN isValid;
END $$
DELIMITER ;