import { useState, useEffect } from "react";
import axios from "axios";
import { Pencil, Trash2, Plus, Search, Eye, EyeOff } from "lucide-react";

const API_URL = "http://10.136.162.16:5000/api/users";
const BASE_URL = "http://10.136.162.16:5000"; 

export default function Users() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isEdit, setIsEdit] = useState(false);

  const [form, setForm] = useState({
    id: null,
    name: "",
    username: "",
    email: "",
    phone: "",
    password: "", 
    role: "",
    foto: "",
  });

  const [currentPage, setCurrentPage] = useState(1);
  const dataPerPage = 12;

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await axios.get(API_URL);
      setUsers(res.data);
    } catch (err) {
      console.error("Gagal ambil data:", err);
      alert("Tidak bisa konek ke backend!");
    }
  };

  const handleSave = async () => {
    if (!isEdit && (!form.name || !form.username || !form.password || !form.role)) {
      return alert("Nama, Username, Password, dan Role wajib diisi untuk user baru!");
    }
    if (isEdit && (!form.name || !form.username || !form.role)) {
      return alert("Nama, Username, dan Role wajib diisi!");
    }

    try {
      if (isEdit) {
        await axios.put(`${API_URL}/${form.id}/${form.role}`, form);
      } else {
        await axios.post(API_URL, form);
      }
      fetchUsers();
      resetForm();
    } catch (err) {
      alert(err.response?.data?.error || "Gagal menyimpan data");
    }
  };

  const handleEdit = (user) => {
    setForm({
      id: user.id,
      name: user.name || "",
      username: user.username || "",
      email: user.email || "",
      phone: user.phone || "",
      password: "", 
      role: user.role || "",
      foto: user.foto || "",
    });
    setIsEdit(true);
    setShowModal(true);
  };

  const handleDelete = async (id, role) => {
    if (confirm("Yakin hapus user ini? Data di mobile juga akan terhapus.")) {
      try {
        await axios.delete(`${API_URL}/${id}/${role}`);
        fetchUsers();
      } catch (err) {
        alert("Gagal menghapus user");
      }
    }
  };

  const resetForm = () => {
    setForm({ id: null, name: "", username: "", email: "", phone: "", password: "", role: "", foto: "" });
    setIsEdit(false);
    setShowModal(false);
  };

  const filteredUsers = users.filter((u) =>
    u.name?.toLowerCase().includes(search.toLowerCase()) ||
    u.username?.toLowerCase().includes(search.toLowerCase()) ||
    u.email?.toLowerCase().includes(search.toLowerCase())
  );

  const totalPages = Math.ceil(filteredUsers.length / dataPerPage);
  const startIndex = (currentPage - 1) * dataPerPage;
  const currentData = filteredUsers.slice(startIndex, startIndex + dataPerPage);

  return (
    <div>
      <div className="flex justify-between items-center mb-5">
        <div>
          <h1 className="text-xl font-bold text-gray-700">Manajemen User</h1>
          <p className="text-sm text-gray-400">Kelola profil, email, foto, dan role pengguna</p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
            <input
              type="text"
              placeholder="Cari nama/username/email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-10 pr-3 py-2 border rounded-lg focus:outline-[#8BC346] w-64 text-sm shadow-sm"
            />
          </div>

          <button onClick={() => setShowModal(true)} className="bg-[#8BC346] hover:bg-green-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 shadow text-sm transition">
            <Plus size={18} /> Tambah
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow overflow-hidden min-h-[400px]">
        <table className="w-full text-sm text-center table-fixed">
          <thead className="bg-[#8BC346] text-white">
            <tr>
              <th className="p-3 w-16">ID</th>
              <th className="w-16">Foto</th>
              <th>Nama Lengkap</th>
              <th>Username</th>
              <th>Email</th>
              <th>No HP</th>
              <th>Password</th>
              <th>Role</th>
              <th className="w-24">Aksi</th>
            </tr>
          </thead>

          <tbody>
            {currentData.length === 0 ? (
              <tr>
                <td colSpan="9" className="p-10 text-gray-500">Data pengguna tidak ditemukan.</td>
              </tr>
            ) : (
              currentData.map((u) => (
                <tr key={`${u.role}-${u.id}`} className="border-b hover:bg-green-50 align-middle">
                  <td className="p-3 text-gray-500">USR-{u.id}</td>
                  
                  <td>
                    {u.foto ? (
                      <img
                        src={`${BASE_URL}/uploads/${u.foto}`}
                        alt="Profile"
                        className="w-10 h-10 rounded-full object-cover mx-auto border border-gray-200 shadow-sm"
                        onError={(e) => { e.target.onerror = null; e.target.style.display='none' }}
                      />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-gray-100 mx-auto flex items-center justify-center border border-gray-300">
                        <span className="text-gray-400 text-[10px] font-semibold">No Pic</span>
                      </div>
                    )}
                  </td>

                  <td className="truncate px-2 font-medium text-gray-800" title={u.name}>{u.name}</td>
                  <td className="font-bold text-gray-600 truncate">{u.username}</td>
                  <td className="truncate px-2 text-xs text-gray-500" title={u.email}>{u.email || "-"}</td>
                  <td className="truncate text-gray-600">{u.phone || "-"}</td>
                  
                  <td>
                    {showPassword ? (
                      <span className="text-gray-600">{u.password ? "Ter-Hash" : "-"}</span>
                    ) : (
                      <span className="text-gray-400 italic text-[11px]">Ter-enkripsi</span>
                    )}
                  </td>

                  <td>
                    <span className={`px-2 py-1 rounded text-white text-xs font-semibold inline-block shadow-sm
                        ${u.role === "Admin" && "bg-gray-700"}
                        ${u.role === "Petugas" && "bg-green-500"}
                        ${u.role === "Supervisor" && "bg-blue-500"}
                        ${u.role === "Dinas" && "bg-purple-500"}
                      `}>
                      {u.role.toUpperCase()}
                    </span>
                  </td>

                  <td className="flex justify-center gap-2 p-2 mt-1.5">
                    <button onClick={() => handleEdit(u)} className="bg-yellow-400 hover:bg-yellow-500 text-white p-1.5 rounded shadow-sm transition" title="Edit">
                      <Pencil size={15} />
                    </button>
                    <button onClick={() => handleDelete(u.id, u.role)} className="bg-red-500 hover:bg-red-600 text-white p-1.5 rounded shadow-sm transition" title="Hapus">
                      <Trash2 size={15} />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      <div className="flex justify-between items-center mt-4">
        <button onClick={() => setShowPassword(!showPassword)} className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-800 transition">
          {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
          {showPassword ? "Sembunyikan Status Password" : "Tampilkan Status Password"}
        </button>

        <div className="flex text-sm gap-4 items-center">
          <button disabled={currentPage === 1} onClick={() => setCurrentPage(currentPage - 1)} className="px-3 py-1.5 bg-gray-200 hover:bg-gray-300 rounded disabled:opacity-50 transition">Prev</button>
          <span className="text-gray-600 font-medium py-1">Halaman {currentPage} dari {totalPages || 1}</span>
          <button disabled={currentPage === totalPages || totalPages === 0} onClick={() => setCurrentPage(currentPage + 1)} className="px-3 py-1.5 bg-gray-200 hover:bg-gray-300 rounded disabled:opacity-50 transition">Next</button>
        </div>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 backdrop-blur-sm">
          <div className="bg-white p-6 rounded-2xl w-[400px] shadow-2xl">
            <h2 className="text-xl font-bold mb-5 text-gray-800 border-b pb-3">{isEdit ? "Edit Pengguna" : "Tambah Pengguna Baru"}</h2>
            
            {isEdit && (
              <div className="flex flex-col items-center mb-5">
                {form.foto ? (
                  <img
                    src={`${BASE_URL}/uploads/${form.foto}`}
                    alt="Profile"
                    className="w-20 h-20 rounded-full object-cover border-4 border-gray-100 shadow-sm mb-2"
                    onError={(e) => { e.target.onerror = null; e.target.style.display='none' }}
                  />
                ) : (
                  <div className="w-20 h-20 rounded-full bg-gray-100 flex flex-col items-center justify-center border-4 border-gray-50 shadow-sm mb-2">
                    <span className="text-gray-400 text-xs font-semibold">No Pic</span>
                  </div>
                )}
                <span className="text-[10px] text-gray-400 italic font-medium">Foto dikelola via aplikasi Mobile</span>
              </div>
            )}

            <div className="space-y-3">
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase ml-1">Nama Lengkap</label>
                <input placeholder="Masukkan nama..." value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-[#8BC346] focus:ring-1 focus:ring-[#8BC346] text-sm mt-1" />
              </div>
              
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase ml-1">Username (Login)</label>
                <input placeholder="Username unik" value={form.username} onChange={(e) => setForm({ ...form, username: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-none bg-gray-100 text-gray-500 cursor-not-allowed text-sm mt-1" disabled={isEdit} />
              </div>

              <div className="flex gap-3">
                <div className="w-1/2">
                  <label className="text-xs font-bold text-gray-500 uppercase ml-1">Email</label>
                  <input placeholder="email@..." type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-[#8BC346] text-sm mt-1" />
                </div>
                <div className="w-1/2">
                  <label className="text-xs font-bold text-gray-500 uppercase ml-1">No. HP</label>
                  <input placeholder="08..." type="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-[#8BC346] text-sm mt-1" />
                </div>
              </div>

              <div>
                <label className="text-xs font-bold text-gray-500 uppercase ml-1">Password</label>
                <input type="password" placeholder={isEdit ? "Biarkan kosong jika tidak diubah" : "Password login"} value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-[#8BC346] text-sm mt-1" />
              </div>
              
              <div>
                <label className="text-xs font-bold text-gray-500 uppercase ml-1">Role Jabatan</label>
                {isEdit ? (
                  <input 
                    value={form.role} 
                    disabled 
                    className="w-full border border-gray-300 p-2.5 rounded-lg bg-gray-100 text-gray-500 font-bold cursor-not-allowed text-sm mt-1" 
                  />
                ) : (
                  <select value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })} className="w-full border border-gray-300 p-2.5 rounded-lg focus:outline-[#8BC346] text-sm mt-1">
                    <option value="">-- Pilih Role --</option>
                    <option value="Admin">Admin</option>
                    <option value="Petugas">Petugas</option>
                    <option value="Supervisor">Supervisor</option>
                    <option value="Dinas">Dinas</option>
                  </select>
                )}
              </div>
            </div>
            
            {isEdit && (
              <p className="text-[11px] text-red-500 mt-3 font-medium bg-red-50 p-2 rounded-lg border border-red-100">
                ⚠️ Role dan Username bersifat permanen. Untuk mengubahnya, hapus akun ini dan buat baru.
              </p>
            )}

            <div className="flex justify-end gap-3 mt-6">
              <button onClick={resetForm} className="bg-gray-100 hover:bg-gray-200 px-5 py-2.5 rounded-lg text-gray-700 font-bold transition">Batal</button>
              <button onClick={handleSave} className="bg-[#8BC346] hover:bg-[#7ab13c] text-white px-6 py-2.5 rounded-lg font-bold shadow-md transition">Simpan Data</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}