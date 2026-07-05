from flask import Blueprint, request, jsonify
from backend.extensions import db
from sqlalchemy import text
from datetime import datetime
import base64
import os
import re
import traceback
import speech_recognition as sr
from pydub import AudioSegment
from backend.utils.auditlog_utils import simpan_audit_log
from backend.services.openclaw_service import parsing_openclaw

wa_bp = Blueprint('wa_routes', __name__)
USER_SESSIONS = {}

def format_tanggal_db(tgl_str):
    if not tgl_str:
        return datetime.now().strftime('%Y-%m-%d')

    if re.match(r"^\d{4}-\d{2}-\d{2}$", tgl_str):
        return tgl_str

    bulan_indo = {
        "januari": "01", "februari": "02", "maret": "03", "april": "04",
        "mei": "05", "juni": "06", "juli": "07", "agustus": "08",
        "september": "09", "oktober": "10", "november": "11", "desember": "12"
    }
    
    try:
        parts = tgl_str.lower().split()
        if len(parts) == 3:
            hari = parts[0].zfill(2)
            bulan = bulan_indo.get(parts[1], "01")
            tahun = parts[2]
            return f"{tahun}-{bulan}-{hari}"
    except Exception:
        pass

    return datetime.now().strftime('%Y-%m-%d')

