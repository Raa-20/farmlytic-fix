import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'beranda.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const primaryColor = Color(0xFF8BC346);

  String? selectedRole;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username dan Password wajib diisi")));
      return;
    }

    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan pilih role")));
      return;
    }

    setState(() { isLoading = true; });

    try {
      final url = Uri.parse("https://farmlytic-fix-production.up.railway.app/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "password": passwordController.text.trim(),
          "role": selectedRole,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', usernameController.text.trim());
        await prefs.setString('role', selectedRole!);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"] ?? "Login berhasil")));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BerandaPage(
              username: usernameController.text.trim(),
              role: selectedRole,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"] ?? "Login gagal")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak bisa konek ke server")));
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text("Sign In", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text("Hi Welcome Back, You've been missed", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 30),

                  const Align(alignment: Alignment.centerLeft, child: Text("Username")),
                  const SizedBox(height: 6),
                  buildTextField(controller: usernameController),
                  const SizedBox(height: 18),

                  const Align(alignment: Alignment.centerLeft, child: Text("Role")),
                  const SizedBox(height: 6),
                  buildDropdown(),
                  const SizedBox(height: 18),

                  const Align(alignment: Alignment.centerLeft, child: Text("Password")),
                  const SizedBox(height: 6),
                  buildTextField(controller: passwordController, isPassword: true),
                  const SizedBox(height: 6),

                  const Align(alignment: Alignment.centerRight, child: Text("Forgot Password?", style: TextStyle(color: Colors.grey, fontSize: 11))),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity, height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Sign In", style: TextStyle(fontSize: 14)),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("Or sign in With", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialButton(Icons.apple),
                      const SizedBox(width: 15),
                      socialButton(Icons.g_mobiledata),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller, obscureText: isPassword, style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      ),
    );
  }

  Widget buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRole, isExpanded: true,
      hint: const Text("Select Role", style: TextStyle(fontSize: 13)),
      items: const [
        DropdownMenuItem(value: "Petugas", child: Text("Petugas")),
        DropdownMenuItem(value: "Supervisor", child: Text("Supervisor")),
        DropdownMenuItem(value: "Dinas", child: Text("Dinas")),
      ],
      onChanged: (value) { setState(() { selectedRole = value; }); },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      ),
    );
  }

  Widget socialButton(IconData icon) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Icon(icon, size: 22),
    );
  }
}