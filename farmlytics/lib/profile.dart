import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'beranda.dart';
import 'custom_navbar.dart';
import 'kelola_account.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  final String? role;
  const ProfilePage({super.key, this.username, this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String email = "";
  String username = "";
  String foto = "";
  bool isLoading = true;

  String imageVersion = "";

  File? _image;
  final ImagePicker _picker = ImagePicker();

  static const primaryColor = Color(0xFF8BC346);

  bool get isGuest =>
      widget.username == null ||
      widget.username!.isEmpty ||
      widget.role == null;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedRole = prefs.getString('role');

    if (savedUsername == null ||
        savedUsername.isEmpty ||
        savedRole == null ||
        savedRole.isEmpty ||
        isGuest) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    if (savedUsername != widget.username || savedRole != widget.role) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      imageVersion =
          prefs.getString('profile_pic_version_${widget.username}') ?? "";
    });

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("https://farmlytic-fix-production.up.railway.app/profile/${widget.username}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          email = data['email'] ?? "";
          username = data['username'] ?? "";
          foto = data['foto'] ?? "";
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal mengambil profile")));
    }
  }

  Future<void> uploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://farmlytic-fix-production.up.railway.app/upload_foto/$username"),
      );
      request.files.add(
        await http.MultipartFile.fromPath('foto', pickedFile.path),
      );
      var response = await request.send();

      if (response.statusCode == 200) {
        String newVersion = DateTime.now().millisecondsSinceEpoch.toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_pic_version_$username', newVersion);

        if (!mounted) return;
        setState(() {
          _image = File(pickedFile.path);
          imageVersion = newVersion;
        });

        fetchProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload berhasil"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi error upload"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deletePhoto() async {
    try {
      final response = await http.delete(
        Uri.parse("https://farmlytic-fix-production.up.railway.app/delete_foto/$username"),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('profile_pic_version_$username');

        if (!mounted) return;
        setState(() {
          _image = null;
          foto = "";
          imageVersion = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Foto berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menghapus foto"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void handleEditPhoto() {
    if (_image == null && foto.isEmpty) {
      uploadPhoto();
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Ganti Foto"),
                  onTap: () {
                    Navigator.pop(context);
                    uploadPhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Hapus Foto"),
                  onTap: () {
                    Navigator.pop(context);
                    deletePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Apakah kamu yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                await prefs.remove('username');
                await prefs.remove('role');

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BerandaPage(username: null, role: null),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = "https://farmlytic-fix-production.up.railway.app/uploads/$foto";
    if (imageVersion.isNotEmpty) {
      imageUrl += "?v=$imageVersion";
    } else if (foto.isNotEmpty) {
      imageUrl +=
          "?v=bypass_error_lama"; 
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SafeArea(
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
                            }
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 104,
                                    height: 104,
                                    child: _image != null
                                        ? Image.file(_image!, fit: BoxFit.cover)
                                        : (foto.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        return Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Center(
                                                            child: SizedBox(
                                                              width: 25,
                                                              height: 25,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                )
                                              : Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                )),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: handleEditPhoto,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Account",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (widget.role == 'Petugas')
                      menuItem(
                        Icons.chat,
                        "Input Via WhatsApp",
                        onTap: () async {
                          const String noWaBot = "6285943743546";
                          const String pesan = "Halo Ladentra!";

                          final Uri waUrl = Uri.parse(
                            "whatsapp://send?phone=$noWaBot&text=${Uri.encodeComponent(pesan)}",
                          );

                          if (await canLaunchUrl(waUrl)) {
                            await launchUrl(waUrl);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Aplikasi WhatsApp tidak ditemukan di perangkat ini!",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),

                    menuItem(
                      Icons.settings,
                      "Kelola Account",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KelolaAccountPage(
                              username: username,
                              email: email,
                              role: widget.role,
                            ),
                          ),
                        );
                      },
                    ),
                    menuItem(Icons.info, "App Version", trailing: "v1.00"),
                    menuItem(Icons.logout, "Logout", onTap: logout),
                    const Spacer(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: 3,
        username: widget.username ?? "",
        role: widget.role ?? "",
      ),
    );
  }

  Widget menuItem(
    IconData icon,
    String title, {
    String? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              if (trailing != null)
                Text(trailing, style: const TextStyle(color: Colors.grey)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 10),
      ],
    );
  }
}
