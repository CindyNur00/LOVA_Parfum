import 'package:flutter/material.dart';
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/dashboard_page.dart';

// Tambahkan import halaman lain jika sudah ada
import 'package:tubes_parfum/ui/parfum_cart.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/ui/signup_page.dart';
import 'package:tubes_parfum/ui/login_page.dart';
import 'package:tubes_parfum/ui/History_page.dart';
import 'package:tubes_parfum/ui/faq.dart';
import 'package:tubes_parfum/ui/edit_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Removed userId from MyApp constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Parfum',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Starting directly to login

      // Use onGenerateRoute for routes that need arguments or complex logic
      onGenerateRoute: (settings) {
        // Handle /dashboard route if it requires userId
        if (settings.name == '/edit_profile') {
          // Assuming arguments are passed as a Map<String, dynamic>
          // Example: Navigator.pushNamed(context, '/dashboard', arguments: {'userId': someUserId});
          final args = settings.arguments as Map<String, dynamic>?; // Make args nullable
          final userId = args?['userId']; // Safely retrieve userId

          if (userId != null) {
            return MaterialPageRoute(builder: (_) => EditProfilePage(userId: userId));
          } else {
            // Handle case where userId is missing, e.g., redirect to login or show error
            return MaterialPageRoute(builder: (_) => LoginPage()); // Or some error page
          }
        }
        // If the route is not handled by onGenerateRoute, fallback to the routes map
        return null; // Let the 'routes' map handle other routes
      },

      // Define standard routes here
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
        '/my-account': (context) => MyAccountPage(),
        '/notifications': (context) => NotificationPage(),
        '/cart': (context) => ParfumCart(),
        '/order-history': (context) => OrderHistoryScreen(),
        '/faq': (context) => FAQScreen(),
        // '/dashboard': (context) => DashboardPage(), // If DashboardPage doesn't need userId, you can put it here
        // The EditProfilePage was previously defined without a userId parameter,
        // so it can be placed directly in the routes map.
        // '/edit-profile': (context) => const EditProfilePage(userId: userId), // Assuming EditProfilePage doesn't require userId
      },
    );
  }
}

