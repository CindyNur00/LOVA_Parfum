import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/user_model.dart';
import 'package:tubes_parfum/ui/signup_page.dart';
import 'package:tubes_parfum/ui/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // This variable is not used for primary navigation since you're using Navigator.pushReplacement.
  // If this is for displaying UI after login without navigation, it can be kept.
  // For the case of navigating to HomeScreen, it can be ignored.
  bool _isLoggedIn = false;

  final String apiUrl = 'http://localhost:8080/api/login'; // Change if testing on a phone

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl), // Use the apiUrl variable
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] != null && data['status'] == 'success') {
          final userJson = data['user'] ?? {};
          final user = users.fromJson(userJson);
          print('Login successful: ${user.username}');

          // Call the success dialog that will navigate after OK
          _showSuccessDialog(data['message'] ?? 'Login successful!');
        } else {
          // If the API responds with 200 but 'success' is false (e.g., wrong credentials)
          _showErrorDialog(data['message'] ?? 'Incorrect username or password.');
        }
      } else {
        // If the status code is not 200 (e.g., 401, 500, etc.)
        _showErrorDialog('Server error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // If unable to connect to the server (e.g., offline, wrong URL)
      _showErrorDialog('Failed to connect to server: Ensure the server is running and internet connection is stable. Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NEW FUNCTION FOR SUCCESS DIALOG ---
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success!"), // More appropriate title
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // --- NAVIGATE TO HOME SCREEN HERE ---
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          )
        ],
      ),
    );
  }

  // --- FUNCTION FOR ERROR DIALOG (remains the same) ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context), // Just closes the dialog
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This _isLoggedIn part will be ignored if you always navigate to HomeScreen
    // after successful login. If this is a dashboard UI that appears on LoginPage
    // after login without navigation, then it can be kept.
    // For the purpose of navigating to HomeScreen, this part can be removed or ignored.
    if (_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("LOVA - Dashboard"),
          backgroundColor: const Color(0xFF781D26), // Primary color
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${_usernameController.text}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoggedIn = false;
                    _usernameController.clear();
                    _passwordController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF781D26), // Primary color
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE4CDDD), // Background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Logo Image
                Image.asset(
                  'src/assets/img/logo.png', // Adjust path in pubspec.yaml
                  width: 350,
                  height: 215,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome back!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Username cannot be empty' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        validator: (value) =>
                        value!.isEmpty ? 'Password cannot be empty' : null,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF781D26), // Primary color
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Sign In",
                            style: TextStyle(color: Colors.white), // Set text color to white
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF781D26), // Primary color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}