import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_navbar.dart';
import 'input.dart';
import 'login.dart';

class BerandaPage extends StatefulWidget {
  final String? username;
  final String? role;
  const BerandaPage({super.key, this.username, this.role});
  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  static const primaryColor = Color(0xFF8BC346);
  bool get isGuest => widget.username == null || widget.username!.isEmpty || widget.role == null;
  List historyData = [];
  bool isLoadingHistory = true;
  @override
  void initState() {
    super.initState();
    checkLogin();
    if (!isGuest) {
      fetchHistory();
    } else {
      isLoadingHistory = false;
    }
  }
  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedRole = prefs.getString('role');

    if (savedUsername == null || savedUsername.isEmpty || savedRole == null || savedRole.isEmpty) {
      return;
    }

    if (widget.username != null && widget.role != null) {
      if (savedUsername != widget.username || savedRole != widget.role) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse("https://farmlytic-fix-production.up.railway.app/history"));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          historyData = decoded;
          historyData.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
          isLoadingHistory = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoadingHistory = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingHistory = false);
    }
  }

  int getTotalCatatan() => historyData.length;
  String getTotalBerat() {
    double totalKg = 0;
    for (var item in historyData) {
      double berat = double.tryParse(item['berat'].toString()) ?? 0;
      String satuan = item['satuan']?.toString().trim().toLowerCase() ?? "kg";
      double val = (satuan == "ton") ? berat * 1000 : berat;
      String jenis = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
      if (jenis == 'keluar') {
        totalKg -= val;
      } else {
        totalKg += val;
      }
    }
    return "${totalKg.toInt()} kg";
  }

  String getTotalMasukSupervisor() {
    double totalKg = 0;
    for (var item in historyData) {
      String jenis = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
      if (jenis == 'masuk') {
        double berat = double.tryParse(item['berat'].toString()) ?? 0;
        String satuan = item['satuan']?.toString().trim().toLowerCase() ?? "kg";
        totalKg += (satuan == "ton") ? berat * 1000 : berat;
      }
    }
    return "${totalKg.toInt()} kg";
  }

  String getTotalKeluarSupervisor() {
    double totalKg = 0;
    for (var item in historyData) {
      String jenis = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
      if (jenis == 'keluar') {
        double berat = double.tryParse(item['berat'].toString()) ?? 0;
        String satuan = item['satuan']?.toString().trim().toLowerCase() ?? "kg";
        totalKg += (satuan == "ton") ? berat * 1000 : berat;
      }
    }
    return "${totalKg.toInt()} kg";
  }

  String shortLocation(String lokasi) {
    if (lokasi.isEmpty) return "-";
    List parts = lokasi.split(',');
    if (parts.isNotEmpty) return parts.first.trim();
    return lokasi.length > 12 ? "${lokasi.substring(0, 12)}..." : lokasi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: fetchHistory,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF79AF3A), Color(0xFF8BC346), Color(0xFFCFF8A6)]),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isGuest ? "Hi Guest" : "Hi ${widget.username}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(isGuest ? "Silakan login terlebih dahulu" : widget.role ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  const Text("Agricultural Management", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  if (isGuest) Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: const Text("Login Terlebih Dahulu", style: TextStyle(color: primaryColor)))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, height: 140,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: const DecorationImage(image: AssetImage("assets/sayur.jpg"), fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 12),
                    if (!isGuest && widget.role == "Petugas")
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => InputPage(username: widget.username ?? "", role: widget.role ?? "", initialTransaksi: "masuk"))).then((_) => fetchHistory());
                        },
                        child: Container(
                          width: double.infinity, height: 45,
                          decoration: BoxDecoration(color: const Color(0xFFE5E5E5), borderRadius: BorderRadius.circular(12)),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), SizedBox(width: 6), Text("Record Panen")]),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                      if (widget.role == "Supervisor" || widget.role == "Petugas") ...[
                        const Text("Statistik Alur Barang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: buildStat("Total Masuk", getTotalMasukSupervisor(), textColor: Colors.green)),
                            const SizedBox(width: 10),
                            Expanded(child: buildStat("Total Keluar", getTotalKeluarSupervisor(), textColor: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                    const Text("Aktivitas Gudang", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: buildStat("Completed", historyData.length.toString())),
                        const SizedBox(width: 10),
                        Expanded(child: buildStat("Total Catatan", getTotalCatatan().toString())),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [const Text("Sisa Stok Gudang"), Text(getTotalBerat(), style: const TextStyle(fontWeight: FontWeight.bold))],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    if (isLoadingHistory) const Center(child: CircularProgressIndicator())
                    else if (historyData.isEmpty) const Center(child: Text("Belum ada data"))
                    else ...historyData.map((item) => buildHistoryItem(item)),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 0, username: widget.username, role: widget.role ?? ""),
    );
  }

  Widget buildCard({required Widget child}) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: child);
  }

  Widget buildStat(String title, String value, {Color textColor = primaryColor}) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(title, style: const TextStyle(fontSize: 12)), const SizedBox(height: 5), Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18))]));
  }

  Widget buildHistoryItem(Map<String, dynamic> item) {
    String image = item['foto'] ?? "";
    String inputMethod = (item['cara_input'] ?? 'manual').toString();
    String labelInput = "Manual";
    Color textInputColor = Colors.blue;
    Color bgInputColor = Colors.blue[100]!;

    if (inputMethod == 'voice') {
      labelInput = "Voice";
      textInputColor = Colors.green;
      bgInputColor = Colors.green[100]!;
    } else if (inputMethod == 'wa_ai') {
      labelInput = "WhatsApp";
      textInputColor = Colors.teal;
      bgInputColor = Colors.teal[100]!;
    }

    String jenisTrans = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
    bool isMasuk = jenisTrans == 'masuk';
    String beratTampil = "${isMasuk ? '+' : '-'}${item['berat'] ?? '0'} ${item['satuan'] ?? 'kg'}";
    Color warnaBerat = isMasuk ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: "https://farmlytic-fix-production.up.railway.app/uploads/$image", width: 75, height: 75, fit: BoxFit.cover,
                    placeholder: (context, url) => Container(width: 75, height: 75, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (context, url, error) => Container(width: 75, height: 75, color: Colors.grey[300], child: const Icon(Icons.image)),
                  )
                : Container(width: 75, height: 75, color: Colors.grey[300], child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['komoditas'] ?? "-", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Text(beratTampil, style: TextStyle(color: warnaBerat, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['tanggal'] ?? "-", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(flex: 3, child: buildInfo("Area", shortLocation(item['lokasi'] ?? "-"))),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                        decoration: BoxDecoration(color: bgInputColor, borderRadius: BorderRadius.circular(20)), 
                        child: Text(labelInput, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textInputColor))
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)), SizedBox(width: 95, child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))]);
  }
}