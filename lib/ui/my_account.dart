import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tubes_parfum/ui/parfum_cart.dart';
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/ui/favorites_screen.dart';
import 'package:tubes_parfum/ui/History_page.dart';
import 'package:tubes_parfum/ui/faq.dart';
import 'package:tubes_parfum/ui/edit_profile.dart';

class MyAccountPage extends StatefulWidget {
  @override
  _MyAccountPageState createState() => _MyAccountPageState();

}

class _MyAccountPageState extends State<MyAccountPage> {
  int _currentIndex = 3;
  final String baseUrl = 'http://localhost:8080/api';

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
      // --- IMPORTANT: Retrieve the actual token from local storage ---
      // This is crucial. 'YOUR_TOKEN_HERE' is a placeholder.
      // Example using SharedPreferences (you'll need to add the dependency):
      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString('user_token'); // Get the token saved during login

      // If no token is found, you might want to redirect to login
      // if (token == null) {
      //   print('No authentication token found. Redirecting to login.');
      //   if (mounted) { // Check if the widget is still in the tree before navigating
      //     Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (context) => LoginPage()), // Assuming LoginPage is imported
      //       (Route<dynamic> route) => false,
      //     );
      //   }
      //   return; // Stop execution if no token
      // }

      // Make sure baseUrl is defined in your class, e.g., `final String baseUrl = 'http://localhost:8080/api';`
      final response = await http.get(
        Uri.parse('$baseUrl/user'), // Changed to /user/profile as that's typical,
        // or if your endpoint is just /user, keep it that way.
        // Based on your MyAccountPage, you used '$baseUrl/profile'.
        // Let's assume '$baseUrl/user/profile' or just '$baseUrl/profile'
        // is the correct endpoint. I'll use '$baseUrl/profile' to match
        // your MyAccountPage logic.
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Use the actual retrieved token
          'Authorization': 'Bearer YOUR_ACTUAL_TOKEN_HERE', // Keep this placeholder for now, but remember to replace it
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
          'Authorization': 'Bearer YOUR_ACTUAL_TOKEN_HERE', // Critical!
        },
      );

      if (response.statusCode == 200) {
        // --- IMPORTANT: Clear your token/session data here ---
        // For example, using shared_preferences:
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.remove('user_token');
        // await prefs.remove('user_id');
        // ---------------------------------------------------

        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => EditProfilePage()),
        //       (Route<dynamic> route) => false,
        // );
      } else {
        // Handle logout failure
        print('Failed to log out: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout. Please try again.')),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4CDDD), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            // _buildMenuItem(Icons.favorite, 'Favorites', () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => FavoritesScreen()),
            //   );
            // }),
            _buildMenuItem(Icons.receipt_long, 'Notifications History', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
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
      bottomNavigationBar: ClipRRect( // <-- ClipRRect untuk memotong sesuai radius
        borderRadius: const BorderRadius.all(Radius.circular(40)), // Radius harus sesuai dengan Container
        child:BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => HomeScreen()));
              } else if (index == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NotificationPage()));
              } else if (index == 2) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ParfumCart()));
              } else if (index == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyAccountPage()));
              }
            },
            backgroundColor: const Color(0xFFF7E6EF),
            // Lighter background for nav bar
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF781D26),
            // Primary color for selected item
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
          ),
        );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFCA99AB),
                  Color(0xFF893A49)
                ], // Lighter to Accent
              ),
            ),
            child: userData['profile_image'] != null &&
                userData['profile_image']
                    .toString()
                    .isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                  userData['profile_image'], fit: BoxFit.cover),
            )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['username'] ?? 'Username',
                    style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(userData['email'] ?? 'userEmail@gmail.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/edit_profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCA99AB),
                    // Lighter background color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                      'Edit Profile', style: TextStyle(fontSize: 12)),
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
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF893A49)),
        // Accent color for icons
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  logout(); // Call your logout function which should handle navigation
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

}