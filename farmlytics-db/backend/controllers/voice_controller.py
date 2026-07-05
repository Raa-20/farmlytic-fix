import os
from werkzeug.utils import secure_filename
from flask import request, jsonify
from backend.models.inputform_model import InputData
from backend.extensions import db
from backend.services.openclaw_service import parsing_openclaw
from backend.utils.auditlog_utils import simpan_audit_log
import re
from datetime import datetime

UPLOAD_FOLDER = 'uploads'

def extract_number(value):
    if not value:
        return None
    match = re.search(r"\d+", str(value))
    return int(match.group()) if match else None

def clean_grade(value):
    if not value:
        return None
    match = re.search(r"[A-C]", str(value).upper())
    return match.group() if match else None

def parse_tanggal(value):
    if not value:
        return None

    bulan_map = {
        "januari": "01", "februari": "02", "maret": "03", "april": "04",
        "mei": "05", "juni": "06", "juli": "07", "agustus": "08",
        "september": "09", "oktober": "10", "november": "11", "desember": "12",
        "may": "05", "august": "08", "october": "10", "december": "12"
    }
    
    try:
        val = str(value).strip().lower()
        parts = val.split()
        
        if len(parts) >= 3:
            hari = parts[0].zfill(2)  
            bulan_str = parts[1]
            tahun = parts[2]
            
            bulan = bulan_map.get(bulan_str, "01") 
            return f"{tahun}-{bulan}-{hari}"
            
        return str(value)
    except Exception as e:
        print("⚠️ GAGAL PARSE TANGGAL:", e)
        return str(value)

def save_voice():
    try:
        text = request.form.get("text")

        id_petugas = request.form.get("id_petugas")
        
        if not text:
            req = request.get_json(silent=True)
            if req and "text" in req:
                text = req.get("text")
            else:
                return jsonify({"error": "text tidak ditemukan"}), 400
            
        print("📥 TEXT MASUK:", text)
        
        hasil = parsing_openclaw(text)

        print("🤖 HASIL OPENCLAW:", hasil)

        if not hasil or "error" in hasil:
            return jsonify(hasil), 400

        komoditas = hasil.get("komoditas")
        berat = extract_number(hasil.get("berat"))
        lokasi = hasil.get("lokasi")
        jenis_transaksi = hasil.get("jenis_transaksi", "masuk")
        satuan = hasil.get("satuan", "Kg")

        if jenis_transaksi == "keluar":
            gagal = 0
            grade = "A"
        else:
            gagal = extract_number(hasil.get("gagal_panen"))
            grade = clean_grade(hasil.get("grade"))

        tanggal = parse_tanggal(hasil.get("tanggal"))
        if not tanggal:
            tanggal = datetime.now().strftime('%Y-%m-%d')

        print("📦 DATA CLEAN:", komoditas, berat, satuan, lokasi, gagal, grade, tanggal, jenis_transaksi)

        if not komoditas:
            return jsonify({"error": "komoditas kosong"}), 400

        foto_filename = ""
        if 'foto' in request.files:
            file_foto = request.files['foto']
            if file_foto and file_foto.filename != '':
                if not os.path.exists(UPLOAD_FOLDER):
                    os.makedirs(UPLOAD_FOLDER)
                    
                foto_filename = secure_filename(file_foto.filename)
                file_foto.save(os.path.join(UPLOAD_FOLDER, foto_filename))

        new_data = InputData(
            komoditas=komoditas,
            berat=berat,
            satuan=satuan,
            lokasi=lokasi,
            gagal=gagal,
            grade=grade,
            tanggal=tanggal,
            cara_input="voice",
            jenis_transaksi=jenis_transaksi,
            foto=foto_filename
        )

        db.session.add(new_data)
        db.session.commit()

        simpan_audit_log(
            user_type="Petugas",
            aktivitas="Input Data Voice",
            detail=f"Menambahkan data {jenis_transaksi} {komoditas} dengan berat {berat} {satuan} di lokasi {lokasi}",
            id_petugas=id_petugas
        )

        return jsonify({
            "message": "Data berhasil disimpan",
            "data": {
                "komoditas": komoditas,
                "berat": berat,
                "satuan": satuan,
                "lokasi": lokasi,
                "gagal": gagal,
                "grade": grade,
                "tanggal": str(tanggal),
                "jenis_transaksi": jenis_transaksi,
                "cara_input": "voice",
                "foto": foto_filename
            }
        }), 200

    except Exception as e:
        print("❌ CONTROLLER ERROR:", str(e))
        db.session.rollback() 
        return jsonify({"error": str(e)}), 500