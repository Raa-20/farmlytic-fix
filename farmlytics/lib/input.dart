import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'custom_navbar.dart';
import 'voiceinput.dart';
import 'history.dart';

class InputPage extends StatefulWidget {
  final String username;
  final String role;
  final String initialTransaksi; 
  const InputPage({
    super.key,
    required this.username,
    required this.role,
    this.initialTransaksi = "masuk", 
  });

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  static const primaryColor = Color(0xFF8BC346);
  final TextEditingController beratC = TextEditingController();
  final TextEditingController gagalC = TextEditingController();
  final TextEditingController tujuanC = TextEditingController();

  DateTime? selectedDate;
  String caraInput = "manual";
  String selectedSatuan = "Kg";
  
  String? selectedKomoditas;
  String? selectedGrade;

  String? selectedProvinceId;
  String? selectedRegencyId;
  String? selectedDistrictId;
  String? selectedVillageId;

  String? provinceName;
  String? regencyName;
  String? districtName;
  String? villageName;

  List provinces = [];
  List regencies = [];
  List districts = [];
  List villages = [];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool isValid = false;
  bool isSaving = false;

  bool get isMasuk => widget.initialTransaksi == "masuk"; 

  @override
  void initState() {
    super.initState();
    if (isMasuk) fetchProvinces(); 
  }

  @override
  void dispose() {
    beratC.dispose();
    gagalC.dispose();
    tujuanC.dispose();
    super.dispose();
  }

  void checkForm() {
    bool valid = false;
    if (isMasuk) {
      valid = selectedKomoditas != null && beratC.text.trim().isNotEmpty &&
          selectedVillageId != null && gagalC.text.trim().isNotEmpty &&
          selectedGrade != null && selectedDate != null;
    } else {
      valid = selectedKomoditas != null && beratC.text.trim().isNotEmpty &&
          tujuanC.text.trim().isNotEmpty && selectedDate != null;
    }
    if (valid != isValid) setState(() => isValid = valid);
  }

  Future<void> fetchProvinces() async {
    try { final res = await http.get(Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json")); if (res.statusCode == 200) setState(() => provinces = json.decode(res.body)); } catch (_) {}
  }
  Future<void> fetchRegencies(String id) async {
    try { final res = await http.get(Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$id.json")); if (res.statusCode == 200) setState(() => regencies = json.decode(res.body)); } catch (_) {}
  }
  Future<void> fetchDistricts(String id) async {
    try { final res = await http.get(Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/districts/$id.json")); if (res.statusCode == 200) setState(() => districts = json.decode(res.body)); } catch (_) {}
  }
  Future<void> fetchVillages(String id) async {
    try { final res = await http.get(Uri.parse("https://www.emsifa.com/api-wilayah-indonesia/api/villages/$id.json")); if (res.statusCode == 200) setState(() => villages = json.decode(res.body)); } catch (_) {}
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) { setState(() => selectedDate = picked); checkForm(); }
  }

  String formatDate(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  String _getRealTimeUI() {
    DateTime now = DateTime.now(); return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour}:${now.minute}";
  }
  String get fullLocation => "${provinceName ?? ''}, ${regencyName ?? ''}, ${districtName ?? ''}, ${villageName ?? ''}";

  @override
  Widget build(BuildContext context) {
    String judulHalaman = isMasuk ? "Input Barang Masuk" : "Input Barang Keluar";
    Color temaWarna = isMasuk ? primaryColor : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                        else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HistoryPage(username: widget.username, role: widget.role)));
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 10),
                    Text(judulHalaman, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: temaWarna)),
                  ],
                ),
                const SizedBox(height: 16),

