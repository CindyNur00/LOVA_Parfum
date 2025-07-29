import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for json.decode and json.encode
// For local storage of token (uncomment if using)
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tubes_parfum/ui/login_page.dart'; // Import if redirecting on 401

class EditProfilePage extends StatefulWidget {
  final String userId; // User ID passed from MyAccountPage

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedImage = 'assets/img/profile_picture/avatar1.jpg';
  bool _isLoading = false;

  final List<String> _profileOptions = List.generate(
    8,
        (index) => 'assets/img/profile_picture/avatar${index + 1}.jpg',
  );

  final String baseUrl = 'http://localhost:8080/api'; // Your CI API base URL

  @override
  void initState() {
    super.initState();
    _fetchCurrentProfileData(); // Fetch existing user data when page loads
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- API Call to Fetch Current User Data ---
  Future<void> _fetchCurrentProfileData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // --- IMPORTANT: Retrieve the actual token from local storage ---
      // Example using SharedPreferences (you need to add the dependency and implement login token saving):
      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString('user_token');

      // if (token == null) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Autentikasi diperlukan. Silakan login kembali.')),
      //     );
      //     Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login
      //       (Route<dynamic> route) => false,
      //     );
      //   }
      //   _isLoading = false;
      //   return;
      // }

      // Use widget.userId if your API requires it in the URL, otherwise, remove it.
      // E.g., '$baseUrl/user/${widget.userId}' OR just '$baseUrl/user' if token identifies user.
      final response = await http.get(
        Uri.parse('$baseUrl/user/${widget.userId}'), // Assuming API endpoint is /user/{userId} for fetching
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ACTUAL_TOKEN_HERE', // REPLACE with actual token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Assuming your API response structure is like { "status": "success", "data": { ...user_data... } }
        if (responseData['status'] == 'success' && responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> userData = responseData['data'];

          if (mounted) {
            setState(() {
              _nameController.text = userData['username'] ?? ''; // Adjust key names to match API
              _emailController.text = userData['email'] ?? '';
              _phoneController.text = userData['phone'] ?? ''; // Assuming 'phone' field
              _addressController.text = userData['address'] ?? ''; // Assuming 'address' field
              _selectedImage = userData['profile_image_path'] ?? 'assets/img/profile_picture/avatar1.jpg'; // Adjust if API returns full URL
            });
          }
        } else {
          // API returned 200 but status is not success or data is malformed
          if (mounted) _showErrorSnackBar(responseData['message'] ?? 'Gagal memuat profil: Data tidak valid.');
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          _showErrorSnackBar('Sesi berakhir. Silakan login kembali.');
          // Uncomment and implement actual redirection
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (context) => LoginPage()),
          //   (Route<dynamic> route) => false,
          // );
        }
      } else {
        // Handle other HTTP errors
        if (mounted) _showErrorSnackBar('Gagal memuat profil: Status ${response.statusCode}');
      }
    } catch (e) {
      // Handle network/connection errors
      if (mounted) _showErrorSnackBar('Error koneksi: Gagal memuat profil. $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  // --- API Call to Update User Data ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form validation fails
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // --- IMPORTANT: Retrieve the actual token ---
      // final prefs = await SharedPreferences.getInstance();
      // final String? token = prefs.getString('user_token');
      // if (token == null) {
      //   if (mounted) {
      //     _showErrorSnackBar('Autentikasi diperlukan untuk update profil.');
      //     // Redirect to login
      //   }
      //   _isLoading = false;
      //   return;
      // }

      final Map<String, dynamic> requestBody = {
        'username': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text, // Ensure your API expects this field
        'address': _addressController.text, // Ensure your API expects this field
        'profile_image_path': _selectedImage, // Send path, or base64 if your API expects that
      };

      final response = await http.put( // Use http.put for updating resources
        Uri.parse('$baseUrl/user/${widget.userId}'), // Assuming API endpoint is /user/{userId} for update
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ACTUAL_TOKEN_HERE', // REPLACE with actual token
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          if (mounted) {
            _showSuccessDialog(responseData['message'] ?? 'Profil berhasil diperbarui!');
          }
        } else {
          if (mounted) _showErrorSnackBar(responseData['message'] ?? 'Gagal memperbarui profil.');
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          _showErrorSnackBar('Sesi berakhir. Silakan login kembali.');
          // Redirect to login
        }
      } else {
        if (mounted) _showErrorSnackBar('Gagal memperbarui profil: Status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error koneksi: Gagal memperbarui profil. $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Pop back to previous screen (MyAccountPage)
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: _profileOptions
              .map((path) => GestureDetector(
            onTap: () {
              setState(() => _selectedImage = path);
              Navigator.pop(context);
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(path),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '$label tidak boleh kosong';
            if (label == "Email" && !value.contains("@")) return 'Format email tidak valid';
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: _isLoading ? null : _updateProfile, // Call _updateProfile on check icon tap
          ),
        ],
      ),
      body: _isLoading // Show loading indicator over body if fetching data
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImagePickerDialog,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(_selectedImage),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Ganti Foto Profil', style: TextStyle(color: Colors.pink)),
              const SizedBox(height: 30),
              _buildTextField("Name", _nameController),
              const SizedBox(height: 20),
              _buildTextField("Email", _emailController, type: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField("Phone", _phoneController, type: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField("Address", _addressController, maxLines: 3),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}