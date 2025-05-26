import streamlit as st
import mysql.connector
import json
import pandas as pd
import webbrowser
from datetime import datetime

# Khởi tạo biến session_state
if "authenticated" not in st.session_state:
    st.session_state.authenticated = False

backgrounds = {
    "Login": "https://wallpapercave.com/wp/wp1945939.jpg",
    "Book Tickets": "https://dnm.nflximg.net/api/v6/BvVbc2Wxr2w6QuoANoSpJKEIWjQ/AAAAQef22OWzj-NkbS5pIbWEeZVAOkxvjPl6fhCURSSw6U0-G2i5cpshA2zBmSCP1as_8JTfUTkY8JAufxP9bJ5eSNc8QNhFyx_n4MWCEYg8MSpNHUZysTf3GP0QmYRRFYiF1QdhegGS7MsfknXVwfGIYg59IQM.jpg?r=557",
    "Cancel Booking": "https://d31xsmoz1lk3y3.cloudfront.net/big/1986437.jpg?v=1599980634",
    "Apply Discount": "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/summer-movies-1591906821.jpg?crop=1xw:1xh;center,top&resize=1200:*",
    "Screening Report": "https://d31xsmoz1lk3y3.cloudfront.net/games/imgur/tD0KbFK.jpg",
    "Sales Report": "https://s.yimg.com/uu/api/res/1.2/1aYSRF7NEFVd._xQ6GbsPg--~B/aD05NjA7dz0xOTIwO2FwcGlkPXl0YWNoeW9u/https://media.zenfs.com/en/seventeen_632/569ae4e42d146c2f0314fa70f0dfdf11",
    "Website": "https://static.wixstatic.com/media/5bf5a4_22d302ef98ca407791f6b75f105b80eb~mv2.jpg/v1/fill/w_980,h_551,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/5bf5a4_22d302ef98ca407791f6b75f105b80eb~mv2.jpg"
}

def set_background(image_url):
    st.markdown(f"""
    <style>
    html, body, [class*="css"] {{
        font-family: 'Poppins', sans-serif;
    }}
    body {{
        background-image: url("{image_url}");
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        background-attachment: fixed;
    }}
    .stApp {{
        background-color: rgba(0, 0, 0, 0.75);
        padding: 2rem;
        border-radius: 10px;
        color: #ffffff;
    }}
    section[data-testid="stSidebar"] {{
        background-color: #fdbbc7;
        color: white;
        padding-top: 2rem;
    }}
    section[data-testid="stSidebar"]::before {{
        content: "";
        display: block;
        background-image: url("https://cdn-icons-png.flaticon.com/512/833/833314.png");
        background-size: 80px 80px;
        background-repeat: no-repeat;
        background-position: center top;
        height: 100px;
        margin-bottom: 1rem;
    }}
    h1, h2, h3 {{
        color: #FFFFFF;
        font-weight: 700;
        text-shadow: 2px 2px 3px rgba(0,0,0,0.5);
    }}
    .stButton>button {{
        background-color: #fdbbc7;
        color: black;
        font-weight: bold;
        border: none;
        border-radius: 10px;
        padding: 0.6em 1.2em;
        transition: background-color 0.3s ease, transform 0.2s ease;
    }}
    .stButton>button:hover {{
        background-color: #fdbbc7;
        transform: scale(1.05);
    }}
    div[data-testid="stFormSubmitButton"] button {{
        background-color: #FFFFFF;
        color: black;
        border: none;
        border-radius: 1010px;
        padding: 0.6em 1.2em;
        font-size: 16px;
        font-weight: bold;
        transition: background-color 0.3s, transform 0.2s ease;
    }}
    div[data-testid="stFormSubmitButton"] button:hover {{
        background-color: #FFFFFF;
        transform: scale(1.05);
    }}
    .stDownloadButton button {{
        background-color: #FFFFFF;
        color: black;
        border: none;
        border-radius: 1010px;
        padding: 0.6em 1.2em;
        font-size: 16px;
        font-weight: bold;
        transition: background-color 0.3s, transform 0.2s ease;
    }}
    .stDownloadButton button:hover {{
        background-color: #FFFFFF;
        transform: scale(1.05);
    }}
    .stTextInput>div>input,
    .stNumberInput>div>input,
    .stSelectbox>div>div {{
        background-color: #1a202c;
        color: white;
        border: 2px solid #2b6cb0;
        border-radius: 8px;
    }}
    .stForm {{
        background-color: #fdbbc7;
        padding: 20px;
        border-radius: 12px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
        margin-top: 1rem;
    }}
    .stDataFrame {{
        border: 1px solid #2b6cb0;
        border-radius: 10px;
        background-color: rgba(0, 0, 0, 0.8);
    }}
    .stDataFrame th {{
        background-color: #2b6cb0;
        color: white;
        font-weight: bold;
    }}
    .stDataFrame td {{
        color: white;
    }}
    .stExpander {{
        background-color: #2d3748;
        border-radius: 8px;
        margin-top: 1rem;
        color: white;
    }}
    </style>
    """, unsafe_allow_html=True)

