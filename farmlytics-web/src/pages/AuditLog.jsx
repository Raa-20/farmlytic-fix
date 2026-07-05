import { useState, useEffect } from "react";
import axios from "axios";
import {
  Activity,
  LogIn,
  LogOut,
  Edit,
  Trash2,
  PlusCircle,
  Database,
  Search,
  UserCircle,
  Clock
} from "lucide-react";

export default function AuditLog() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    getAuditLogs();
  }, []);

  const getAuditLogs = async () => {
    try {
      const res = await axios.get("http://10.136.162.16:5000/audit-log");
      setLogs(res.data);
    } catch (error) {
      console.error("Gagal mengambil audit log:", error);
    } finally {
      setLoading(false);
    }
  };

  const getLogStyle = (aktivitas) => {
    if (!aktivitas) return { bg: "bg-slate-100 text-slate-700", icon: <Activity size={16} /> };
    
    const act = aktivitas.toLowerCase();

    if (act.includes("login")) return { bg: "bg-blue-100 text-blue-700", icon: <LogIn size={16} /> };
    if (act.includes("logout")) return { bg: "bg-gray-100 text-gray-600", icon: <LogOut size={16} /> };
    if (act.includes("tambah user")) return { bg: "bg-emerald-100 text-emerald-700", icon: <PlusCircle size={16} /> };
    
    if (act.includes("input") || act.includes("tambah data")) {
      return { bg: "bg-green-100 text-green-700", icon: <Database size={16} /> };
    }
    
    if (act.includes("edit") || act.includes("update") || act.includes("profil")) {
      return { bg: "bg-orange-100 text-orange-700", icon: <Edit size={16} /> };
    }
    
    if (act.includes("hapus") || act.includes("delete")) {
      return { bg: "bg-red-100 text-red-700", icon: <Trash2 size={16} /> };
    }

    return { bg: "bg-slate-100 text-slate-700", icon: <Activity size={16} /> };
  };

  const filteredLogs = logs.filter((log) => {
    const searchLower = searchTerm.toLowerCase();
    return (
      (log.aktivitas?.toLowerCase() || "").includes(searchLower) ||
      (log.detail?.toLowerCase() || "").includes(searchLower) ||
      (log.user_type?.toLowerCase() || "").includes(searchLower)
    );
  });

  return (
    <div>
      <div className="flex justify-between items-center mb-5">
        <div>
          <h1 className="text-xl font-bold text-gray-700">Audit Log</h1>
          <p className="text-sm text-gray-400">Monitoring rekam jejak aktivitas pengguna dan sistem</p>
        </div>

        <div className="relative w-full md:w-72">
          <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
          <input
            type="text"
            placeholder="Cari aktivitas, user, atau detail..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#8BC346] focus:border-transparent text-sm shadow-sm transition-all"
          />
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex-1 overflow-hidden flex flex-col">
        
        {loading ? (
          <div className="flex flex-col justify-center items-center h-64 text-gray-400 gap-3">
            <Activity className="animate-pulse" size={32} />
            <p className="text-sm font-medium">Mengumpulkan rekam jejak...</p>
          </div>
        ) : filteredLogs.length === 0 ? (
          <div className="flex flex-col justify-center items-center h-64 text-gray-400 gap-3">
            <Search size={32} className="opacity-50" />
            <p className="text-sm font-medium">Tidak ada log aktivitas yang ditemukan.</p>
          </div>
        ) : (
          <div className="overflow-y-auto pr-4 pb-10" style={{ maxHeight: "calc(100vh - 220px)" }}>
            <div className="relative border-l-2 border-gray-100 ml-4 md:ml-6 space-y-8 mt-4">
              
              {filteredLogs.map((log) => {
                const style = getLogStyle(log.aktivitas);
                
                return (
                  <div key={log.id} className="relative pl-8 md:pl-10 group">
                    
                    <div className={`absolute -left-[17px] top-1 w-8 h-8 rounded-full flex items-center justify-center border-4 border-white shadow-sm transition-transform group-hover:scale-110 ${style.bg}`}>
                      {style.icon}
                    </div>

                    <div className="bg-white border border-gray-100 rounded-2xl p-5 shadow-sm hover:shadow-md transition-all duration-200">
                      
                      <div className="flex flex-col md:flex-row md:justify-between md:items-center mb-3 gap-2">
                        <div className="flex items-center gap-3">
                          <span className={`px-3 py-1 rounded-lg text-xs font-bold uppercase tracking-wider ${style.bg}`}>
                            {log.aktivitas}
                          </span>
                        </div>
                        
                        <div className="flex items-center gap-1.5 text-xs text-gray-400 font-medium bg-gray-50 px-2.5 py-1 rounded-md">
                          <Clock size={12} />
                          {log.tanggal}
                        </div>
                      </div>

                      <div className="text-gray-700 text-sm font-medium leading-relaxed mb-4 whitespace-pre-wrap">
                        {log.detail}
                      </div>

                      <div className="flex items-center gap-2 pt-3 border-t border-gray-50">
                        <UserCircle size={14} className="text-gray-400" />
                        <span className="text-xs text-gray-500 font-medium">
                          Diakses oleh: <span className="text-gray-700 font-bold">{log.user_type}</span>
                        </span>
                      </div>

                    </div>
                  </div>
                );
              })}
              
            </div>
          </div>
        )}
      </div>
    </div>
  );
}