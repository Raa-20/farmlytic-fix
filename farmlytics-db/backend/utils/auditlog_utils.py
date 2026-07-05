from backend.extensions import db
from backend.models.auditlog_model import AuditLog

def simpan_audit_log(
    user_type,
    aktivitas,
    detail,
    id_admin=None,
    id_dinas=None,
    id_supervisor=None,
    id_petugas=None
):
    log = AuditLog(
        ID_ADMIN=id_admin,
        ID_DINAS=id_dinas,
        ID_SUPERVISOR=id_supervisor,
        ID_PETUGAS_BANGSAL=id_petugas,
        USER_TYPE=user_type,
        AKTIVITAS=aktivitas,
        DETAIL_INPUT=detail
    )

    db.session.add(log)
    db.session.commit()