@wa_bp.route('/api/wa-webhook', methods=['POST'])
def receive_wa():
    data = request.json
    raw_text = data.get('raw_text', '')
    audio_b64 = data.get('audio_b64')
    sender = data.get('sender', 'unknown') 

    if audio_b64:
        try:
            ogg_path = "temp_vn.ogg"
            wav_path = "temp_vn.wav"
            
            with open(ogg_path, "wb") as f:
                f.write(base64.b64decode(audio_b64))
            
            audio = AudioSegment.from_ogg(ogg_path)
            audio.export(wav_path, format="wav")
            
            recognizer = sr.Recognizer()
            with sr.AudioFile(wav_path) as source:
                audio_data = recognizer.record(source)
                raw_text = recognizer.recognize_google(audio_data, language="id-ID")
                print("🎙️ Hasil STT WA:", raw_text)

            if os.path.exists(ogg_path): os.remove(ogg_path)
            if os.path.exists(wav_path): os.remove(wav_path)

        except sr.UnknownValueError:
            return jsonify({"status": "success", "reply": "❌ Maaf, suaranya kurang jelas. Bisa diulangi lagi?"}), 200
        except Exception as e:
            print("STT ERROR:", e)
            return jsonify({"status": "success", "reply": f"❌ Terjadi kesalahan saat memproses suara: {str(e)}"}), 200

    parsed_data = parsing_openclaw(raw_text)

    if "error" in parsed_data:
        return jsonify({"status": "error", "message": "Maaf, Ladentra AI tidak memahami maksud pesanmu."}), 200

    intent = parsed_data.get('intent', 'input_panen')
    komoditas = parsed_data.get('komoditas')

    try:
        if intent == 'sapaan' or intent == 'menu_baru':
            reply_msg = (
                "Halo Petugas Ladentra! 👋\n\n"
                "Ada yang bisa saya bantu hari ini?\n"
                "Ketik angka untuk memilih menu di bawah ini:\n\n"
                "1️⃣ Tambah data panen / keluar\n"
                "2️⃣ Edit data panen\n"
                "3️⃣ Hapus data panen"
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'menu_tambah':
            reply_msg = (
                "📝 *PANDUAN TAMBAH DATA*\n\n"
                "Kirim laporan hasil panen Anda dengan cara *Ketik Pesan* atau *Kirim Voice Note (VN)*. 🎙️\n\n"
                "📥 *BARANG MASUK*\n"
                "Sebutkan: _Panen [Komoditas] [Berat] [Satuan] di [Lokasi], gagal panen [Gagal]%, grade [A/B/C], tanggal [Tgl]_\n"
                "🗣️ *Contoh VN:* \"Panen cabai 50 kilo di Desa Plaosan, Kecamatan Plaosan, Kabupaten Malang, Jawa Timur, gagal panen 5 %, grade A, tanggal 12 Juni 2026.\"\n\n"
                "📤 *BARANG KELUAR*\n"
                "Sebutkan: _Keluar [Komoditas] [Berat] [Satuan] tujuan [Lokasi], tanggal [Tgl]_\n"
                "🗣️ *Contoh VN:* \"Keluar tomat 30 kilo tujuan Pasar Induk, tanggal 12 Juni 2026.\"\n\n"
                "_(Catatan: Jika tanggal tidak disebutkan, sistem otomatis memakai tanggal hari ini)_"
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'input_panen':
            berat = parsed_data.get('berat')
            lokasi = parsed_data.get('lokasi')
            jenis_transaksi = parsed_data.get('jenis_transaksi', 'masuk')
            satuan = parsed_data.get('satuan', 'Kg') 
            tanggal_raw = parsed_data.get('tanggal')
            tanggal = format_tanggal_db(tanggal_raw)

            if jenis_transaksi == 'keluar':
                gagal = 0
                grade = "A"
            else:
                gagal = parsed_data.get('gagal_panen', 0)
                grade = (parsed_data.get('grade') or '-').upper()

            if not komoditas or not berat or not lokasi:
                return jsonify({"status": "success", "reply": "❌ Data tidak lengkap! Ketik '1' untuk melihat format panduan."}), 200

            USER_SESSIONS[sender] = {
                "k": komoditas.capitalize(), 
                "b": berat, 
                "s": satuan,
                "l": lokasi.title(), 
                "g": gagal, 
                "gr": grade,
                "jt": jenis_transaksi,
                "tgl": tanggal
            }
            
            tipe_laporan = "BARANG MASUK" if jenis_transaksi == 'masuk' else "BARANG KELUAR"
            reply_msg = (
                f"⏳ *KONFIRMASI DATA {tipe_laporan}*\n\n"
                f"- Komoditas: {komoditas.capitalize()}\n"
                f"- Berat: {berat} {satuan}\n"
                f"- Lokasi/Tujuan: {lokasi.title()}\n"
                f"- Tanggal: {tanggal}\n"
            )
            if jenis_transaksi == 'masuk':
                reply_msg += f"- Grade: {grade}\n- Gagal Panen: {gagal}%\n"

            reply_msg += "\nApakah data di atas sudah benar?\nBalas:\n✅ *ya simpan*\n❌ *batal*"
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'konfirmasi_simpan':
            if sender not in USER_SESSIONS:
                return jsonify({"status": "success", "reply": "❌ Tidak ada data yang menunggu disimpan. Silakan kirim data panen terlebih dahulu."}), 200
            
            sess_data = USER_SESSIONS[sender]
            query = text("""
                INSERT INTO input_data (komoditas, berat, satuan, lokasi, gagal, grade, cara_input, jenis_transaksi, tanggal) 
                VALUES (:k, :b, :s, :l, :g, :gr, 'wa_ai', :jt, :tgl)
            """)
            db.session.execute(query, sess_data)
            db.session.commit()

            try:
                simpan_audit_log(
                    user_type="Petugas WA", 
                    aktivitas="Input Data WA", 
                    detail=f"Menambahkan data {sess_data['jt']} {sess_data['k']} dengan berat {sess_data['b']} {sess_data['s']}", 
                    id_petugas=sender
                )
            except Exception as e:
                print("Gagal log audit:", e)

            del USER_SESSIONS[sender]
            return jsonify({"status": "success", "reply": "✅ Data berhasil disimpan ke database.\n\n🔄 Ketik */new* untuk kembali ke menu utama."}), 200

        elif intent == 'batal_simpan':
            if sender in USER_SESSIONS:
                del USER_SESSIONS[sender]
            return jsonify({"status": "success", "reply": "🚫 Proses simpan dibatalkan.\n\nSilakan kirim pesan atau Voice Note baru."}), 200

        elif intent == 'menu_edit':
            reply_msg = (
                "✏️ *EDIT DATA PANEN*\n\n"
                "Silakan masukkan ID transaksi yang ingin diedit.\n"
                "Contoh: *edit ID 1*\n\n"
                "Anda bisa melihat ID transaksi di aplikasi Farmlytics pada menu History."
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'proses_edit':
            id_transaksi = parsed_data.get('id_transaksi')
            query = text("SELECT * FROM input_data WHERE id = :id")
            data_row = db.session.execute(query, {"id": id_transaksi}).fetchone()
            
            if not data_row:
                return jsonify({"status": "success", "reply": f"❌ ID transaksi {id_transaksi} tidak ditemukan."}), 200
            
            reply_msg = (
                f"✅ *DATA DITEMUKAN (ID: {id_transaksi})*\n"
                f"- Komoditas: {data_row.komoditas}\n"
                f"- Berat: {data_row.berat} {data_row.satuan}\n"
                f"- Lokasi: {data_row.lokasi}\n"
                f"- Gagal Panen: {data_row.gagal}%\n"
                f"- Grade: {data_row.grade}\n\n"
                "Silakan kirim update dengan format:\n"
                "*update ID {id_transaksi} [Komoditas] [Berat] [Lokasi] [Gagal]% [Grade]*"
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'update_data':
            id_transaksi = parsed_data.get('id_transaksi')
            berat = parsed_data.get('berat')
            komoditas = parsed_data.get('komoditas')
            lokasi = parsed_data.get('lokasi')
            gagal = parsed_data.get('gagal_panen')
            grade = parsed_data.get('grade')
            
            if not all([id_transaksi, berat, komoditas, lokasi, gagal, grade]):
                return jsonify({"status": "success", "reply": "❌ Data tidak lengkap. Pastikan format: *update ID [ID] [Komoditas] [Berat] [Lokasi] [Gagal]% [Grade]*"}), 200
            
            update_query = text("UPDATE input_data SET berat = :berat, komoditas = :komoditas, lokasi = :lokasi, gagal = :gagal, grade = :grade WHERE id = :id")
            db.session.execute(update_query, {"berat": berat, "komoditas": komoditas.capitalize(), "lokasi": lokasi.title(), "gagal": gagal, "grade": grade.upper(), "id": id_transaksi})
            db.session.commit()

            try:
                simpan_audit_log(
                    user_type="Petugas WA", 
                    aktivitas="Update Data WA", 
                    detail=f"Memperbarui data TRX-{id_transaksi} menjadi {komoditas} {berat}kg", 
                    id_petugas=sender
                )
            except Exception as e:
                print("Gagal log audit:", e)
                
            return jsonify({"status": "success", "reply": f"✅ Data ID {id_transaksi} berhasil diperbarui sepenuhnya.\n\n🔄 Ketik */new* untuk kembali ke menu utama."}), 200

        elif intent == 'menu_hapus':
            reply_msg = (
                "🗑️ *HAPUS DATA PANEN*\n\n"
                "Silakan masukkan ID transaksi yang ingin dihapus.\n"
                "Contoh: *hapus ID 1*\n\n"
                "Anda bisa melihat ID transaksi di aplikasi Farmlytics pada menu History. \n"
                "*⚠️ Peringatan: Data yang dihapus tidak dapat dikembalikan.*"
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200
        
        elif intent == 'menu_hapus_konfirmasi':
            id_transaksi = parsed_data.get('id_transaksi')
            query = text("SELECT * FROM input_data WHERE id = :id")
            data_row = db.session.execute(query, {"id": id_transaksi}).fetchone()
            
            if not data_row:
                return jsonify({"status": "success", "reply": f"❌ ID {id_transaksi} tidak ditemukan."}), 200
            
            reply_msg = (
                f"⚠️ *KONFIRMASI HAPUS*\n"
                f"- Komoditas: {data_row.komoditas}\n"
                f"- Berat: {data_row.berat} {data_row.satuan}\n"
                f"- Lokasi: {data_row.lokasi}\n"
                f"- Gagal Panen: {data_row.gagal}%\n"
                f"- Grade: {data_row.grade}\n\n"
                f"Ketik: *ya hapus ID {id_transaksi}* untuk melanjutkan."
            )
            return jsonify({"status": "success", "reply": reply_msg}), 200

        elif intent == 'konfirmasi_hapus':
            id_transaksi = parsed_data.get('id_transaksi')
            delete_query = text("DELETE FROM input_data WHERE id = :id")
            db.session.execute(delete_query, {"id": id_transaksi})
            db.session.commit()

            try:
                simpan_audit_log(
                    user_type="Petugas WA", 
                    aktivitas="Hapus Data WA", 
                    detail=f"Menghapus data transaksi TRX-{id_transaksi}", 
                    id_petugas=sender
                )
            except Exception as e:
                print("Gagal log audit:", e)
                
            return jsonify({"status": "success", "reply": "✅ Data berhasil dihapus.\n\n🔄 Ketik */new* untuk kembali ke menu utama."}), 200

        elif intent == 'minta_laporan':
            if not komoditas:
                return jsonify({"status": "success", "reply": "Komoditas apa yang ingin kamu cek datanya? (Contoh: Cabai, Tomat)"}), 200
            query = text("SELECT COUNT(*) as total_transaksi, SUM(berat) as total_berat, AVG(gagal) as rata_gagal FROM input_data WHERE LOWER(komoditas) = :komoditas")
            result = db.session.execute(query, {"komoditas": komoditas.lower()}).fetchone()
            reply_msg = f"📊 *REKAP {komoditas.upper()}*\nTotal panen: {result.total_berat or 0} Kg. Rata-rata gagal: {round(result.rata_gagal or 0, 2)}%."
            return jsonify({"status": "success", "reply": reply_msg}), 200
        
        else:
            return jsonify({"status": "success", "reply": "Maaf, perintah tidak dikenali."}), 200

    except Exception as e:
        print("❌ FLASK ERROR DETAIL:")
        traceback.print_exc()
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500