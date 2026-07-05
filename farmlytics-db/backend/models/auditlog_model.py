from backend.extensions import db
from datetime import datetime

class AuditLog(db.Model):
    __tablename__ = 'audit_log'

    ID_AUDIT_LOG = db.Column(db.Integer, primary_key=True)
    ID_ADMIN = db.Column(db.Integer)
    ID_DINAS = db.Column(db.Integer)
    ID_SUPERVISOR = db.Column(db.Integer)
    ID_PETUGAS_BANGSAL = db.Column(db.Integer)
    USER_TYPE = db.Column(db.String(50))
    AKTIVITAS = db.Column(db.String(255))
    DETAIL_INPUT = db.Column(db.Text)
    TANGGAL = db.Column(
        db.DateTime,
        default=datetime.now
    )