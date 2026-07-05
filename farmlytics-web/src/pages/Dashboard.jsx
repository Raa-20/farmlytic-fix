import { useNavigate, useLocation, Outlet } from "react-router-dom";
import { useState, useEffect } from "react";
import axios from "axios";
import Header from "../components/Header";
import myLogo from "../assets/logoladentra.jpg";
import {
  Users as UsersIcon,
  Leaf,
  TrendingUp,
  AlertCircle,
  LogOut,
} from "lucide-react";
import {
  Chart as ChartJS,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler,
  Tooltip,
  Legend,
} from "chart.js";
import { Line } from "react-chartjs-2";

ChartJS.register(
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Filler,
  Tooltip,
  Legend
);

const USERS_API = `${import.meta.env.VITE_API_URL}/api/users`;
const HISTORY_API = `${import.meta.env.VITE_API_URL}/history`;
const AUDIT_API = `${import.meta.env.VITE_API_URL}/audit-log`;

export default function Dashboard({ setIsLogin }) {
  const navigate = useNavigate();
  const location = useLocation();

  const [users, setUsers] = useState([]);
  const [historyData, setHistoryData] = useState([]);
  const [auditLogs, setAuditLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [username, setUsername] = useState("");

  useEffect(() => {
    const loginStatus = localStorage.getItem("login");

    if (loginStatus !== "true") {
      navigate("/", { replace: true });
      return;
    }

    loadData();

    const loginUser = localStorage.getItem("username");
    setUsername(loginUser || "Admin");
  }, [navigate]);

  const loadData = async () => {
    try {
      const [userRes, historyRes, auditRes] = await Promise.all([
        axios.get(USERS_API),
        axios.get(HISTORY_API),
        axios.get(AUDIT_API),
      ]);

      setUsers(userRes.data || []);
      setHistoryData(historyRes.data || []);
      setAuditLogs(auditRes.data || []);
      
    } catch (err) {
      console.error("Gagal mengambil data:", err);
    } finally {
      setLoading(false);
    }
  };

  const gagalData = historyData.map((item) => Number(item.gagal || 0));
  const totalGagal = gagalData.reduce((a, b) => a + b, 0);

  const totalMasuk = historyData.reduce((total, item) => {
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();
    if (jenis !== "masuk") return total;
    const berat = Number(item.berat || 0);
    const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
    const nilai = satuan === "ton" ? berat * 1000 : berat;
    return total + nilai;
  }, 0);

  const stokKeluar = historyData.reduce((total, item) => {
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();
    if (jenis !== "keluar") return total;
    const berat = Number(item.berat || 0);
    const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
    const nilai = satuan === "ton" ? berat * 1000 : berat;
    return total + nilai;
  }, 0);

  const sisaStok = historyData.reduce((total, item) => {
    const berat = Number(item.berat || 0);
    const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
    const nilai = satuan === "ton" ? berat * 1000 : berat;
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();
    return jenis === "keluar" ? total - nilai : total + nilai;
  }, 0);

  const monthNames = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"];
  const monthlyStats = {};

  historyData.forEach((item) => {
    if (!item.tanggal) return;

    const dateParts = item.tanggal.substring(0, 10).split("-");
    if (dateParts.length !== 3) return;

    const year = dateParts[0];
    const monthIdx = parseInt(dateParts[1], 10) - 1; 
    
    const monthKey = `${year}-${dateParts[1]}`; 
    const label = `${monthNames[monthIdx]} ${year}`; 

    if (!monthlyStats[monthKey]) {
      monthlyStats[monthKey] = { label, panen: 0, gagal: 0 };
    }

    const berat = Number(item.berat || 0);
    const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
    const nilai = satuan === "ton" ? berat * 1000 : berat;
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();

    if (jenis === "masuk") {
      monthlyStats[monthKey].panen += nilai;
    }
    
    monthlyStats[monthKey].gagal += Number(item.gagal || 0);
  });

  const sortedMonthKeys = Object.keys(monthlyStats).sort();
  
  const chartLabels = sortedMonthKeys.map(key => monthlyStats[key].label);
  const chartPanenData = sortedMonthKeys.map(key => monthlyStats[key].panen);
  const chartGagalData = sortedMonthKeys.map(key => monthlyStats[key].gagal);

  const lokasiMap = {};
  historyData.forEach((item) => {
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();
    
    if (jenis === "masuk") {
      if (!lokasiMap[item.lokasi]) {
        lokasiMap[item.lokasi] = 0;
      }
      const berat = Number(item.berat || 0);
      const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
      
      lokasiMap[item.lokasi] += satuan === "ton" ? berat * 1000 : berat;
    }
  });

  const lahanData = Object.entries(lokasiMap).map(([nama, total]) => ({
    nama,
    total,
  }));

  const topLahan = [...lahanData]
    .sort((a, b) => b.total - a.total)
    .slice(0, 5);

  const gradeMap = {};
  historyData.forEach((item) => {
    const grade = item.grade || "C";
    if (!gradeMap[grade]) {
      gradeMap[grade] = 0;
    }
    const berat = Number(item.berat || 0);
    const satuan = (item.satuan || "kg").toString().trim().toLowerCase();
    const nilai = satuan === "ton" ? berat * 1000 : berat;
    const jenis = (item.jenis_transaksi || "masuk").toString().toLowerCase();

    if (jenis === "keluar") {
      gradeMap[grade] -= nilai;
    } else {
      gradeMap[grade] += nilai;
    }
  });

  const gradeData = Object.entries(gradeMap)
    .filter(([_, total]) => total > 0)
    .sort((a, b) => b[1] - a[1]);

  const recentActivities = [...auditLogs]
    .sort((a, b) => new Date(b.tanggal) - new Date(a.tanggal))
    .slice(0, 2);

  const handleLogout = async () => {
    try {
      const storedUser = localStorage.getItem("username") || "Unknown";
      const storedRole = localStorage.getItem("role") || "Unknown";

      await axios.post("https://${import.meta.env.VITE_API_URL}/logout", {
        username: storedUser,
        role: storedRole
      });
    } catch (error) {
      console.error("Gagal mencatat log logout:", error);
    } finally {
      localStorage.clear();
      setIsLogin(false);
      navigate("/", { replace: true });
    }
  };

  const DashboardHome = () => {
    const chartData = {
      labels: chartLabels.length > 0 ? chartLabels : ["Belum ada data"],
      datasets: [
        {
          label: "Panen (Kg)",
          data: chartPanenData.length > 0 ? chartPanenData : [0],
          fill: true,
          backgroundColor: "rgba(139,195,70,0.2)",
          borderColor: "#8BC346",
          tension: 0.4,
        },
        {
          label: "Gagal",
          data: chartGagalData.length > 0 ? chartGagalData : [0],
          fill: true,
          backgroundColor: "rgba(255,0,0,0.1)",
          borderColor: "#ef4444",
          tension: 0.4,
        },
      ],
    };

    return (
      <>
        <div className="grid grid-cols-4 gap-5">
          <Card title="Total User" value={users.length} icon={<UsersIcon />} />
          <Card title="Sisa Stok" value={`${sisaStok.toFixed(0)} Kg`} icon={<Leaf />} />
          <Card title="Stok Keluar" value={`${stokKeluar} Kg`} icon={<TrendingUp />} />
          <Card title="Gagal Panen" value={totalGagal} icon={<AlertCircle />} />
        </div>

        <div className="grid grid-cols-3 gap-5 mt-6">
          <div className="col-span-2 bg-white p-4 rounded-xl shadow">
            <h2 className="font-semibold mb-3">Statistik Panen</h2>
            <div className="h-72">
              <Line 
                data={chartData} 
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  scales: {
                    y: { beginAtZero: true }
                  }
                }} 
              />
            </div>
          </div>

          <div className="bg-white p-5 rounded-xl shadow">
            <h2 className="font-semibold mb-3">Grade Komoditas</h2>
            <div className="space-y-3">
              {gradeData.length > 0 ? (
                gradeData.map(([grade, total], index) => (
                  <div key={index} className="flex justify-between border-b pb-2">
                    <span>Grade {grade}</span>
                    <span className="font-semibold text-[#8BC346]">
                      {total.toFixed(0)} Kg
                    </span>
                  </div>
                ))
              ) : (
                <p className="text-gray-500">Belum ada data grade</p>
              )}
            </div>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-5 mt-6">
          <div className="bg-white p-4 rounded-xl shadow">
            <h2 className="font-semibold mb-3">Top Lahan</h2>
            <ul className="text-sm text-gray-600 space-y-1">
              {topLahan.map((l, i) => (
                <li key={i}>
                  {i + 1}. {l.nama} - {l.total} Kg
                </li>
              ))}
            </ul>
          </div>

          <div className="bg-white p-4 rounded-xl shadow">
            <h2 className="font-semibold mb-3">Aktivitas Terbaru</h2>
            <ul className="text-sm text-gray-600 space-y-2">
              {recentActivities.length > 0 ? (
                recentActivities.map((log, index) => (
                  <li key={index} className="border-b pb-2">
                    <div className="font-medium text-gray-700">{log.aktivitas}</div>
                    <div className="text-xs text-gray-500">{log.detail}</div>
                    <div className="text-xs text-gray-400 mt-1">
                      {log.user_type} • {log.tanggal}
                    </div>
                  </li>
                ))
              ) : (
                <li>Belum ada aktivitas</li>
              )}
            </ul>
          </div>
        </div>
      </>
    );
  };

  const getPageTitle = () => {
    switch (location.pathname) {
      case "/dashboard":
        return "Dashboard";
      case "/dashboard/users":
        return "Manajemen User";
      case "/dashboard/master-data":
        return "Master Data";
      case "/dashboard/audit-log":
        return "Audit Log";
      default:
        return "Dashboard";
    }
  };

  const isDashboardHome = location.pathname === "/dashboard";

  if (loading) {
    return (
      <div className="h-screen flex items-center justify-center">
        Loading...
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <div className="w-64 text-white flex flex-col h-screen bg-gradient-to-b from-[#8BC346] to-green-700 shadow-xl z-20">
        
        <div className="h-16 shrink-0 flex items-center px-6 border-b border-white/20 gap-3">
          <img 
            src={myLogo} 
            alt="Logo Ladentra" 
            className="w-10 h-10 object-cover rounded-full shadow-md border border-white/30" 
          />
          <h1 className="text-xl font-extrabold tracking-wide drop-shadow-sm">Ladentra</h1>
        </div>

        <nav className="flex-1 p-4 space-y-1 mt-2">
          <Menu
            label="Dashboard"
            active={location.pathname === "/dashboard"}
            onClick={() => navigate("/dashboard")}
          />
          <Menu
            label="Users"
            active={location.pathname.includes("/dashboard/users")}
            onClick={() => navigate("/dashboard/users")}
          />
          <Menu
            label="Master Data"
            active={location.pathname.includes("/dashboard/master-data")}
            onClick={() => navigate("/dashboard/master-data")}
          />
          <Menu
            label="Audit Log"
            active={location.pathname.includes("/dashboard/audit-log")}
            onClick={() => navigate("/dashboard/audit-log")}
          />
        </nav>

        <div className="p-4 border-t border-white/20">
          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 bg-red-500/90 hover:bg-red-500 hover:shadow-lg hover:-translate-y-0.5 text-white font-bold py-2.5 px-4 rounded-xl shadow-sm transition-all duration-200"
          >
            <LogOut size={18} />
            <span>Logout</span>
          </button>
        </div>
      </div>

      <div className="flex-1 flex flex-col">
        <Header username={username} pageTitle={getPageTitle()} />

        <div className="p-6 overflow-auto">
          {isDashboardHome ? <DashboardHome /> : <Outlet />}
        </div>
      </div>
    </div>
  );
}

const Menu = ({ label, onClick, active }) => (
  <div
    onClick={onClick}
    className={`p-3 rounded-xl cursor-pointer transition-all duration-200 ${
      active
        ? "bg-white text-green-700 font-bold shadow-md transform scale-[1.02]"
        : "hover:bg-white/10 font-medium text-green-50"
    }`}
  >
    {label}
  </div>
);

const Card = ({ title, value, icon }) => (
  <div className="bg-white p-5 rounded-xl shadow-md flex justify-between items-center border-l-4 border-[#8BC346] hover:shadow-lg transition-shadow">
    <div>
      <h2 className="text-gray-500 text-sm font-medium">{title}</h2>
      <p className="text-2xl font-bold text-[#8BC346] mt-1">{value}</p>
    </div>
    <div className="bg-green-50 p-3 rounded-full text-[#8BC346]">
      {icon}
    </div>
  </div>
);