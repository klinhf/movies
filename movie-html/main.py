from flask import Flask, render_template
import mysql.connector

app = Flask(__name__)

db_config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'Khanhlinh1003@',
    'database': 'CinemaDB',
    'port': 3306,
    'auth_plugin': 'mysql_native_password'
}

def get_available_cinema_rooms():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
        SELECT cr.RoomID, cr.RoomName, cr.RoomType, cr.Capacity
        FROM CinemaRooms cr
        """)
        cinema_rooms = cursor.fetchall()
        cursor.close()
        conn.close()
        return cinema_rooms
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return []

def get_screenings_with_movies():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
        SELECT s.ScreeningID, m.MovieTitle, m.Genre, m.DurationMinutes, 
               s.ScreeningDate, s.ScreeningTime, cr.RoomName, cr.RoomType
        FROM Screenings s
        JOIN Movies m ON s.MovieID = m.MovieID
        JOIN CinemaRooms cr ON s.RoomID = cr.RoomID
        ORDER BY s.ScreeningDate, s.ScreeningTime
        """)
        screenings = cursor.fetchall()
        cursor.close()
        conn.close()
        return screenings
    except mysql.connector.Error as err:
        print(f"Database Error: {err}")
        return []
    

@app.route('/')
def index():
    cinema_rooms = get_available_cinema_rooms()
    screenings = get_screenings_with_movies()
    return render_template('index.html', cinema_rooms=cinema_rooms, screenings=screenings)
def home():
    print("Đã vào route /")
    return "Trang hoạt động bình thường"

if __name__ == '__main__':
    app.run(debug=True)