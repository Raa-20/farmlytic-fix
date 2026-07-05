import requests
import json
import re

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"
MODEL_NAME = "qwen2.5:3b"

def detect_intent(text):
    prompt = f"""
Tentukan intent dari pesan berikut. 
Jika pesan mengandung informasi komoditas, berat, dan lokasi, maka intent adalah 'input_panen'.
Jika pesan menanyakan data atau rekap, maka intent adalah 'minta_laporan'.
Jika pesan hanya sapaan, maka intent adalah 'sapaan'.

Balas JSON valid saja.
{{"intent":"input_panen"}}

Pesan:
{text}
"""
    payload = {
        "model": MODEL_NAME,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False
    }
    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=60)
        if response.status_code != 200: return {"intent": "input_panen"}
        result = response.json()
        match = re.search(r"\{.*\}", result["message"]["content"], re.DOTALL)
        if match: return json.loads(match.group())
    except Exception as e:
        print("AI ERROR:", e)
    return {"intent": "input_panen"}

def extract_panen(text):
    result = {}
    
    id_match = re.search(r"id\s+(\d+)", text, re.I)
    if id_match: result["id_transaksi"] = id_match.group(1)
    jenis_match = re.search(r"(keluar|kirim|jual)", text, re.I)
    jenis_transaksi = "keluar" if jenis_match else "masuk"
    result["jenis_transaksi"] = jenis_transaksi

    tanggal_match = re.search(r"(\d{4}-\d{2}-\d{2}|\d{1,2}-\d{1,2}-\d{4}|\d{1,2}\s+[a-zA-Z]+\s+\d{4})", text)
    if tanggal_match: 
        result["tanggal"] = tanggal_match.group(1)
        text = text.replace(tanggal_match.group(0), "")
        text = re.sub(r"(tgl|tanggal|pada tanggal)\s*", "", text, flags=re.IGNORECASE)

    komoditas = re.search(r"(tomat|cabai|padi|jagung|kakao|sayur mayur|kentang)", text, re.I)
    if komoditas: 
        result["komoditas"] = komoditas.group(1).lower()
        sisa_teks = text[komoditas.end():].strip()
    else:
        sisa_teks = text

    berat = re.search(r"(\d+)\s*(kg|kilo|ton|kwintal)?", sisa_teks, re.I)
    if berat:
        result["berat"] = int(berat.group(1))
        satuan_raw = berat.group(2)
        if satuan_raw:
            if satuan_raw.lower() == "kilo":
                result["satuan"] = "Kg"
            else:
                result["satuan"] = satuan_raw.capitalize()
        
        sisa_teks = sisa_teks[berat.end():].strip()

    if jenis_transaksi == "masuk":
        gagal = re.search(r"(\d+)\s*[%]", text, re.I)
        if gagal: result["gagal_panen"] = int(gagal.group(1))
        
        grade = re.search(r"grade\s+([A-C])", text, re.I)
        if grade: result["grade"] = grade.group(1).upper()

        lokasi_match = re.search(r"^(.*?)\s+\d+\s*[%]", sisa_teks, re.I)
        if lokasi_match: 
            loc_clean = lokasi_match.group(1).strip()
            loc_clean = re.sub(r"^(lokasi|di|tempat)\s+", "", loc_clean, flags=re.IGNORECASE)
            loc_clean = re.sub(r"\s+(gagal panen|gagal|dengan gagal)$", "", loc_clean, flags=re.IGNORECASE).strip()
            result["lokasi"] = loc_clean.title()
    else:
        tujuan_bersih = re.sub(r"^(tujuan|ke|di)\s+", "", sisa_teks, flags=re.IGNORECASE).strip()
        if tujuan_bersih: 
            result["lokasi"] = tujuan_bersih.title()

    return result

def parsing_openclaw(text):
    text_clean = text.strip().lower()

    if "/new" in text_clean: return {"intent": "menu_baru"}

    if text_clean in ["ya simpan", "ya", "simpan"]: 
        return {"intent": "konfirmasi_simpan"}
    if text_clean in ["batal", "tidak", "cancel"]: 
        return {"intent": "batal_simpan"}
    
    if "ya hapus id" in text_clean:
        data = extract_panen(text)
        data["intent"] = "konfirmasi_hapus"
        return data
    
    if "hapus id" in text_clean:
        data = extract_panen(text)
        data["intent"] = "menu_hapus_konfirmasi"
        return data

    if "update id" in text_clean:
        data = extract_panen(text)
        data["intent"] = "update_data"
        return data
        
    if "edit id" in text_clean:
        data = extract_panen(text)
        data["intent"] = "proses_edit"
        return data

    if text_clean in ["1", "1."]: return {"intent": "menu_tambah"}
    elif text_clean in ["2", "2."]: return {"intent": "menu_edit"}
    elif text_clean in ["3", "3."]: return {"intent": "menu_hapus"}

    if "keluar" in text_clean or "kirim" in text_clean or "jual" in text_clean:
        data = extract_panen(text)
        data["intent"] = "input_panen"
        return data

    if "panen" in text_clean or "berat" in text_clean:
        data = extract_panen(text)
        data["intent"] = "input_panen"
        return data

    if text_clean in ["halo ladentra!", "halo", "hai", "menu", "halo"]:
        return {"intent": "sapaan"}

    intent_data = detect_intent(text)
    data = extract_panen(text)
    data["intent"] = intent_data.get("intent", "input_panen")
    
    return data