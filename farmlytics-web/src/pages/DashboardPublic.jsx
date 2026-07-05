import { useNavigate } from "react-router-dom";
import { Leaf } from "lucide-react";
import sayurBg from "../assets/sayur.jpg";

export default function DashboardPublic() {
  const navigate = useNavigate();

  return (
  <div
    className="min-h-screen bg-cover bg-center bg-no-repeat"
    style={{
      backgroundImage: `url(${sayurBg})`,
    }}
  >
    <div className="bg-transparent text-white px-8 py-4 flex justify-between absolute top-0 left-0 w-full z-10">
      <h1 className="text-2xl font-bold flex items-center gap-2">
        <Leaf />
        Ladentra
      </h1>

      <button
    onClick={() => navigate("/login")}
    className="text-white px-4 py-2 font-semibold hover:text-green-200 transition"
    >
    Login Admin
    </button>
    </div>

    <div className="min-h-screen bg-black/50 flex items-center justify-center">
      <div className="text-center px-6">
        <h2 className="text-5xl md:text-6xl font-bold text-white mb-6">
          Selamat Datang di Ladentra
        </h2>

        <p className="text-white text-xl md:text-2xl">
          Sistem Monitoring Hasil Panen dan Stok Komoditas Pertanian
        </p>
      </div>
    </div>
  </div>
);
}