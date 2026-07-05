import { NavLink } from "react-router-dom";
import axios from "axios";
import myLogo from "../assets/logoladentra.jpg";

export default function Sidebar({ setMenu }) {
  const handleLogout = async () => {
    try {
      const storedUser = localStorage.getItem("username") || "Unknown";
      const storedRole = localStorage.getItem("role") || "Unknown";

      await axios.post("${import.meta.env.VITE_API_URL}/logout", {
        username: storedUser,
        role: storedRole,
      });
    } catch (error) {
      console.error("Gagal mencatat log logout:", error);
    } finally {
      localStorage.clear();
      window.location.href = "/";
    }
  };

  return (
    <div className="w-64 bg-green-700 text-white h-screen flex flex-col">
      <div className="h-16 shrink-0 flex items-center px-6 border-b border-white gap-3">
        <img
          src={myLogo}
          alt="Logo Ladentra"
          className="w-10 h-10 object-contain bg-white rounded-full p-1"
        />
        <h1 className="text-xl font-bold tracking-wide">Ladentra</h1>
      </div>

      <div className="p-4 flex-1">
        <button
          onClick={() => setMenu("dashboard")}
          className="block mb-4 text-left w-full hover:text-green-200"
        >
          Dashboard
        </button>
        <button
          onClick={() => setMenu("users")}
          className="block mb-4 text-left w-full hover:text-green-200"
        >
          User
        </button>
        <button
          onClick={() => setMenu("master")}
          className="block mb-4 text-left w-full hover:text-green-200"
        >
          Master Data
        </button>
        <button
          onClick={() => setMenu("audit")}
          className="block text-left w-full hover:text-green-200"
        >
          Audit Log
        </button>
      </div>

      <div className="p-4 border-t border-green-600">
        <button
          onClick={handleLogout}
          className="w-full bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded-lg font-bold transition duration-200 shadow-sm"
        >
          Logout
        </button>
      </div>
    </div>
  );
}
