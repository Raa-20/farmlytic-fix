import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react' // (atau sesuaikan dengan plugin yang kamu pakai)

export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Wajib agar bisa diakses dari luar container Docker
    allowedHosts: ['farmlytics-web.up.railway.app'], // Tambahkan baris ini
  }
})