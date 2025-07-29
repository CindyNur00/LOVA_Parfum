import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/product_model.dart';
import 'package:tubes_parfum/model/user_model.dart';
import 'package:tubes_parfum/ui/checkout_page.dart';
import 'package:tubes_parfum/model/checkout.dart';
import 'package:tubes_parfum/model/address.dart';

// Tambahkan import halaman lain jika sudah ada
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/widgets/cart_manager.dart';

class ParfumCart extends StatefulWidget {
  // final List<ProductDetail> initialItems; // Ini tidak diperlukan lagi jika pakai CartManager
  const ParfumCart({Key? key}) : super(key: key); // Konstruktor tanpa initialItems

  @override
  _ParfumCartState createState() => _ParfumCartState();
}

class _ParfumCartState extends State<ParfumCart> {

  int quantity = 1; // Ini mungkin dari ProductDetailScreen, tidak perlu di sini
  bool isFavorite = false; // Ini mungkin dari ProductDetailScreen, tidak perlu di sini

  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener agar UI keranjang otomatis update
    CartManager().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    // Panggil setState untuk merebuild UI saat keranjang berubah
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager().items; // Ambil item dari CartManager

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Color(0xFFE8C4D8),
        foregroundColor: Colors.black,
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty!'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItemTile(item); // Buat widget tile untuk setiap item
              },
            ),
          ),
          // Bagian bawah dengan Total dan Pay Now
          _buildCartSummary(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCartItemTile(CartItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFE8C4D8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFCA99AB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.product.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp. ${item.product.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (item.quantity > 1) {
                            CartManager().updateQuantity(item.product.id, item.quantity - 1);
                          } else {
                            // Hapus item jika kuantitasnya 1 dan dikurangi lagi
                            CartManager().removeItem(item.product.id);
                          }
                        },
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () {
                          CartManager().updateQuantity(item.product.id, item.quantity + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                CartManager().removeItem(item.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rp. ${CartManager().totalCartPrice.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4C1208)),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (CartManager().items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Keranjang Anda kosong!')),
                  );
                  return;
                }
                // INI ADALAH TITIK KRITIS!
                // Ubah semua CartItem menjadi CheckoutItem dan teruskan ke CheckoutPage
                final List<CheckoutItem> checkoutItems = CartManager().items.map((cartItem) {
                  return cartItem.toCheckoutItem();
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(items: checkoutItems),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF893A49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index; // Update currentIndex saat tab diubah
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                break;
              case 1:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NotificationPage()));
                break;
              case 2:
              // Sudah di halaman keranjang, tidak perlu navigasi lagi
                break;
              case 3:
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyAccountPage()));
                break;
            }
          },
          backgroundColor: const Color(0xFFF7E6EF),
          type: BottomNavigationBarType.fixed, // Penting untuk distribusi ikon merata
          selectedItemColor: const Color(0xFF781D26),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Padding( // <-- Tambahkan Padding di sini
                padding: EdgeInsets.only(bottom: 0.0), // Sesuaikan nilai ini (misal: 2.0 atau 4.0)
                child: Icon(Icons.home),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding( // <-- Tambahkan Padding di sini
                padding: EdgeInsets.only(bottom: 0.0), // Sesuaikan nilai ini
                child: Icon(Icons.notifications),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding( // <-- Tambahkan Padding di sini
                padding: EdgeInsets.only(bottom: 0.0), // Sesuaikan nilai ini
                child: Icon(Icons.shopping_cart),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Padding( // <-- Tambahkan Padding di sini
                padding: EdgeInsets.only(bottom: 0.0), // Sesuaikan nilai ini
                child: Icon(Icons.person),
              ),
              label: '',
            ),
          ],
        ),
    );
  }
}