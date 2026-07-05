import { useState, useEffect } from "react";
import axios from "axios";
import { Trash2, Search, Eye, X } from "lucide-react"; 

const API_URL = "https://${import.meta.env.VITE_API_URL}/history"; 
const DELETE_URL = "https://${import.meta.env.VITE_API_URL}/delete_data"; 
const BASE_URL = "https://${import.meta.env.VITE_API_URL}";

export default function MasterData() {
  const [data, setData] = useState([]);
  const [search, setSearch] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [filterMetode, setFilterMetode] = useState("Semua");
  const [filterTanggal, setFilterTanggal] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [selectedData, setSelectedData] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const dataPerPage = 8;

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      const res = await axios.get(API_URL);
      setData(res.data);
    } catch (err) {
      console.error("Gagal ambil data:", err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (confirm("Yakin ingin menghapus riwayat data ini? Data di mobile juga akan terhapus.")) {
      try {
        const storedRole = localStorage.getItem("role") || "Admin";
        const storedUser = localStorage.getItem("username") || "Unknown";

        await axios.delete(`${DELETE_URL}/${id}?role=${storedRole}&username=${storedUser}`);
        
        fetchData();
      } catch (err) {
        console.error(err);
        alert("Gagal menghapus data");
      }
    }
  };

  const handleRead = (item) => {
    setSelectedData(item);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedData(null);
  };

  let filtered = data.filter((d) =>
    (d.komoditas?.toLowerCase() || "").includes(search.toLowerCase()) ||
    (d.lokasi?.toLowerCase() || "").includes(search.toLowerCase())
  );

  if (filterMetode !== "Semua") {
    filtered = filtered.filter(d => {
      const isVoice = d.cara_input === 'voice';
      const isWa = d.cara_input === 'wa_ai';
      if (filterMetode === "Manual") return !isVoice && !isWa;
      if (filterMetode === "Voice") return isVoice;
      if (filterMetode === "WhatsApp") return isWa;
      return true;
    });
  }

  if (filterTanggal) {
    filtered = filtered.filter(d => d.tanggal === filterTanggal);
  }

  filtered.sort((a, b) => b.id - a.id);

  const totalPages = Math.ceil(filtered.length / dataPerPage);
  const startIndex = (currentPage - 1) * dataPerPage;
  const currentData = filtered.slice(startIndex, startIndex + dataPerPage);

  return (
    <div>
      <div className="flex justify-between items-center mb-5">
        <div>
          <h1 className="text-xl font-bold text-gray-700">Data Transaksi & Panen</h1>
          <p className="text-sm text-gray-400">Sinkronisasi langsung dari input Petugas Bangsal (Mobile)</p>
        </div>

        <div className="flex gap-3 items-center">
          <input
            type="date"
            value={filterTanggal}
            onChange={(e) => { setFilterTanggal(e.target.value); setCurrentPage(1); }}
            className="px-3 py-2 border rounded-lg focus:outline-[#8BC346] text-sm text-gray-600"
          />

          <select 
            value={filterMetode} 
            onChange={(e) => { setFilterMetode(e.target.value); setCurrentPage(1); }}
            className="px-3 py-2 border rounded-lg focus:outline-[#8BC346] text-sm text-gray-600"
          >
            <option value="Semua">Semua Input</option>
            <option value="Manual">Manual</option>
            <option value="Voice">Voice</option>
            <option value="WhatsApp">WhatsApp</option>
          </select>

          <div className="relative">
            <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
            <input
              placeholder="Cari komoditas/lokasi..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setCurrentPage(1); }}
              className="pl-10 pr-3 py-2 border rounded-lg focus:outline-[#8BC346] text-sm w-56"
            />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow overflow-hidden min-h-[400px]">
        <table className="w-full text-sm text-center table-fixed">
          <thead className="bg-[#8BC346] text-white">
            <tr>
              <th className="p-3 w-16">ID</th>
              <th className="w-16">Foto</th>
              <th>Komoditas</th>
              <th>Lokasi (Area)</th>
              <th>Berat</th>
              <th>Jenis Transaksi</th>
              <th>Tanggal</th>
              <th>Metode Input</th>
              <th className="w-24">Aksi</th>
            </tr>
          </thead>

          <tbody>
            {isLoading ? (
              <tr>
                <td colSpan="9" className="p-10 text-gray-500">Memuat data dari server...</td>
              </tr>
            ) : currentData.length === 0 ? (
              <tr>
                <td colSpan="9" className="p-10 text-gray-500">Data riwayat panen tidak ditemukan.</td>
              </tr>
            ) : (
              currentData.map((d) => {
                let bgInput = "bg-gray-100 text-gray-600";
                let labelInput = "Manual";
                if (d.cara_input === 'voice') { bgInput = "bg-blue-100 text-blue-600"; labelInput = "Voice"; }
                else if (d.cara_input === 'wa_ai') { bgInput = "bg-teal-100 text-teal-700"; labelInput = "WhatsApp"; }

                return (
                  <tr key={d.id} className="border-b hover:bg-green-50 align-middle">
                    <td className="p-3 text-gray-500">TRX-{d.id}</td>
                    
                    <td>
                      {d.foto ? (
                        <img
                          src={`${BASE_URL}/uploads/${d.foto}`}
                          alt="Komoditas"
                          className="w-10 h-10 rounded-lg object-cover mx-auto border border-gray-200 cursor-pointer hover:opacity-80"
                          onClick={() => handleRead(d)}
                          onError={(e) => { e.target.onerror = null; e.target.style.display='none' }}
                        />
                      ) : (
                        <div className="w-10 h-10 rounded-lg bg-gray-200 mx-auto flex items-center justify-center border border-gray-300">
                          <span className="text-gray-400 text-[10px]">No Pic</span>
                        </div>
                      )}
                    </td>

                    <td className="font-bold text-gray-700">{d.komoditas}</td>
                    <td className="truncate px-2" title={d.lokasi}>{d.lokasi}</td>
                    
                    <td className="font-semibold">
                      {d.berat} {d.satuan}
                    </td>

                    <td>
                      <span className={`px-2 py-1 rounded text-white text-xs font-semibold
                        ${(d.jenis_transaksi || 'masuk').toLowerCase() === 'masuk' ? 'bg-green-500' : 'bg-red-500'}
                      `}>
                        {(d.jenis_transaksi || 'Masuk').toUpperCase()}
                      </span>
                    </td>

                    <td className="text-gray-600">{d.tanggal}</td>
                    
                    <td>
                      <span className={`px-2 py-1 rounded text-xs font-semibold ${bgInput}`}>
                        {labelInput}
                      </span>
                    </td>

                    <td className="flex justify-center gap-2 p-2 mt-1.5">
                      <button
                        onClick={() => handleRead(d)}
                        className="bg-blue-500 hover:bg-blue-600 p-1.5 rounded text-white shadow-sm"
                        title="Lihat Detail"
                      >
                        <Eye size={15} />
                      </button>

                      <button
                        onClick={() => handleDelete(d.id)}
                        className="bg-red-500 hover:bg-red-600 p-1.5 rounded text-white shadow-sm"
                        title="Hapus Data"
                      >
                        <Trash2 size={15} />
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {!isLoading && (
        <div className="flex justify-between mt-4 text-sm">
          <button disabled={currentPage === 1} onClick={() => setCurrentPage(currentPage - 1)} className="px-3 py-1.5 bg-gray-200 hover:bg-gray-300 rounded disabled:opacity-50">Prev</button>
          <span className="py-1">Halaman {currentPage} dari {totalPages || 1}</span>
          <button disabled={currentPage === totalPages || totalPages === 0} onClick={() => setCurrentPage(currentPage + 1)} className="px-3 py-1.5 bg-gray-200 hover:bg-gray-300 rounded disabled:opacity-50">Next</button>
        </div>
      )}

      {showModal && selectedData && (
        <div className="fixed inset-0 bg-black/40 flex justify-center items-center z-50">
          <div className="bg-white p-6 rounded-2xl w-[550px] shadow-2xl relative">
            <button onClick={closeModal} className="absolute top-5 right-5 text-gray-400 hover:text-red-500 transition">
              <X size={22} />
            </button>
            
            <h2 className="mb-5 text-lg font-bold border-b pb-3 text-gray-700 flex items-center gap-2">
              <Eye className="text-[#8BC346]" size={20} />
              Detail Transaksi (TRX-{selectedData.id})
            </h2>

            <div className="flex gap-5">
              <div className="w-2/5">
                {selectedData.foto ? (
                  <img
                    src={`${BASE_URL}/uploads/${selectedData.foto}`}
                    alt="Komoditas"
                    className="w-full h-40 object-cover rounded-xl border shadow-sm"
                  />
                ) : (
                  <div className="w-full h-40 bg-gray-100 rounded-xl flex flex-col items-center justify-center border border-dashed border-gray-300">
                    <span className="text-gray-400 text-xs mt-2 font-medium">Tidak Ada Foto</span>
                  </div>
                )}
              </div>

              <div className="w-3/5 space-y-4 text-sm">
                <div className="flex justify-between border-b pb-2">
                  <div className="w-1/2">
                    <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Komoditas</p>
                    <p className="font-bold text-gray-800 text-base">{selectedData.komoditas}</p>
                  </div>
                  <div className="w-1/2">
                    <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Metode Input</p>
                    <p className="font-semibold text-gray-800 capitalize flex items-center gap-1">
                      {selectedData.cara_input === 'voice' ? '🎙️ Suara' : selectedData.cara_input === 'wa_ai' ? '💬 WhatsApp' : '✍️ Manual'}
                    </p>
                  </div>
                </div>

                <div>
                  <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Lokasi Area</p>
                  <p className="font-semibold text-gray-800">{selectedData.lokasi}</p>
                </div>

                <div className="flex justify-between">
                  <div className="w-1/2">
                    <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Berat & Satuan</p>
                    <p className="font-bold text-[#8BC346] text-lg">{selectedData.berat} {selectedData.satuan}</p>
                  </div>
                  <div className="w-1/2">
                    <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Jenis Transaksi</p>
                    <p className={`font-bold mt-1 inline-block px-2 py-0.5 rounded text-white text-xs ${
                      (selectedData.jenis_transaksi || 'masuk').toLowerCase() === 'keluar' ? 'bg-red-500' : 'bg-green-500'
                    }`}>
                      {(selectedData.jenis_transaksi || 'Masuk').toUpperCase()}
                    </p>
                  </div>
                </div>

                <div>
                  <p className="text-[11px] text-gray-400 font-bold uppercase tracking-wider">Tanggal Dibuat</p>
                  <p className="font-medium text-gray-600">{selectedData.tanggal}</p>
                </div>
              </div>
            </div>

            <div className="flex justify-end mt-6 pt-4 border-t">
              <button
                onClick={closeModal}
                className="bg-gray-800 hover:bg-gray-900 text-white px-6 py-2 rounded-lg font-medium shadow-md transition"
              >
                Tutup Detail
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}