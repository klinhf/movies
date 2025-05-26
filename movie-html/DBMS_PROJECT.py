import mysql.connector
from datetime import datetime
from tabulate import tabulate
import json

def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Khanhlinh1003@",
        database="CinemaDB",
        auth_plugin='mysql_native_password'  # Add this line to specify authentication plugin
    )

try:
    db = get_connection()
    cursor = db.cursor()
    print("Database connection successful!")
except mysql.connector.Error as err:
    print(f"Database connection error: {err}")
    cursor = None
    db = None

def book_tickets_with_optional_snack(customer_name, phone, email, payment_method,
                                     seat_list, snack_list=None, discount_code=None):
    try:
        seat_json = json.dumps(seat_list)
        snack_json = json.dumps(snack_list) if snack_list else None

        args = (
            customer_name,
            phone,
            email,
            payment_method,
            seat_json,
            snack_json,
            discount_code
        )

        cursor.callproc("BookTicketsWithOptionalSnack", args)
        db.commit()
        print("Booking successful!")

    except mysql.connector.Error as err:
        print("Error during booking:", err)

def cancel_booking(booking_id):
    try:
        cursor.callproc("CancelBooking", (booking_id,))
        db.commit()
        print("Booking cancelled successfully.")
    except mysql.connector.Error as err:
        print("Error:", err)

def apply_discount_code(discount_code, booking_ticket_id):
    try:
        cursor.callproc("ApplyDiscountCode", (discount_code, booking_ticket_id))
        for result in cursor.stored_results():
            print(result.fetchall())
        db.commit()
    except mysql.connector.Error as err:
        print("Error:", err)

def get_screening_report():
    query = """
    SELECT 
        s.ScreeningID,
        m.MovieTitle,
        m.Genre,
        m.DurationMinutes,
        r.RoomName,
        r.RoomType,
        r.Capacity,
        s.ScreeningDate,
        s.ScreeningTime,
        COUNT(bt.BookingTicketsID) AS TicketsSold,
        COALESCE(SUM(tp.Price), 0) AS TotalTicketRevenue
    FROM Screenings s
    JOIN Movies m ON s.MovieID = m.MovieID
    JOIN CinemaRooms r ON s.RoomID = r.RoomID
    LEFT JOIN BookingTickets bt ON s.ScreeningID = bt.ScreeningID
    LEFT JOIN TicketPrice tp ON bt.PricingID = tp.PricingID
    GROUP BY s.ScreeningID, m.MovieTitle, m.Genre, m.DurationMinutes,
             r.RoomName, r.RoomType, r.Capacity, s.ScreeningDate, s.ScreeningTime
    ORDER BY s.ScreeningDate, s.ScreeningTime;
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    headers = [
        "Screening ID", "Movie Title", "Genre", "Duration (min)",
        "Room", "Room Type", "Capacity", "Date", "Time", 
        "Tickets Sold", "Total Revenue"
    ]
    print(tabulate(rows, headers=headers, tablefmt="grid"))

def get_sales_report():
    query = """
    SELECT 
        DATE(p.PaymentDate) AS PaymentDate,
        COUNT(p.PaymentID) AS TotalPayments,
        COALESCE(SUM(tp.Price), 0) AS TicketRevenue,
        COALESCE(SUM(bs.TotalAmount), 0) AS SnackRevenue,
        SUM(p.Amount) AS TotalRevenue
    FROM Payments p
    LEFT JOIN Bookings b ON p.BookingID = b.BookingID
    LEFT JOIN BookingTickets bt ON b.BookingID = bt.BookingID
    LEFT JOIN TicketPrice tp ON bt.PricingID = tp.PricingID
    LEFT JOIN BookingSnacks bs ON b.BookingID = bs.BookingID
    WHERE p.Status = 'Paid'
    GROUP BY DATE(p.PaymentDate)
    ORDER BY PaymentDate DESC;
    """
    cursor.execute(query)
    raw_rows = cursor.fetchall()

    # Format rows to avoid scientific notation
    formatted_rows = [
        [
            row[0],                                
            row[1],                               
            f"{row[2]:,.0f}",              
            f"{row[3]:,.0f}",                     
            f"{row[4]:,.0f}"                   
        ]
        for row in raw_rows
    ]

    headers = [
        "Payment Date",
        "Total Successful Payments",
        "Ticket Revenue (VND)",
        "Snack Revenue (VND)",
        "Total Revenue (VND)"
    ]

    print(tabulate(formatted_rows, headers=headers, tablefmt="grid"))

if db is not None and db.is_connected():
    if cursor is not None:
        cursor.close()
    db.close()
    print("Database connection closed.")