from flask import Blueprint
from backend.controllers.auditlog_controller import get_audit_logs

audit_log_bp = Blueprint("audit_log_bp", __name__)
audit_log_bp.route("/audit-log", methods=["GET"])(get_audit_logs)