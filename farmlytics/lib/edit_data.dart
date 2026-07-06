import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditDataPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const EditDataPage({super.key, required this.data});

  @override
  State<EditDataPage> createState() => _EditDataPageState();
}

class _EditDataPageState extends State<EditDataPage> {
  static const primaryColor = Color(0xFF8BC346);

  final TextEditingController beratC = TextEditingController();

  final TextEditingController gagalC = TextEditingController();
  DateTime? selectedDate;
  String? selectedKomoditas;
  String? selectedGrade;
  String? selectedLokasi;
  File? _image;

  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  List<String> listKomoditas = ["Cabai", "Tomat", "Kentang", "Kakao", "Sayur Mayur"];
  List<String> listLokasi = ["Zona Barat", "Zona Timur", "Zona Utara", "Zona Selatan"];
  List<String> listGrade = ["A", "B", "C"];

  @override
  void initState() {
    super.initState();
  
    String? dbKomoditas = widget.data['komoditas'];
    if (dbKomoditas != null && dbKomoditas.isNotEmpty && !listKomoditas.contains(dbKomoditas)) {
      listKomoditas.add(dbKomoditas);
    }
    selectedKomoditas = dbKomoditas;

    String? dbLokasi = widget.data['lokasi'];
    if (dbLokasi != null && dbLokasi.isNotEmpty && !listLokasi.contains(dbLokasi)) {
      listLokasi.add(dbLokasi);
    }
    selectedLokasi = dbLokasi;

    String? dbGrade = widget.data['grade'];
    if (dbGrade != null && dbGrade.isNotEmpty && !listGrade.contains(dbGrade)) {
      listGrade.add(dbGrade);
    }
    selectedGrade = dbGrade;
    beratC.text = widget.data['berat'].toString();
    gagalC.text = widget.data['gagal'].toString();
    
    if (widget.data['tanggal'] != null && widget.data['tanggal'] != "-") {
      selectedDate = DateTime.tryParse(widget.data['tanggal']);
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> updateData() async {
    setState(() => isLoading = true);
    final url = Uri.parse("https://farmlytic-fix-production.up.railway.app/update_data/${widget.data['id']}");

    try {
      var request = http.MultipartRequest('PUT', url);
      request.fields['komoditas'] = selectedKomoditas ?? "";
      request.fields['berat'] = beratC.text;
      request.fields['lokasi'] = selectedLokasi ?? "";
      request.fields['gagal'] = gagalC.text;
      request.fields['grade'] = selectedGrade ?? "";

      if (selectedDate != null) {
        request.fields['tanggal'] = formatDate(selectedDate!);
      }

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _image!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil diperbarui ✅")));
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Data", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Komoditas"),
              DropdownButtonFormField<String>(
                value: selectedKomoditas,
                items: listKomoditas.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (val) => setState(() => selectedKomoditas = val),
              ),
              const SizedBox(height: 12),
              
              const Text("Berat (kg)"),
              TextField(controller: beratC, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              const Text("Lokasi"),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedLokasi,
                items: listLokasi.map((l) {
                  return DropdownMenuItem<String>(
                    value: l,
                    child: Text(
                      l,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedLokasi = val),
              ),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Gagal Panen (%)"),
                        TextField(controller: gagalC, keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Grade"),
                        DropdownButtonFormField<String>(
                          value: selectedGrade,
                          items: listGrade.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setState(() => selectedGrade = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Text("Tgl Masuk Barang"),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  height: 45, width: double.infinity,
                  alignment: Alignment.centerLeft,
                  color: Colors.grey[200],
                  child: Text(selectedDate == null ? "Pilih Tanggal" : formatDate(selectedDate!)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Ganti Foto (Opsional)"),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 120, width: double.infinity,
                  color: Colors.grey[200],
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : (widget.data['foto'] != ""
                          ? CachedNetworkImage(
                              imageUrl: "https://farmlytic-fix-production.up.railway.app/uploads/${widget.data['foto']}",
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.camera_alt),
                            )
                          : const Icon(Icons.camera_alt, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: isLoading ? null : updateData,
                  child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Data", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}