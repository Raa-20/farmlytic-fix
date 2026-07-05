from backend.extensions import db

class Supervisor(db.Model):
    __tablename__ = 'supervisor'

    ID_SUPERVISOR = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ID_LOKASI = db.Column(db.Integer, nullable=True) 
    NAMA = db.Column(db.String(255), nullable=False)
    USERNAME = db.Column(db.String(100), unique=True, nullable=False)
    PASSWORD = db.Column(db.String(255), nullable=False)
    EMAIL = db.Column(db.String(255), nullable=True)
    NO_HP = db.Column(db.String(15), nullable=True)
    foto = db.Column(db.String(255), nullable=True)

    def __repr__(self):
        return f"<Supervisor {self.USERNAME}>"