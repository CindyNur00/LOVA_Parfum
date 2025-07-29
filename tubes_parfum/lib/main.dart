import 'package:flutter/material.dart';
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/dashboard_page.dart';

// Tambahkan import halaman lain jika sudah ada
import 'package:tubes_parfum/ui/parfum_cart.dart';
import 'package:tubes_parfum/ui/my_account.dart';
import 'package:tubes_parfum/ui/notifikasi_page.dart';

import 'package:tubes_parfum/ui/signup_page.dart';
import 'package:tubes_parfum/ui/login_page.dart';

import 'package:tubes_parfum/model/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Parfum',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',              // ← Langsung ke login
      routes: {
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignUpPage(),
        '/home': (context) {
          final users user = ModalRoute.of(context)!.settings.arguments as users;
          return HomeScreen(user: user);
        },
        '/notifications': (context) {
          final u = ModalRoute.of(context)!.settings.arguments as users;
          return NotificationPage(user: u);
        },
        '/cart': (context) {
          final users user = ModalRoute.of(context)!.settings.arguments as users;
          return ParfumCart(user: user);
        },
        '/profile': (context) {
          final users user = ModalRoute.of(context)!.settings.arguments as users;
          return MyAccountPage(user: user);
        },
      },

    );
  }
}


