import os
from flask import request, jsonify, send_from_directory
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash 
from backend.models.admin_model import Admin
from backend.models.petugas_model import PetugasBangsal
from backend.models.supervisor_model import Supervisor
from backend.models.dinas_model import Dinas
from backend.extensions import db
from backend.utils.auditlog_utils import simpan_audit_log 

class AuthController:

    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    UPLOAD_FOLDER = os.path.join(BASE_DIR, '..', '..', 'uploads')

    def __init__(self):
        os.makedirs(self.UPLOAD_FOLDER, exist_ok=True)

    def find_user_by_username(self, username):
        user = PetugasBangsal.query.filter_by(USERNAME=username).first()
        if user: return user, "Petugas"
        
        user = Supervisor.query.filter_by(USERNAME=username).first()
        if user: return user, "Supervisor"
        
        user = Dinas.query.filter_by(USERNAME=username).first()
        if user: return user, "Dinas"
        
        user = Admin.query.filter_by(USERNAME=username).first()
        if user: return user, "Admin"
        
        return None, None

    def _get_user_foto(self, user):
        if hasattr(user, 'foto') and user.foto: return user.foto
        if hasattr(user, 'FOTO') and user.FOTO: return user.FOTO
        return ""

    def _set_user_foto(self, user, filename):
        if hasattr(user, 'FOTO'): user.FOTO = filename
        else: user.foto = filename

    def login(self):
        data = request.get_json()
        username = data.get("username")
        password = data.get("password")
        role = data.get("role")

        if not username or not password or not role:
            return jsonify({"status": "error", "message": "Data login tidak lengkap"}), 400

        user = None
        if role == "Admin": user = Admin.query.filter_by(USERNAME=username).first()
        elif role == "Petugas": user = PetugasBangsal.query.filter_by(USERNAME=username).first()
        elif role == "Supervisor": user = Supervisor.query.filter_by(USERNAME=username).first()
        elif role == "Dinas": user = Dinas.query.filter_by(USERNAME=username).first()

        if user:
            db_password = getattr(user, 'PASSWORD', getattr(user, 'password', ''))
            login_sukses = False

            if check_password_hash(db_password, password):
                login_sukses = True
            elif db_password == password:
                login_sukses = True
                new_hash = generate_password_hash(password)
                if hasattr(user, 'PASSWORD'): user.PASSWORD = new_hash
                elif hasattr(user, 'password'): user.password = new_hash
                db.session.commit()

            if login_sukses:
                try:
                    simpan_audit_log(user_type=role, aktivitas="Login", detail=f"User {username} berhasil masuk ke sistem")
                except Exception as e:
                    db.session.rollback()
                    print("Audit Log Error:", e)

                return jsonify({
                    "status": "success",
                    "message": f"Login {role} berhasil",
                    "role": role,
                    "username": user.USERNAME,
                    "email": getattr(user, "EMAIL", ""),
                    "foto": self._get_user_foto(user), 
                    "no_hp": getattr(user, "NO_HP", "")
                }), 200

        return jsonify({"status": "error", "message": "Username / Password salah"}), 401

    def logout(self):
        data = request.get_json()
        username = data.get("username", "Unknown")
        role = data.get("role", "Unknown")
        
        try:
            simpan_audit_log(user_type=role, aktivitas="Logout", detail=f"User {username} keluar dari sistem")
        except Exception as e:
            db.session.rollback() 
            print("Audit Log Error:", e)

        return jsonify({"status": "success", "message": "Logout berhasil dicatat"}), 200

    def get_profile(self, username):
        user, role = self.find_user_by_username(username)
        if not user: return jsonify({"status": "error", "message": "User tidak ditemukan"}), 404
        return jsonify({"status": "success", "username": user.USERNAME, "email": getattr(user, "EMAIL", ""), "no_hp": getattr(user, "NO_HP", ""), "foto": self._get_user_foto(user), "role": role}), 200

    def upload_foto(self, username):
        if 'foto' not in request.files: return jsonify({"status": "error", "message": "File tidak ditemukan"}), 400
        file = request.files['foto']
        if file.filename == '': return jsonify({"status": "error", "message": "File kosong"}), 400
        user, role = self.find_user_by_username(username)
        if not user: return jsonify({"status": "error", "message": "User tidak ditemukan"}), 404
        old_photo = self._get_user_foto(user)
        if old_photo:
            old_path = os.path.join(self.UPLOAD_FOLDER, old_photo)
            if os.path.exists(old_path): os.remove(old_path)
        extension = file.filename.split('.')[-1]
        filename = secure_filename(f"{role}_{username}.{extension}")
        filepath = os.path.join(self.UPLOAD_FOLDER, filename)
        file.save(filepath)
        self._set_user_foto(user, filename)
        db.session.commit()
        return jsonify({"status": "success", "message": "Upload foto berhasil", "path": filename}), 200

    def get_foto(self, filename):
        return send_from_directory(self.UPLOAD_FOLDER, filename)

    def delete_foto(self, username):
        user, role = self.find_user_by_username(username)
        if not user: return jsonify({"status": "error", "message": "User tidak ditemukan"}), 404
        old_photo = self._get_user_foto(user)
        if old_photo:
            filepath = os.path.join(self.UPLOAD_FOLDER, old_photo)
            if os.path.exists(filepath): os.remove(filepath)
        self._set_user_foto(user, "")
        db.session.commit()
        return jsonify({"status": "success", "message": "Foto berhasil dihapus"}), 200

    def update_account(self):
        data = request.get_json()
        username_lama = data.get("username")
        email = data.get("email")
        username_baru = data.get("new_username")
        phone = data.get("phone") or data.get("no_hp")
        password = data.get("password")

        if not username_lama: return jsonify({"status": "error", "message": "Username wajib dikirim"}), 400
        user, role = self.find_user_by_username(username_lama)
        if not user: return jsonify({"status": "error", "message": "User tidak ditemukan"}), 404

        if username_baru and username_baru != username_lama:
            existing_user, _ = self.find_user_by_username(username_baru)
            if existing_user: return jsonify({"status": "error", "message": "Username sudah digunakan"}), 400

        if email:
            if hasattr(user, 'EMAIL'): user.EMAIL = email
            elif hasattr(user, 'email'): user.email = email
        if username_baru:
            if hasattr(user, 'USERNAME'): user.USERNAME = username_baru
            elif hasattr(user, 'username'): user.username = username_baru
        if phone:
            if hasattr(user, 'NO_HP'): user.NO_HP = phone
            elif hasattr(user, 'no_hp'): user.no_hp = phone
        if password:
            hashed_password = generate_password_hash(password)
            if hasattr(user, 'PASSWORD'): user.PASSWORD = hashed_password
            elif hasattr(user, 'password'): user.password = hashed_password

        db.session.commit()
        final_username = getattr(user, 'USERNAME', getattr(user, 'username', username_lama))

        try:
            simpan_audit_log(user_type=role, aktivitas="Edit Profil", detail=f"User {final_username} memperbarui profil")
        except Exception as e:
            db.session.rollback() 
            print("Audit Log Error:", e)

        return jsonify({"status": "success", "message": "Data account berhasil diperbarui", "username": final_username}), 200

    def get_account(self, username):
        user, role = self.find_user_by_username(username)
        if not user: return jsonify({"status": "error", "message": "User tidak ditemukan"}), 404
        return jsonify({"status": "success", "username": user.USERNAME, "email": getattr(user, 'EMAIL', ""), "no_hp": getattr(user, 'NO_HP', ""), "foto": self._get_user_foto(user), "role": role}), 200