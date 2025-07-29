import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sukses'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _showSuccessDialog('Profil berhasil diperbarui');
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
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
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            onPressed: _isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
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
              SizedBox(height: 16),
              Text('Ganti Foto Profil', style: TextStyle(color: Colors.pink)),
              SizedBox(height: 30),
              _buildTextField("Name", _nameController),
              SizedBox(height: 20),
              _buildTextField("Email", _emailController, type: TextInputType.emailAddress),
              SizedBox(height: 20),
              _buildTextField("Phone", _phoneController, type: TextInputType.phone),
              SizedBox(height: 20),
              _buildTextField("Address", _addressController, maxLines: 3),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
