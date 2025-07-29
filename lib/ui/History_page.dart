import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tubes_parfum/model/history.dart'; // Pastikan model Order ada di sini

import 'package:tubes_parfum/widgets/order_service.dart'; // Pastikan OrderService ada di sini

// Import halaman-halaman lain untuk BottomNavBar
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';
import 'package:tubes_parfum/ui/parfum_cart.dart'; // Pastikan ParfumCart sudah ada dan benar

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  bool isLoading = true;
  String error = '';
  int _currentIndex = 0; // Current index for BottomNavigationBar (set to 0 for Home or adjust as needed)

  @override
  void initState() {
    super.initState();
    _currentIndex = _getInitialPageIndex(); // Set initial index based on route
    fetchOrders();
  }

  // Helper function to determine initial index if coming from different tabs
  int _getInitialPageIndex() {
    // This is a simple example. In a real app, you might use arguments passed
    // via Navigator, or a global state manager to know the previous tab.
    // For OrderHistoryScreen, if it's considered a sub-page of "My Account",
    // then its index might be 3. If it's its own top-level tab, give it a unique index.
    // For now, let's assume it's part of MyAccount flow, so index 3.
    return 3; // Assuming Order History is associated with the profile/account tab
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final fetchedOrders = await OrderService.getOrders();
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // --- Metode _buildBottomNavBar() dipindahkan ke sini ---
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NotificationPage()));
                break;
              case 2:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ParfumCart()));
                break;
              case 3:
              // Sudah di halaman MyAccountPage, atau halaman terkait, jadi tidak navigasi
              // Jika OrderHistoryScreen adalah bagian dari MyAccountPage, maka ini sudah benar.
              // Jika OrderHistoryScreen adalah tab utama sendiri, maka pastikan ini adalah indeksnya.
              // Untuk sekarang, karena Anda di OrderHistoryScreen, tidak perlu navigasi lagi.
                break;
            }
          },
          backgroundColor: const Color(0xFFF7E6EF), // Transparan agar warna Container terlihat
          type: BottomNavigationBarType.fixed, // Penting untuk distribusi ikon merata
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
  // --------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F0F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFCA99AB),
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Tampilkan loading spinner
            : error.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error, style: const TextStyle(color: Color(0xFF781D26))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchOrders,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : orders.isEmpty
            ? const Center(child: Text('No orders found')) // Tampilkan jika tidak ada pesanan
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // Panggil metode BottomNavBar di sini
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shipping':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'pending': // Tambahkan status pending untuk QRIS
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesanan #${order.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(order.date),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(order.status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}