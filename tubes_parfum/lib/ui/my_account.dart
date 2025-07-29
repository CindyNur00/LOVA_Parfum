import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/user_model.dart';
import 'dart:convert';

import 'package:tubes_parfum/ui/parfum_cart.dart';
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/ui/favorites_screen.dart';
import 'package:tubes_parfum/ui/History_page.dart';
import 'package:tubes_parfum/ui/faq.dart';

class MyAccountPage extends StatefulWidget {
  final users user;
  const MyAccountPage({Key? key, required this.user}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();

}

class _MyAccountPageState extends State<MyAccountPage> {
  int _currentIndex = 3;
  final String baseUrl = 'http://localhost:8080/api/user';

  Map<String, dynamic> userData = {
    'username': 'Username',
    'email': 'userEmail@gmail.com',
    'profile_image': '',
  };

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['data'];
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 30),
                  _buildMenuItem(Icons.favorite, 'Favorites', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritesScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.receipt_long, 'Order History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderHistoryScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.help_outline, 'FAQ', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.logout, 'Log Out', () {
                    _showLogoutDialog();
                  }),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE8A5A5), Color(0xFFD4A5A5)],
              ),
            ),
            child: userData['profile_image'] != null &&
                    userData['profile_image'].toString().isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(userData['profile_image'], fit: BoxFit.cover),
                  )
                : Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['username'] ?? 'Username',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(userData['email'] ?? 'userEmail@gmail.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                  child: Text('Edit Profile', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE8A5A5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            logout();
          }, child: Text('Logout')),
        ],
      ),
    );
  }
}
