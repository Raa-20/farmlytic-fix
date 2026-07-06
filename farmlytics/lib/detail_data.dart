import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailDataPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailDataPage({super.key, required this.data});
  static const primaryColor = Color(0xFF8BC346);

  @override
  Widget build(BuildContext context) {
    String image = data['foto'] ?? "";
    bool isVoice = data['cara_input'] == 'voice';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detail Data", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              CachedNetworkImage(
                imageUrl: "https://farmlytic-fix-production.up.railway.app/uploads/$image",
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              
              Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['komoditas'] ?? "-",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isVoice ? Colors.green[100] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isVoice ? "Voice Input" : "Manual Input",
                            style: TextStyle(
                              fontSize: 12,
                              color: isVoice ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 20),
                    _buildDetailRow(Icons.scale, "Berat", "${data['berat'] ?? '0'} kg"),
                    _buildDetailRow(Icons.location_on, "Lokasi", data['lokasi'] ?? "-"),
                    _buildDetailRow(Icons.warning_amber_rounded, "Gagal Panen", "${data['gagal'] ?? '0'} %"),
                    _buildDetailRow(Icons.star_border, "Grade", data['grade'] ?? "-"),
                    _buildDetailRow(Icons.calendar_today, "Tanggal Masuk", data['tanggal'] ?? "-"),
                    _buildDetailRow(Icons.access_time, "Waktu Input Form", data['created_at'] ?? "-"),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          const Text(":", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}