def open_flask_home():
    st.markdown(
        '<a href="http://127.0.0.1:5000" target="_blank">Click here to go to Website</a>',
        unsafe_allow_html=True
    )

# Initialize session state for authentication
if 'authenticated' not in st.session_state:
    st.session_state.authenticated = False
    st.session_state.user_role = None
    st.session_state.username = None
    st.session_state.db = None

# Database connection
def init_db_connection(username, password):
    try:
        # Kết nối vào MySQL bằng tài khoản thật (ví dụ: root)
        db = mysql.connector.connect(
            host="switchback.proxy.rlwy.net",
            port=23791,
            user="root",             # thay bằng user MySQL thật của bạn
            password="sWQDsfBKeAZlfLEMLbRcUqELEaJHlWsp", # thay bằng mật khẩu MySQL thật
            database="CinemaDB"
        )
        cursor = db.cursor(dictionary=True)

        # Kiểm tra username + password trong bảng users
        cursor.execute(
            "SELECT * FROM Users WHERE username = %s AND password = %s",
            (username, password)
        )
        user = cursor.fetchone()

        if user:
            return db, user['role']  # Trả về kết nối DB và vai trò (role)
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
    set_background(backgrounds["Login"])
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
            st.sidebar.header("🎞️ Menu")
            menu = ["Book Tickets", "Cancel Booking", "Apply Discount", "Screening Report", "Sales Report", "Website"]
            choice = st.sidebar.selectbox("Select Page", menu, format_func=lambda x: f"🎬 {x}")
            set_background(backgrounds[choice])
            st.title(choice)
        else:  # ticket_clerk
            st.sidebar.header("🎞️ Menu")
            menu = ["Book Tickets"]
            choice = st.sidebar.selectbox("Select Page", menu, format_func=lambda x: f"🎬 {x}")
            set_background(backgrounds[choice])
            st.title(choice)


        if choice == "Book Tickets":
            st.header("🎟️ Reserve Your Seats")
            with st.form("booking_form"):
                st.subheader("👤 Guest Information")
                col1, col2 = st.columns(2)
                with col1:
                    customer_name = st.text_input("Full Name", placeholder="Enter your full name")
                    phone = st.text_input("Phone Number", placeholder="e.g., 0966121314")
                with col2:
                    email = st.text_input("Email Address", placeholder="e.g., user@example.com")
                    payment_method = st.selectbox("Payment Method", ["Credit Card", "Debit Card", "Cash"], help="Select your preferred payment method")

                st.subheader("🪑 Seat Selection")
                st.markdown("Enter seats in format: [[ScreeningID, SeatID], ...]")
                seat_list_input = st.text_area("Seat List", placeholder="e.g., [[9, 76], [9, 77]]", height=100)

                st.subheader("🍿 Snack Selection (Optional)")
                st.markdown("Enter snacks in format: [[SnackName, Quantity], ...]")
                snack_list_input = st.text_area("Snack List", placeholder='e.g., [["Popcorn", 2], ["Coke", 1]]', height=100, value="")

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
        elif choice == "Website" and st.session_state.user_role == "admin_cinema":
            st.header("🌐 Cinema Website")
            st.markdown("Click the button below to visit our website.")
            if st.button("🌐 Visit Website"):
                open_flask_home()
# Footer
if st.session_state.authenticated:
    st.markdown("---")
    st.markdown('<div class="footer">🎬 Cinema Royale | Crafted with passion for movie lovers | © 2025</div>', unsafe_allow_html=True)