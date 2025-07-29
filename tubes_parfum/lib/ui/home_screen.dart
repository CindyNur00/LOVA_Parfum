import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/product_model.dart';
import 'package:tubes_parfum/widgets/product_card.dart';

// Tambahkan import halaman lain jika sudah ada
import 'package:tubes_parfum/ui/parfum_cart.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/model/user_model.dart';

class HomeScreen extends StatefulWidget {
  final users user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  List<ProductDetail> products = [];
  List<String> categories = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProductsFromAPI();
  }

  Future<void> fetchProductsFromAPI() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/parfum'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map((json) => ProductDetail.fromJson(json)).toList();
          categories = ['All'];
          categories.addAll(products
              .map((e) => e.category ?? '-')
              .toSet()
              .where((e) => e.trim().isNotEmpty));
          isLoading = false;
        });
      } else {
        print('Gagal mengambil data produk. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error saat mengambil produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ProductDetail> getFilteredProducts() {
    List<ProductDetail> filtered = products;

    if (selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // Sudah di home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage(user: widget.user)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ParfumCart(user: widget.user)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyAccountPage(user: widget.user)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7E6F1),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7E6EE),
        elevation: 0,
        leading: Container(),
        title: Row(
          children: [
        Text("Hi, ${widget.user.username}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            CircleAvatar(
              backgroundImage: NetworkImage('https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&s=40'),
              radius: 20,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.tune, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.white.withOpacity(0.8),
                            selectedColor: Colors.pinkAccent.withOpacity(0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: getFilteredProducts().length,
                itemBuilder: (context, index) {
                  final product = getFilteredProducts()[index];
                  return ProductCard(
                    product: product,
                    user: widget.user,
                    onFavoriteToggle: () {
                      setState(() {
                        product.isFavorite = !product.isFavorite;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _currentIndex = index;
            });
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage(user: widget.user)));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ParfumCart(user: widget.user)),
            );
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyAccountPage(user: widget.user)));
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
    );
  }
}