                if (isMasuk) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: boxStyle(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pilih Metode Input", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: methodCard("Input Manual", "Ketik Secara Manual", isActive: caraInput == "manual", activeColor: temaWarna, onTap: () => setState(() => caraInput = "manual"))),
                            const SizedBox(width: 12),
                            Expanded(child: methodCard("Voice Input", "Rekaman suara", isActive: caraInput == "voice", activeColor: temaWarna, onTap: () {
                              setState(() => caraInput = "voice");
                              Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceInputPage(username: widget.username, role: widget.role)));
                            })),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: boxStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isMasuk ? "Detail Panen Masuk" : "Detail Pengeluaran Barang", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text("Nama Komoditas"), const SizedBox(height: 6),
                      simpleDropdown(["Cabai", "Tomat", "Kentang", "Kakao", "Sayur Mayur"], selectedKomoditas, "Pilih Komoditas", (v) => selectedKomoditas = v),
                      const SizedBox(height: 12),
                      const Text("Berat"), const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: inputField(beratC, isMasuk ? "Total Berat Masuk" : "Total Berat Keluar", isNumber: true)),
                          const SizedBox(width: 8),
                          SizedBox(width: 110, child: simpleDropdown(["Kg", "Ton", "Gram", "Kwintal"], selectedSatuan, "", (v) => selectedSatuan = v!))
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isMasuk) ...[
                        const Text("Provinsi"), wilayahDropdown(provinces, selectedProvinceId, "Pilih Provinsi", (id, name) { selectedProvinceId = id; provinceName = name; selectedRegencyId = null; selectedDistrictId = null; selectedVillageId = null; regencies = []; districts = []; villages = []; fetchRegencies(id!); checkForm(); }), const SizedBox(height: 12),
                        const Text("Kabupaten/Kota"), wilayahDropdown(regencies, selectedRegencyId, "Pilih Kabupaten/Kota", (id, name) { selectedRegencyId = id; regencyName = name; selectedDistrictId = null; selectedVillageId = null; districts = []; villages = []; fetchDistricts(id!); checkForm(); }), const SizedBox(height: 12),
                        const Text("Kecamatan"), wilayahDropdown(districts, selectedDistrictId, "Pilih Kecamatan", (id, name) { selectedDistrictId = id; districtName = name; selectedVillageId = null; villages = []; fetchVillages(id!); checkForm(); }), const SizedBox(height: 12),
                        const Text("Desa"), wilayahDropdown(villages, selectedVillageId, "Pilih Desa", (id, name) { selectedVillageId = id; villageName = name; checkForm(); }), const SizedBox(height: 12),
                        const Text("Gagal Panen (%)"), const SizedBox(height: 6), inputField(gagalC, "0 - 100", isNumber: true), const SizedBox(height: 12),
                        const Text("Grade"), const SizedBox(height: 6), simpleDropdown(["A", "B", "C"], selectedGrade, "Pilih Grade", (v) => selectedGrade = v), const SizedBox(height: 12),
                      ] else ...[
                        const Text("Tujuan / Keterangan Keluar"), const SizedBox(height: 6),
                        inputField(tujuanC, "Misal: Dikirim ke Pasar Induk"),
                        const SizedBox(height: 12),
                      ],

                      Text(isMasuk ? "Tgl Masuk Gudang" : "Tgl Keluar Gudang"), const SizedBox(height: 6),
                      GestureDetector(onTap: pickDate, child: dateBox()), const SizedBox(height: 12),
                      const Text("Tanggal Input Form"), const SizedBox(height: 6), dateAutoBox(), const SizedBox(height: 16),
                      const Text("Foto Dokumentasi"), const SizedBox(height: 6), imagePickerBox(), const SizedBox(height: 24),

                      GestureDetector(
                        onTap: isValid && !isSaving ? saveData : null,
                        child: Container(
                          width: double.infinity, height: 45,
                          decoration: BoxDecoration(color: isValid ? temaWarna : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                          child: Center(child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Dan Lanjutkan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(currentIndex: 2, username: widget.username, role: widget.role),
    );
  }

  Future<void> saveData() async {
    try {
      setState(() => isSaving = true);
      final url = Uri.parse("https://farmlytic-fix-production.up.railway.app/input_data");
      var request = http.MultipartRequest('POST', url);
      
      request.fields['komoditas'] = selectedKomoditas!;
      request.fields['berat'] = beratC.text;
      request.fields['satuan'] = selectedSatuan;
      request.fields['cara_input'] = caraInput;
      request.fields['tanggal'] = formatDate(selectedDate!);
      request.fields['jenis_transaksi'] = widget.initialTransaksi; 

      if (isMasuk) {
        request.fields['lokasi'] = fullLocation;
        request.fields['gagal'] = gagalC.text;
        request.fields['grade'] = selectedGrade!;
      } else {
        request.fields['lokasi'] = tujuanC.text;
        request.fields['gagal'] = "0";
        request.fields['grade'] = "A";
      }

      if (_image != null) request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan"), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryPage(username: widget.username, role: widget.role)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  BoxDecoration boxStyle() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]);
  Widget inputField(TextEditingController controller, String hint, {bool isNumber = false}) => TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, onChanged: (_) => checkForm(), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)));
  Widget simpleDropdown(List<String> data, String? value, String hint, Function(String?) onChanged) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), hint: Text(hint), items: data.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { setState(() { onChanged(v); checkForm(); }); });
  Widget wilayahDropdown(List data, String? value, String hint, Function(String?, String?) onChanged) => DropdownButtonFormField<String>(value: value, decoration: InputDecoration(filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), hint: Text(hint), items: data.map<DropdownMenuItem<String>>((item) => DropdownMenuItem(value: item['id'], child: Text(item['name']))).toList(), onChanged: (val) { final selected = data.firstWhere((e) => e['id'] == val); setState(() => onChanged(val, selected['name'])); });
  Widget dateBox() => Container(width: double.infinity, height: 45, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: Align(alignment: Alignment.centerLeft, child: Text(selectedDate == null ? "Pilih tanggal" : formatDate(selectedDate!))));
  Widget dateAutoBox() => Container(width: double.infinity, height: 45, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), child: Align(alignment: Alignment.centerLeft, child: Text(_getRealTimeUI())));
  Widget imagePickerBox() => GestureDetector(onTap: pickImage, child: Container(width: double.infinity, height: 150, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)), child: _image != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_image!, fit: BoxFit.cover)) : const Center(child: Text("Tap untuk upload foto"))));
  Widget methodCard(String title, String subtitle, {VoidCallback? onTap, bool isActive = false, Color activeColor = primaryColor}) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isActive ? activeColor.withOpacity(0.2) : Colors.grey[100], borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? activeColor : Colors.transparent, width: 1.5)), child: Column(children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? activeColor : Colors.black)), const SizedBox(height: 4), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey))])));
}