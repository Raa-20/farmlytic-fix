import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_navbar.dart';
import 'input.dart';
import 'history.dart';

class VoiceInputPage extends StatefulWidget {
  final String username;
  final String role;

  const VoiceInputPage({
    super.key,
    required this.username,
    required this.role,
  });

  static const primaryColor = Color(0xFF8BC346);

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  late stt.SpeechToText speech;

  bool isListening = false;
  bool isSpeechAvailable = false;
  bool isLoading = false;

  String text = "Tekan tombol mic dan mulai bicara";

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    initSpeech();
  }

  void initSpeech() async {
    isSpeechAvailable = await speech.initialize(
      onStatus: (status) {
        print("STATUS: $status");
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => isListening = false);
        }
      },
      onError: (error) => print("ERROR: $error"),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void startListening() async {
    if (!isSpeechAvailable) return;

    setState(() => isListening = true);

    speech.listen(
      localeId: "id_ID",
      pauseFor: const Duration(seconds: 10),
      listenFor: const Duration(seconds: 60), 
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          text = result.recognizedWords;
        });
      },
    );
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveData() async {
    if (text == "Tekan tombol mic dan mulai bicara" || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap rekam suara terlebih dahulu!"),
        ),
      );
      return;
    }

    final url = Uri.parse("https://farmlytic-fix-production.up.railway.app/input");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['text'] = text;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            _image!.path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data suara & foto berhasil disimpan ✅"),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryPage(
              username: widget.username,
              role: widget.role,
            ),
          ),
        );
      } else {
        final resBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${resBody['error'] ?? response.body}"),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error koneksi: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasVoice = text != "Tekan tombol mic dan mulai bicara" && text.isNotEmpty;

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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPage(
                                username: widget.username,
                                role: widget.role,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Voice Input",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: boxStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pilih Metode Input",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: methodCard(
                              context,
                              "Input Manual",
                              "Ketik Data Secara Manual",
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InputPage(
                                    username: widget.username,
                                    role: widget.role,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: methodCard(
                              context,
                              "Voice Input",
                              "Menggunakan suara",
                              isActive: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue[800],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Tips Bicara (Voice Guide)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pastikan kalimatmu menyebutkan unsur berikut agar sistem mudah memahaminya:",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      _buildTipItem("🍅 Komoditas", "(Contoh: Cabai, Tomat)"),
                      _buildTipItem("⚖️ Berat", "(Sebutkan angka dan Kilo/Kwintal/Ton)"),
                      _buildTipItem("📍 Lokasi", "(Contoh: Desa Plaosan)"),
                      _buildTipItem("📉 Gagal Panen", "(Sebutkan angka dan Persen)"),
                      _buildTipItem("⭐ Grade", "(Sebutkan A, B, atau C)"),
                      _buildTipItem("📅 Tanggal", "(Sebutkan tanggal spesifik atau 'hari ini')"),
                      const SizedBox(height: 12),
                      const Text(
                        'Contoh: "Panen tomat 50 kilo di Desa Plaosan, gagal panen 5 persen, grade A, tanggal 3 Mei 2026."',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: boxStyle(),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!isListening) {
                            startListening();
                          } else {
                            stopListening();
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isListening
                                  ? [Colors.red, Colors.redAccent]
                                  : [const Color(0xFF8BC346), const Color(0xFFB5E07A)],
                            ),
                          ),
                          child: Icon(
                            isListening ? Icons.stop : Icons.mic,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isListening ? "Listening..." : "Voice Input",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: boxStyle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Foto Dokumentasi (Opsional)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Tap untuk upload foto",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: hasVoice ? saveData : null,
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          decoration: BoxDecoration(
                            color: hasVoice ? VoiceInputPage.primaryColor : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Simpan Dan Lanjutkan",
                              style: TextStyle(
                                color: hasVoice ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 2,
        username: widget.username,
        role: widget.role,
      ),
    );
  }

  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
        ),
      ],
    );
  }

  Widget methodCard(
    BuildContext context,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? VoiceInputPage.primaryColor.withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? VoiceInputPage.primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}