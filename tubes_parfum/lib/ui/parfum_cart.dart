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

class ParfumCart extends StatefulWidget {
  final users user;

  final List<ProductDetail> initialItems;

  const ParfumCart({
    super.key,
    required this.user,
    this.initialItems = const [],
  });

  @override
  _ParfumCartState createState() => _ParfumCartState();
}


class _ParfumCartState extends State<ParfumCart> {
  List<ProductDetail> parfumList = [];
  Map<String, int> quantityMap = {};
  Map<String, bool> selectedMap = {};

  @override
  void initState() {
    super.initState();

    parfumList = widget.initialItems;

    for (var p in parfumList) {
      quantityMap[p.id] = 1;
      selectedMap[p.id] = true; // default: sudah dipilih
    }
  }


  // Future<void> fetchParfumFromAPI() async {
  //   try {
  //     final response = await http.get(Uri.parse('http://localhost:8080/api/parfum'));
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       List<ProductDetail> list = data.map((item) => ProductDetail.fromJson(item)).toList();
  //
  //       setState(() {
  //         parfumList = list;
  //         for (var p in parfumList) {
  //           quantityMap[p.id] = 1;
  //           selectedMap[p.id] = false;
  //         }
  //       });
  //     } else {
  //       print('Gagal mengambil data. Status: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Terjadi kesalahan: $e');
  //   }
  // }

  double get total {
    return parfumList
        .where((item) => selectedMap[item.id] == true)
        .fold(0, (sum, item) => sum + ((item.price ?? 0) * (quantityMap[item.id] ?? 1))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: const Text(
          'Parfum Store',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.pinkAccent.withOpacity(0.4),
              child: Icon(Icons.person, color: Colors.pink),
            ),
          ),
        ],
      ),
      body: parfumList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: parfumList.length,
        itemBuilder: (context, index) {
          final item = parfumList[index];
          final id = item.id;
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMap[id] = !(selectedMap[id] ?? false);
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedMap[id]! ? Colors.pinkAccent : Colors.grey,
                        width: 2,
                      ),
                      color: selectedMap[id]! ? Colors.pinkAccent : Colors.transparent,
                    ),
                    child: selectedMap[id]!
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text(
                        'Rp. ${item.price.toStringAsFixed(2).replaceAll('.00', '.000,00')}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _qtyBtn(
                            icon: Icons.remove,
                            onTap: () {
                              if ((quantityMap[id] ?? 1) > 1) {
                                setState(() {
                                  quantityMap[id] = quantityMap[id]! - 1;
                                });
                              }
                            },
                          ),
                          SizedBox(width: 12),
                          Text('${quantityMap[id]}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(width: 12),
                          _qtyBtn(
                            icon: Icons.add,
                            onTap: () {
                              setState(() {
                                quantityMap[id] = quantityMap[id]! + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.local_florist, color: Color(0xFFFAE2EB), size: 30),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp. ${total.toStringAsFixed(2).replaceAll('.00', '.000,00')}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selectedItems = parfumList.where((item) => selectedMap[item.id] == true).toList();
                    if (selectedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pilih setidaknya 1 parfum untuk checkout.')),
                      );
                      return;
                    }

                    final List<CheckoutItem> checkoutItems = selectedItems.map((item) {
                      return CheckoutItem(
                        idPembayaran: 0,
                        namaBarang: item.name,
                        jenis: item.category ?? '-',
                        deskripsi: item.description,
                        harga: item.price,
                        jumlahBarang: quantityMap[item.id] ?? 1,
                        alamat: Address(
                          street: '',
                          city: '',
                          state: '',
                          zipCode: '',
                          country: 'Indonesia',
                        ),
                        tanggalPembayaran: '',
                        totalHarga: 0,
                        image: item.imageUrl ?? '',
                      );
                    }).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage(items: checkoutItems)),
                    ).then((value) {
                      if (value == true) {
                        setState(() {
                          parfumList.clear();
                          quantityMap.clear();
                          selectedMap.clear();
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout berhasil. Keranjang telah dikosongkan.')),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => HomeScreen(user: widget.user),
                ),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NotificationPage(user: widget.user)));
              } else if (index == 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ParfumCart(user: widget.user)));
              } else if (index == 3) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MyAccountPage(user: widget.user)));
              }
            },
            backgroundColor: Color(0xFFF7E6EF),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.pinkAccent,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
        ],
      ),

    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 16),
      ),
    );
  }
}
