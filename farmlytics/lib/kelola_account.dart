import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KelolaAccountPage extends StatefulWidget {
  final String username;
  final String? email; 
  final String? role;
  const KelolaAccountPage({super.key, required this.username, this.email, this.role});

  @override
  State<KelolaAccountPage> createState() => _KelolaAccountPageState();
}

class _KelolaAccountPageState extends State<KelolaAccountPage> {
  final TextEditingController emailController = TextEditingController(); 
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  static const primaryColor = Color(0xFF8BC346);

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.username;
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
    getData();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    try {
      final response = await http.get(
        Uri.parse("https://farmlytic-fix-production.up.railway.app/profile/${widget.username}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emailController.text = data['email'] ?? ""; 
          usernameController.text = data['username'] ?? "";
          phoneController.text = data['no_hp'] ?? "";
        });
      } else {
        showMessage("Gagal mengambil data");
      }
    } catch (e) {
      showMessage("Terjadi error koneksi");
    }
  }

  Future<void> updateAccount() async {
    if (emailController.text.trim().isEmpty) {
      showMessage("Email tidak boleh kosong");
      return;
    }
    if (usernameController.text.trim().isEmpty) {
      showMessage("Username tidak boleh kosong");
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      showMessage("Nomor HP tidak boleh kosong");
      return;
    }
    if (passwordController.text.isNotEmpty && passwordController.text.length < 6) {
      showMessage("Password minimal 6 karakter");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showMessage("Konfirmasi password tidak cocok");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse("https://farmlytic-fix-production.up.railway.app/update_account"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": widget.username,
          "email": emailController.text,
          "new_username": usernameController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
        }),
      );

      final data = json.decode(response.body);
      showMessage(data['message']);

      if (data['status'] == "success") {
        Navigator.pop(context, usernameController.text);
      }
    } catch (e) {
      showMessage("Gagal koneksi ke server");
    }

    setState(() => isLoading = false);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Kelola Account"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInput("Username", usernameController, "Masukkan username"),
            buildInput("Email", emailController, "Masukkan email"),
            buildInput("Nomor HP", phoneController, "Masukkan nomor HP", keyboard: TextInputType.phone),
            buildInput("Password Baru", passwordController, "Masukkan password baru", isPassword: true),
            buildInput("Konfirmasi Password", confirmPasswordController, "Ulangi password", isPassword: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(
    String label, TextEditingController controller, String hint, 
    {bool isPassword = false, TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboard,
          decoration: inputStyle(hint),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}