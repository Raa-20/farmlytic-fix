from flask import jsonify
from backend.models.auditlog_model import AuditLog

def get_audit_logs():
    try:

        logs = AuditLog.query.order_by(
            AuditLog.TANGGAL.desc()
        ).all()

        return jsonify([
            {
                "id": log.ID_AUDIT_LOG,
                "user_type": log.USER_TYPE,
                "aktivitas": log.AKTIVITAS,
                "detail": log.DETAIL_INPUT,
                "tanggal": log.TANGGAL.strftime("%Y-%m-%d %H:%M:%S")
            }
            for log in logs
        ])

    except Exception as e:
        print("ERROR AUDIT LOG:", str(e))

        return jsonify({
            "success": False,
            "message": str(e)
        }), 500