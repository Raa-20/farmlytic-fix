import 'package:flutter/material.dart';
import 'history.dart';
import 'beranda.dart';
import 'input.dart';
import 'profile.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final String? username;
  final String role;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    this.username,
    required this.role,
  });

  static const Color primaryColor =
      Color(0xFF8BC346);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Username tidak ditemukan, silakan login ulang",
          ),
        ),
      );
      return;
    }

    Widget page;

    if (role == "Petugas") {
      switch (index) {
        case 0:
          page = BerandaPage(
            username: username!,
            role: role,
          );
          break;

        case 1:
          page = HistoryPage(
            username: username!,
            role: role,
          );
          break;

        case 2:
          page = InputPage(
            username: username!,
            role: role,
          );
          break;

        case 3:
          page = ProfilePage(
            username: username!,
            role: role,
          );
          break;

        default:
          page = BerandaPage(
            username: username!,
            role: role,
          );
      }
    }

    else {
      switch (index) {
        case 0:
          page = BerandaPage(
            username: username!,
            role: role,
          );
          break;

        case 1:
          page = HistoryPage(
            username: username!,
            role: role,
          );
          break;

        case 2:
          page = ProfilePage(
            username: username!,
            role: role,
          );
          break;

        default:
          page = BerandaPage(
            username: username!,
            role: role,
          );
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: role == "Petugas"
            ? [
                _navItem(
                    context,
                    Icons.home,
                    0),
                _navItem(
                    context,
                    Icons.article,
                    1),
                _navItem(
                    context,
                    Icons.add_box,
                    2),
                _navItem(
                    context,
                    Icons.person,
                    3),
              ]
            : [
                _navItem(
                    context,
                    Icons.home,
                    0),
                _navItem(
                    context,
                    Icons.article,
                    1),
                _navItem(
                    context,
                    Icons.person,
                    2),
              ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Icon(
        icon,
        color: currentIndex == index
            ? primaryColor
            : Colors.grey,
      ),
    );
  }
}