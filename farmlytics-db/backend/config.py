import os

class Config:
    # Mengambil data dari variabel Railway, dengan nilai cadangan (fallback) untuk di laptop
    DB_USER = os.getenv('MYSQLUSER', 'root')
    DB_PASS = os.getenv('MYSQLPASSWORD', 'password123')
    DB_HOST = os.getenv('MYSQLHOST', 'mysql.railway.internal')
    DB_PORT = os.getenv('MYSQLPORT', '3306')
    DB_NAME = os.getenv('MYSQLDATABASE', 'railway')

    # Merakit URL database sesuai dengan driver yang kamu pakai (mysqlconnector)
    SQLALCHEMY_DATABASE_URI = f"mysql+mysqlconnector://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False