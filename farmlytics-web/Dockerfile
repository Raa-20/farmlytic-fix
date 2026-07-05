# Gunakan image Node.js yang ringan
FROM node:18-alpine

# Tentukan folder kerja di dalam container
WORKDIR /app

# Salin file package.json dan package-lock.json
COPY package*.json ./

# Install semua dependensi (node_modules)
RUN npm install

# Salin seluruh sisa kode website
COPY . .

# Beritahu Docker bahwa Vite menggunakan port 5173
EXPOSE 5173

# Jalankan Vite dan paksa agar bisa diakses dari luar container (--host)
CMD ["npm", "run", "dev", "--", "--host"]