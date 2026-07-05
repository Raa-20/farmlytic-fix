# Gunakan Base Image Python yang ringan
FROM python:3.10-slim

# Tentukan folder kerja di dalam container
WORKDIR /app

# Salin file requirements terlebih dahulu
COPY requirements.txt .

# Install semua dependensi
RUN pip install --no-cache-dir -r requirements.txt

# Salin seluruh sisa kode sumber ke dalam container
COPY . .

# Beritahu Docker bahwa aplikasi kita menggunakan port 5000
EXPOSE 5000

# Perintah utama untuk menjalankan aplikasi saat container dihidupkan
CMD ["python", "run.py"]