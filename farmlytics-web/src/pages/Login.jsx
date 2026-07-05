import { useNavigate } from "react-router-dom";
import { useState } from "react";
import sayurBg from "../assets/sayur.jpg";

export default function Login({ setIsLogin }) {
  const navigate = useNavigate();

  const [user, setUser] = useState("");
  const [pass, setPass] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();

    if (!user || !pass) {
      alert("Username dan Password wajib diisi!");
      return;
    }

    setLoading(true);

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/login`,{
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          username: user,
          password: pass,
          role: "Admin",
        }),
      });

      const data = await response.json();

      console.log("RESPONSE LOGIN:", data);

      if (response.ok && data.status === "success") {
        localStorage.setItem("login", "true");
        localStorage.setItem("username", data.username);
        localStorage.setItem("role", data.role);

        setIsLogin(true);

        alert(data.message || "Login berhasil");

        navigate("/dashboard");
      } else {
        alert(data.message || "Username / Password salah!");
      }
    } catch (error) {
      console.error("ERROR LOGIN:", error);
      alert("Tidak bisa konek ke server!");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
        className="relative h-screen bg-cover bg-center bg-no-repeat"
        style={{
          backgroundImage: `url(${sayurBg})`,
        }}
      >
      <div className="absolute inset-0 bg-black/55"></div>

      <div className="absolute top-8 left-10 z-20">
        <h1 className="text-white text-3xl font-bold">
          🌿 Ladentra
        </h1>
      </div>

      <div className="relative z-10 flex items-center justify-center h-full">
        <form
          onSubmit={handleLogin}
          className="w-[420px] bg-white/95 backdrop-blur-md rounded-3xl shadow-2xl p-10"
        >
          <h1 className="text-4xl font-bold text-center text-[#8BC346] mb-3">
            Login Admin
          </h1>

          <p className="text-center text-gray-500 mb-8">
            Silakan masuk ke dashboard
          </p>

          <div className="mb-5">
            <input
              type="text"
              placeholder="Username"
              value={user}
              onChange={(e) => setUser(e.target.value)}
              className="w-full border border-gray-300 p-4 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#8BC346]"
            />
          </div>

          <div className="mb-6">
            <input
              type="password"
              placeholder="Password"
              value={pass}
              onChange={(e) => setPass(e.target.value)}
              className="w-full border border-gray-300 p-4 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#8BC346]"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-[#8BC346] text-white py-4 rounded-xl font-semibold text-lg hover:bg-green-600 transition duration-300 disabled:opacity-50"
          >
            {loading ? "Loading..." : "Login"}
          </button>

          <p className="text-center text-gray-400 text-sm mt-6">
            © 2026 Ladentra Admin Panel
          </p>
        </form>
      </div>
    </div>
  );
}