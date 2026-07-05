import os
from flask import request, jsonify
from werkzeug.utils import secure_filename
from backend.models.inputform_model import InputData
from backend.extensions import db
from backend.utils.auditlog_utils import simpan_audit_log

UPLOAD_FOLDER = 'uploads'

def get_history_data():
    data = InputData.query.order_by(
        InputData.tanggal.desc()
    ).all()

    result = []

    for item in data:
        result.append({
            "id": item.id,
            "komoditas": item.komoditas,
            "berat": item.berat,
            "satuan": item.satuan if item.satuan else "Kg",
            "lokasi": item.lokasi,
            "gagal": item.gagal,
            "grade": item.grade,
            "cara_input": item.cara_input,
            "jenis_transaksi": item.jenis_transaksi if item.jenis_transaksi else "masuk",
            "tanggal": (
                str(item.tanggal)
                if item.tanggal
                else "-"
            ),
            "created_at": (
                item.created_at.strftime("%Y-%m-%d %H:%M")
                if item.created_at
                else "-"
            ),
            "foto": (
                item.foto
                if item.foto
                else ""
            )
        })

    return result

def get_summary():
    total_inputan = db.session.query(
        db.func.count(InputData.id)
    ).scalar() or 0

    total_berat = db.session.query(
        db.func.sum(InputData.berat)
    ).scalar() or 0

    return {
        "total_inputan": total_inputan,
        "total_berat": total_berat
    }

def delete_history_data(id):
    try:
        user_role = request.args.get("role", "Admin")
        user_name = request.args.get("username", "Unknown")

        data = InputData.query.get(id)

        if not data:
            return jsonify({
                "error": "Data tidak ditemukan"
            }), 404
        
        old_komoditas = data.komoditas
        old_berat = data.berat
        old_satuan = data.satuan
        old_lokasi = data.lokasi
        old_gagal = data.gagal
        old_grade = data.grade
        old_tanggal = data.tanggal
        old_jenis_transaksi = data.jenis_transaksi
        old_foto = data.foto

        if data.foto:
            file_path = os.path.join(
                UPLOAD_FOLDER,
                data.foto
            )

            if os.path.exists(file_path):
                os.remove(file_path)

        db.session.delete(data)
        db.session.commit()

        simpan_audit_log(
            user_type=user_role,
            aktivitas="Hapus Data",
            detail=f"User {user_name} menghapus data transaksi TRX-{id} ({old_komoditas})"
        )

        return jsonify({
            "message": "Data berhasil dihapus"
        }), 200

    except Exception as e:
        db.session.rollback()

        return jsonify({
            "error": str(e)
        }), 500

def update_history_data(id):
    try:
        user_role = request.form.get("role") or request.args.get("role", "Admin")
        user_name = request.form.get("username") or request.args.get("username", "Unknown")

        data = InputData.query.get(id)

        if not data:
            return jsonify({
                "error": "Data tidak ditemukan"
            }), 404
        old_data = {
            "komoditas": str(data.komoditas or "-"),
            "berat": str(data.berat or "-"),
            "satuan": str(data.satuan or "-"),
            "lokasi": str(data.lokasi or "-"),
            "gagal": str(data.gagal or "-"),
            "grade": str(data.grade or "-"),
            "tanggal": str(data.tanggal or "-"),
            "jenis_transaksi": str(data.jenis_transaksi or "-"),
            "foto": str(data.foto or "-")
        }

        komoditas = request.form.get("komoditas")
        berat = request.form.get("berat")
        satuan = request.form.get("satuan")
        lokasi = request.form.get("lokasi")
        gagal = request.form.get("gagal")
        grade = request.form.get("grade")
        tanggal = request.form.get("tanggal")
        jenis_transaksi = request.form.get("jenis_transaksi")

        if komoditas:
            data.komoditas = komoditas
        if berat:
            data.berat = float(berat)
        if satuan:
            data.satuan = satuan
        if lokasi:
            data.lokasi = lokasi
        if gagal:
            data.gagal = int(gagal)
        if grade:
            data.grade = grade
        if tanggal:
            data.tanggal = tanggal
        if jenis_transaksi:
            data.jenis_transaksi = jenis_transaksi

        if 'foto' in request.files:
            file_foto = request.files['foto']

            if (
                file_foto and
                file_foto.filename != ''
            ):

                if data.foto:
                    old_path = os.path.join(
                        UPLOAD_FOLDER,
                        data.foto
                    )

                    if os.path.exists(old_path):
                        os.remove(old_path)

                filename = secure_filename(
                    file_foto.filename
                )

                file_foto.save(
                    os.path.join(
                        UPLOAD_FOLDER,
                        filename
                    )
                )

                data.foto = filename

        db.session.commit()

        detail_log = (
        f"Komoditas: {old_data['komoditas']} -> {data.komoditas}\n"
        f"Berat: {old_data['berat']} {old_data['satuan']} -> {data.berat} {data.satuan}\n"
        f"Lokasi: {old_data['lokasi']} -> {data.lokasi}\n"
        f"Gagal Panen: {old_data['gagal']} -> {data.gagal}\n"
        f"Grade: {old_data['grade']} -> {data.grade}\n"
        f"Tanggal: {old_data['tanggal']} -> {data.tanggal}\n"
        f"Jenis Transaksi: {old_data['jenis_transaksi']} -> {data.jenis_transaksi}\n"
        f"Foto: {old_data['foto']} -> {data.foto}"
        )

        simpan_audit_log(
            user_type=user_role,
            aktivitas="Edit Data",
            detail=f"User {user_name} mengedit data TRX-{id}:\n{detail_log}"
        )

        return jsonify({
            "message": "Data berhasil diupdate"
        }), 200

    except Exception as e:
        db.session.rollback()

        return jsonify({
            "error": str(e)
        }), 500