import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/notifikasi.dart';
import 'package:tubes_parfum/model/user_model.dart';

// Add imports for other pages if they exist
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/parfum_cart.dart';

import 'package:tubes_parfum/widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  int _currentIndex = 1; // <-- Deklarasikan _currentIndex di sini dan set ke 1 (untuk Notifications)

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

        // Convert JSON to NotificationModel objects
        List<NotificationModel> fetchedNotifications =
        jsonData.map((e) => NotificationModel.fromJson(e)).toList();

        // --- ADD THE SORTING LOGIC HERE ---
        fetchedNotifications.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        // ----------------------------------

        setState(() {
          _notifications = fetchedNotifications;
        });
      } else {
        print('Failed to retrieve notification data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while fetching notifications: $e');
    }
  }

  Future<void> onRefresh() async {
    await fetchNotifications();
  }

  Widget _buildBottomNavBar() {
    return ClipRRect( // ClipRRect untuk memotong sesuai radius
      borderRadius: const BorderRadius.all(Radius.circular(40)), // Radius harus sesuai dengan Container
      child: BottomNavigationBar(
        currentIndex: _currentIndex, // Gunakan _currentIndex dari State ini
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Selalu update _currentIndex di setState
          });

          // Logika navigasi menggunakan pushReplacement untuk berpindah antar tab
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              break;
            case 1:
            // Sudah di halaman Notifikasi, tidak perlu navigasi lagi
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ParfumCart()));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyAccountPage()));
              break;
          }
        },
        backgroundColor: const Color(0xFFF7E6EF), // Transparan agar warna Container terlihat
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF781D26),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications History"),
        backgroundColor: const Color(0xFFCA99AB), // AppBar background
        leading: IconButton( // Tambahkan tombol kembali
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Tampilkan loading spinner jika kosong
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notif = _notifications[index];
            return NotificationCard(
              notification: notif,
              onTap: () {
                // Add action if you want to mark as read, etc.
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // <-- Panggil metode di sini
    );
  }
}