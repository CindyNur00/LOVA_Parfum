import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tubes_parfum/model/notifikasi.dart';
import 'package:tubes_parfum/model/user_model.dart';

// Tambahkan import halaman lain jika sudah ada
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/parfum_cart.dart';

import 'package:tubes_parfum/widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  final users user;

  const NotificationPage({Key? key, required this.user}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/notifikasi'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _notifications = jsonData.map((e) => NotificationModel.fromJson(e)).toList();
        });
      } else {
        print('Gagal mengambil data notifikasi. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat fetch notifikasi: $e');
    }
  }

  Future<void> onRefresh() async {
    await fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notif = _notifications[index];
            return NotificationCard(
              notification: notif,
              onTap: () {
                // Tambahkan aksi kalau mau mark as read, dll.
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1, user: widget.user),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final users user;

  const BottomNavBar({Key? key, required this.currentIndex, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(user: user)));
            break;
          case 1:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NotificationPage(user: user)));
            break;
          case 2:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ParfumCart(user: user)));
            break;
          case 3:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyAccountPage(user: user)));
            break;
        }
      },
      backgroundColor: Color(0xFFF7E6EF),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pinkAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }
}




  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isActive ? Color(0xFF8B4B8B) : Color(0xFFB8A5B8),
        size: 28,
      ),
    );
  }
