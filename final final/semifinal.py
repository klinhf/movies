import streamlit as st
import mysql.connector
import json
import pandas as pd
from datetime import datetime

# Custom CSS for cinematic theme with deep red, muted gold, and black
st.markdown("""
<style>
    /* Main container */
    .main {
        background: linear-gradient(to bottom, #000000, #1c1c1c);
        padding: 30px;
        border-radius: 15px;
        color: #e0e0e0;
        font-family: 'Arial', sans-serif;
    }

    /* Title and headers */
    h1 {
        color: #B8860B;
        text-align: center;
        font-size: 2.8em;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
        margin-bottom: 25px;
    }
    h2, h3 {
        color: #B8860B;
        font-weight: bold;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.6);
    }

    /* Sidebar */
    .sidebar .sidebar-content {
        background-color: #1c1c1c;
        border-right: 2px solid #B8860B;
        padding: 20px;
    }
    .sidebar .stSelectbox label {
        color: #B8860B;
        font-weight: bold;
    }

    /* Input fields */
    .stTextInput>div>input, .stTextArea>div>textarea, .stNumberInput>div>input {
        background-color: #2a2a2a;
        color: #e0e0e0;
        border: 1px solid #B8860B;
        border-radius: 8px;
        padding: 12px;
        transition: border-color 0.3s;
    }
    .stTextInput>div>input:focus, .stTextArea>div>textarea:focus, .stNumberInput>div>input:focus {
        border-color: #8B0000;
        box-shadow: 0 0 5px rgba(139, 0, 0, 0.5);
    }

    /* Selectbox */
    .stSelectbox>div>div {
        background-color: #2a2a2a;
        color: #e0e0e0;
        border: 1px solid #B8860B;
        border-radius: 8px;
    }

    /* Buttons */
    .stButton>button {
        background-color: #8B0000;
        color: #ffffff;
        border: none;
        border-radius: 8px;
        padding: 12px 24px;
        font-size: 16px;
        font-weight: bold;
        transition: background-color 0.3s, transform 0.2s;
    }
    .stButton>button:hover {
        background-color: #6B0000;
        transform: scale(1.05);
    }

    /* Dataframe */
    .stDataFrame {
        background-color: #2a2a2a;
        border: 1px solid #B8860B;
        border-radius: 10px;
        padding: 15px;
        color: #e0e0e0;
    }
    .stDataFrame th {
        color: #B8860B;
        background-color: #1c1c1c;
    }
    .stDataFrame td {
        color: #e0e0e0;
    }

    /* Download button */
    .stDownloadButton>button {
        background-color: #B8860B;
        color: #000000;
        border-radius: 8px;
        padding: 10px 20px;
        font-weight: bold;
    }
    .stDownloadButton>button:hover {
        background-color: #986F0A;
    }

    /* Form */
    .stForm {
        background-color: #1c1c1c;
        padding: 20px;
        border-radius: 10px;
        border: 1px solid #B8860B;
    }

    /* Footer */
    .footer {
        text-align: center;
        color: #e0e0e0;
        margin-top: 30px;
        font-size: 14px;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.6);
    }

    /* Animations */
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    .stMarkdown, .stForm, .stDataFrame {
        animation: fadeIn 0.5s ease-in;
    }

    /* Custom icons */
    .section-icon {
        margin-right: 10px;
        font-size: 1.2em;
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state for authentication
if 'authenticated' not in st.session_state:
    st.session_state.authenticated = False
    st.session_state.user_role = None
    st.session_state.username = None
    st.session_state.db = None

# Database connection
def init_db_connection(username, password):
    try:
        db = mysql.connector.connect(
            host="localhost",
            user=username,
            password=password,
            database="CinemaDB"
        )
        if username in ['admin_cinema', 'ticket_clerk']:
            return db, username
        else:
            db.close()
            return None, None
    except mysql.connector.Error as err:
        st.error(f"🔴 Login failed: {err}")
        return None, None

# Function to book tickets
def book_tickets_with_optional_snack(db, customer_name, phone, email, payment_method, seat_list, snack_list=None, discount_code=None):
    cursor = db.cursor()
    try:
        seat_json = json.dumps(seat_list)
        snack_json = json.dumps(snack_list) if snack_list else None

        args = (customer_name, phone, email, payment_method, seat_json, snack_json, discount_code)
        cursor.callproc("BookTicketsWithOptionalSnack", args)
        db.commit()
        st.success("🎬 Booking successful! Enjoy your movie!")
    except mysql.connector.Error as err:
        st.error(f"❌ Error during booking: {err}")
    finally:
        cursor.close()

# Function to cancel booking
def cancel_booking(db, booking_id):
    cursor = db.cursor()
    try:
        cursor.callproc("CancelBooking", (booking_id,))
        db.commit()
        st.success("🎟️ Booking cancelled successfully.")
    except mysql.connector.Error as err:
        st.error(f"❌ Error: {err}")
    finally:
        cursor.close()

# Function to apply discount code
def apply_discount_code(db, discount_code, booking_ticket_id):
    cursor = db.cursor()
    try:
        cursor.callproc("ApplyDiscountCode", (discount_code, booking_ticket_id))
        for result in cursor.stored_results():
            st.write(result.fetchall())
        db.commit()
        st.success("💸 Discount applied successfully!")
    except mysql.connector.Error as err:
        st.error(f"❌ Error: {err}")
    finally:
        cursor.close()

# Function to get screening report
def get_screening_report(db):
    cursor = db.cursor()
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
    cursor.close()
    return pd.DataFrame(rows, columns=headers)

# Function to get sales report
def get_sales_report(db):
    cursor = db.cursor()
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
    rows = cursor.fetchall()
    headers = [
        "Payment Date", "Total Successful Payments", 
        "Ticket Revenue (VND)", "Snack Revenue (VND)", "Total Revenue (VND)"
    ]
    cursor.close()
    return pd.DataFrame(rows, columns=headers)

# Streamlit app
st.title("🎥 Cinema Royale")
st.markdown("Step into the world of cinema with our premium booking experience!")

# Login page
if not st.session_state.authenticated:
    st.header("🔐 Login to Cinema Royale")
    with st.form("login_form"):
        st.subheader("User Credentials")
        username = st.text_input("Username", placeholder="Enter your username")
        password = st.text_input("Password", placeholder="Enter your password", type="password")
        submit = st.form_submit_button("🎥 Login")

        if submit:
            if not username or not password:
                st.error("❌ Please enter both username and password.")
            else:
                db, authenticated_username = init_db_connection(username, password)
                if db and authenticated_username:
                    st.session_state.authenticated = True
                    st.session_state.user_role = authenticated_username
                    st.session_state.username = authenticated_username
                    st.session_state.db = db
                    st.success(f"🎬 Welcome, {username}! You are logged in.")
                    st.rerun()
                else:
                    st.error("❌ Invalid username or password.")
else:
    # Main app content
    db = st.session_state.db
    if not db or db.is_connected() is False:
        st.error("❌ Database connection lost. Please log in again.")
        st.session_state.authenticated = False
        st.session_state.user_role = None
        st.session_state.username = None
        st.session_state.db = None
        st.rerun()
    else:
        st.markdown(f"Logged in as: **{st.session_state.username}**")
        if st.button("🚪 Logout"):
            if db:
                db.close()
            st.session_state.authenticated = False
            st.session_state.user_role = None
            st.session_state.username = None
            st.session_state.db = None
            st.rerun()

        # Define menu based on role
        if st.session_state.user_role == "admin_cinema":
            menu = ["Book Tickets", "Cancel Booking", "Apply Discount", "Screening Report", "Sales Report"]
        else:  # ticket_clerk
            menu = ["Book Tickets"]

        # Sidebar for navigation
        st.sidebar.header("🎞️ Menu")
        choice = st.sidebar.selectbox("Select Feature", menu, format_func=lambda x: f"🎬 {x}")

        if choice == "Book Tickets":
            st.header("🎟️ Reserve Your Seats")
            with st.form("booking_form"):
                st.subheader("👤 Guest Information")
                col1, col2 = st.columns(2)
                with col1:
                    customer_name = st.text_input("Full Name", placeholder="Enter your full name")
                    phone = st.text_input("Phone Number", placeholder="e.g., 1234567890")
                with col2:
                    email = st.text_input("Email Address", placeholder="e.g., user@example.com")
                    payment_method = st.selectbox("Payment Method", ["Credit Card", "Debit Card", "Cash"], help="Select your preferred payment method")

                st.subheader("🪑 Seat Selection")
                st.markdown("Enter seats in format: [[ScreeningID, SeatID], ...]")
                seat_list_input = st.text_area("Seat List", placeholder="e.g., [[9, 76], [9, 77]]", height=100)

                st.subheader("🍿 Snack Selection (Optional)")
                st.markdown("Enter snacks in format: [[SnackName, Quantity], ...]")
                snack_list_input = st.text_area("Snack List", placeholder="e.g., [['Popcorn', 2], ['Coke', 1]]", height=100, value="")

                st.subheader("🎁 Discount Code")
                discount_code = st.text_input("Discount Code (Optional)", placeholder="e.g., STUDENT15")

                submit = st.form_submit_button("🎥 Book Now")
                
                if submit:
                    try:
                        seat_list = json.loads(seat_list_input) if seat_list_input else []
                        snack_list = json.loads(snack_list_input) if snack_list_input else None
                        if not customer_name or not phone or not email or not payment_method or not seat_list:
                            st.error("❌ Please fill in all required fields.")
                        else:
                            book_tickets_with_optional_snack(
                                db, customer_name, phone, email, payment_method, 
                                seat_list, snack_list, discount_code
                            )
                    except json.JSONDecodeError:
                        st.error("❌ Invalid JSON format for seat or snack list.")

        elif choice == "Cancel Booking" and st.session_state.user_role == "admin_cinema":
            st.header("🗑️ Cancel Booking")
            with st.form("cancel_form"):
                booking_id = st.number_input("Booking ID", min_value=1, step=1, format="%d", help="Enter the Booking ID to cancel")
                submit = st.form_submit_button("🚫 Cancel Booking")
                if submit:
                    cancel_booking(db, booking_id)

        elif choice == "Apply Discount" and st.session_state.user_role == "admin_cinema":
            st.header("💸 Apply Discount Code")
            with st.form("discount_form"):
                col1, col2 = st.columns(2)
                with col1:
                    discount_code = st.text_input("Discount Code", placeholder="e.g., FLASH25")
                with col2:
                    booking_ticket_id = st.number_input("Booking Ticket ID", min_value=1, step=1, format="%d", help="Enter the Booking Ticket ID")
                submit = st.form_submit_button("🎁 Apply Discount")
                if submit:
                    if not discount_code:
                        st.error("❌ Please enter a discount code.")
                    else:
                        apply_discount_code(db, discount_code, booking_ticket_id)

        elif choice == "Screening Report" and st.session_state.user_role == "admin_cinema":
            st.header("📊 Screening Report")
            df = get_screening_report(db)
            st.dataframe(df, use_container_width=True)
            st.download_button(
                label="📥 Download Report",
                data=df.to_csv(index=False).encode('utf-8'),
                file_name="screening_report.csv",
                mime="text/csv"
            )

        elif choice == "Sales Report" and st.session_state.user_role == "admin_cinema":
            st.header("💰 Sales Report")
            df = get_sales_report(db)
            st.dataframe(df, use_container_width=True)
            st.download_button(
                label="📥 Download Report",
                data=df.to_csv(index=False).encode('utf-8'),
                file_name="sales_report.csv",
                mime="text/csv"
            )

# Footer
if st.session_state.authenticated:
    st.markdown("---")
    st.markdown('<div class="footer">🎬 Cinema Royale | Crafted with passion for movie lovers | © 2025</div>', unsafe_allow_html=True)