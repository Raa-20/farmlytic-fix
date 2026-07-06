import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'custom_navbar.dart';
import 'edit_data.dart';
import 'detail_data.dart';
import 'input.dart';

class HistoryPage extends StatefulWidget {
  final String username;
  final String role;
  const HistoryPage({super.key, required this.username, required this.role});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const primaryColor = Color(0xFF8BC346);
  List allHistoryData = [];
  List filteredData = [];
  List selectedReportData = [];
  bool isLoading = true;

  TextEditingController searchC = TextEditingController();
  String filterKomoditas = "Semua";
  String filterCaraInput = "Semua";
  String filterTransaksi = "Semua"; 
  String filterTanggal = "";

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://farmlytic-fix-production.up.railway.app/history"));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if(!mounted) return;
        setState(() {
          allHistoryData = decodedData;
          allHistoryData.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
          applyFilter();
          isLoading = false;
        });
      } else {
        if(!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      if(!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteData(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirm) return;
    try {
      final response = await http.delete(Uri.parse("https://farmlytic-fix-production.up.railway.app/delete_data/$id"));
      if (response.statusCode == 200) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
        fetchHistory();
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void applyFilter() {
    String query = searchC.text.toLowerCase();
    setState(() {
      filteredData = allHistoryData.where((item) {
        String komoditas = item['komoditas']?.toString().toLowerCase() ?? "";
        String lokasi = item['lokasi']?.toString().toLowerCase() ?? "";
        bool matchesSearch = komoditas.contains(query) || lokasi.contains(query);
        bool matchesKomoditas = filterKomoditas == "Semua" || item['komoditas'] == filterKomoditas;
        bool matchesCaraInput = true;
        String inputType = (item['cara_input'] ?? 'manual').toString().toLowerCase();
        if (filterCaraInput == "Manual") matchesCaraInput = inputType != 'voice' && inputType != 'wa_ai';
        else if (filterCaraInput == "Voice") matchesCaraInput = inputType == 'voice';
        else if (filterCaraInput == "WhatsApp") matchesCaraInput = inputType == 'wa_ai';
        String jenis = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
        bool matchesTransaksi = filterTransaksi == "Semua" || jenis == filterTransaksi.toLowerCase();
        bool matchesTanggal = filterTanggal.isEmpty || item['tanggal'] == filterTanggal;
        return matchesSearch && matchesKomoditas && matchesCaraInput && matchesTransaksi && matchesTanggal;
      }).toList();
    });
  }

  String shortLocation(String lokasi) {
    if (lokasi.isEmpty) return "-";
    List parts = lokasi.split(',');
    if (parts.isNotEmpty) return parts.first.trim();
    return lokasi.length > 12 ? "${lokasi.substring(0, 12)}..." : lokasi;
  }

  List getDailyData() {
    final now = DateTime.now();
    return allHistoryData.where((item) {
      try {
        DateTime itemDate = DateTime.parse(item['tanggal']?.toString() ?? "");
        return itemDate.day == now.day && itemDate.month == now.month && itemDate.year == now.year;
      } catch (e) { return false; }
    }).toList();
  }

  List getWeeklyData() {
    final now = DateTime.now();
    final startWeek = now.subtract(Duration(days: now.weekday - 1));
    return allHistoryData.where((item) {
      try {
        DateTime itemDate = DateTime.parse(item['tanggal']?.toString() ?? "");
        return itemDate.isAfter(startWeek.subtract(const Duration(days: 1))) && itemDate.isBefore(now.add(const Duration(days: 1)));
      } catch (e) { return false; }
    }).toList();
  }

  List getMonthlyData() {
    final now = DateTime.now();
    return allHistoryData.where((item) {
      try {
        DateTime itemDate = DateTime.parse(item['tanggal']?.toString() ?? "");
        return itemDate.month == now.month && itemDate.year == now.year;
      } catch (e) { return false; }
    }).toList();
  }

  Future<void> generatePdfReport(List data, String title) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["Komoditas", "Berat", "Lokasi", "Tanggal", "Tipe"],
            data: data.map((item) => [
              item['komoditas'] ?? '-', 
              "${item['berat']} ${item['satuan'] ?? 'kg'}", 
              item['lokasi'] ?? '-', 
              item['tanggal'] ?? '-',
              item['jenis_transaksi'] ?? 'masuk'
            ]).toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void showReportModal(String title, List reportData) {
    selectedReportData = [];
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8, padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: reportData.isEmpty ? const Center(child: Text("Tidak ada data")) : ListView.builder(
                      itemCount: reportData.length,
                      itemBuilder: (context, index) {
                        final item = reportData[index];
                        bool isSelected = selectedReportData.contains(item);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                          child: CheckboxListTile(
                            value: isSelected, activeColor: primaryColor, controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) {
                              setModalState(() { if (value == true) selectedReportData.add(item); else selectedReportData.remove(item); });
                            },
                            title: Text(item['komoditas'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(item['tanggal'] ?? "-")]),
                                  const SizedBox(height: 4),
                                  Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 5), Expanded(child: Text(item['lokasi'] ?? "-", overflow: TextOverflow.ellipsis))]),
                                  const SizedBox(height: 4),
                                  Text("Berat : ${item['berat']} ${item['satuan'] ?? 'Kg'}", style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: () async {
                        if (selectedReportData.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih minimal 1 data"))); return; }
                        Navigator.pop(context);
                        await generatePdfReport(selectedReportData, title);
                      },
                      icon: const Icon(Icons.download, color: Colors.white), label: const Text("Download PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  left: 20, right: 20, top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Filter Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                             setModalState(() {
                                filterTransaksi = "Semua"; filterKomoditas = "Semua"; filterCaraInput = "Semua"; filterTanggal = "";
                             });
                             applyFilter();
                          },
                          child: const Text("Reset", style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("Tanggal Masuk (Transaksi)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                           setModalState(() {
                             filterTanggal = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                           });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(filterTanggal.isEmpty ? "Pilih Tanggal..." : filterTanggal, style: TextStyle(color: filterTanggal.isEmpty ? Colors.grey[600] : Colors.black)),
                            const Icon(Icons.calendar_month, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text("Jenis Transaksi", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: filterTransaksi,
                      items: ["Semua", "Masuk", "Keluar"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setModalState(() => filterTransaksi = val!),
                    ),
                    const SizedBox(height: 16),
  
                    const Text("Komoditas", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: filterKomoditas,
                      items: ["Semua", "Cabai", "Tomat", "Kentang", "Kakao", "Sayur Mayur"].map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (val) => setModalState(() => filterKomoditas = val!),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text("Metode Input", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      value: filterCaraInput,
                      items: ["Semua", "Manual", "Voice", "WhatsApp"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setModalState(() => filterCaraInput = val!),
                    ),
                    const SizedBox(height: 24),
  
                    SizedBox(
                      width: double.infinity, height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        onPressed: () { applyFilter(); Navigator.pop(context); },
                        child: const Text("Terapkan Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int getTotalCatatan() => filteredData.length;

  String getTotalBerat() {
    double totalKg = 0;
    for (var item in filteredData) {
      double berat = double.tryParse(item['berat'].toString()) ?? 0;
      String satuan = item['satuan']?.toString().trim().toLowerCase() ?? "kg";
      double val = (satuan == "ton") ? berat * 1000 : berat;

      if (filterTransaksi == "Semua") {
         String jenis = (item['jenis_transaksi'] ?? 'masuk').toString().toLowerCase();
         if (jenis == 'keluar') {
           totalKg -= val;
         } else {
           totalKg += val;
         }
      } else {
         totalKg += val;
      }
    }
    return "${totalKg.toInt()} kg";
  }

  @override
  Widget build(BuildContext context) {
    String labelBerat = "Total Stok";
    if (filterTransaksi == "Masuk") labelBerat = "Total Masuk";
    if (filterTransaksi == "Keluar") labelBerat = "Total Keluar";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Transaction History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Complete audit log of all records", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset("assets/sayuran.jpg", width: 75, height: 75, fit: BoxFit.cover),
                  )
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45, padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: searchC,
                        onChanged: (value) => applyFilter(),
                        decoration: const InputDecoration(icon: Icon(Icons.search, size: 20, color: Colors.grey), hintText: "Cari komoditas atau lokasi...", border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: showFilterModal,
                    child: Container(height: 45, width: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.filter_alt, color: primaryColor)),
                  )
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: buildSummary("Total Catatan", getTotalCatatan().toString())),
                  const SizedBox(width: 10),
                  Expanded(child: buildSummary(labelBerat, getTotalBerat())),
                ],
              ),
              const SizedBox(height: 15),

              if (widget.role != "Dinas" && widget.role != "Supervisor") ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InputPage(username: widget.username, role: widget.role, initialTransaksi: "masuk"),
                            ),
                          ).then((_) => fetchHistory());
                        },
                        icon: const Icon(Icons.inventory_2, color: Colors.white),
                        label: const Text("Barang Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InputPage(username: widget.username, role: widget.role, initialTransaksi: "keluar"),
                            ),
                          ).then((_) => fetchHistory());
                        },
                        icon: const Icon(Icons.outbox, color: Colors.white),
                        label: const Text("Barang Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () => showReportModal("Laporan Harian", getDailyData()),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18), label: const Text("Harian", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () => showReportModal("Laporan Mingguan", getWeeklyData()),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18), label: const Text("Mingguan", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: () => showReportModal("Laporan Bulanan", getMonthlyData()),
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18), label: const Text("Bulanan", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredData.isEmpty
                        ? const Center(child: Text("Data tidak ditemukan"))
                        : RefreshIndicator(
                            onRefresh: fetchHistory, color: primaryColor,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final item = filteredData[index];
                                return buildItem(item);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 1, username: widget.username, role: widget.role),
    );
  }

  Widget buildSummary(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget buildItem(Map<String, dynamic> item) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDataPage(data: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TRX-${item['id']}", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text(item['komoditas'] ?? "-", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                      Text(beratTampil, style: TextStyle(color: warnaBerat, fontWeight: FontWeight.bold, fontSize: 14)), 
                      
                      if (widget.role != "Dinas" && widget.role != "Supervisor")
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              bool? refreshed = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditDataPage(data: item)));
                              if (refreshed == true) fetchHistory();
                            } else if (value == 'delete') {
                              deleteData(item['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.red))])),
                          ],
                          child: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12), const SizedBox(width: 4),
                      Text(item['tanggal'] ?? "-", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(flex: 3, child: buildInfo("Area / Tujuan", shortLocation(item['lokasi'] ?? "-"))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: bgInputColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(labelInput, style: TextStyle(fontSize: 10, color: textInputColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        SizedBox(width: 95, child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    );
  }
}