import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/checkout.dart';
import 'package:tubes_parfum/model/address.dart';

class CheckoutPage extends StatefulWidget {
  final List<CheckoutItem> items;

  const CheckoutPage({super.key, required this.items});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const String baseUrl = 'http://localhost:8080/api/pembayaran';

  late List<CheckoutItem> _cartItems;
  bool _isLoading = false;

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _cardNumberController = TextEditingController();

  double _subtotal = 0;
  final int _shippingFee = 10000;
  final int _processingFee = 1000;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.items;
    _calculateSubtotal();
  }

  void _calculateSubtotal() {
    _subtotal = _cartItems.fold(0, (sum, item) => sum + (item.harga * item.jumlahBarang));
  }

  double get _total => _subtotal + _shippingFee + _processingFee;

  Future<Map<String, dynamic>> _processApiCheckout({
    required List<CheckoutItem> items,
    required String paymentMethod,
    required String cardNumber,
  }) async {

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/pembayaran'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'items': _cartItems.map((e) => e.toJson()).toList()}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Checkout failed: ${response.body}');
    }
  }

  Future<void> _processCheckout() async {
    print("===> Item yang dikirim ke server:");
    _cartItems.forEach((item) {
      print(item.toJson());
    });

    if (_streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipController.text.isEmpty) {
      _showErrorSnackBar('Please complete all address fields');
      return;
    }

    if (_stateController.text.isEmpty || _zipController.text.isEmpty) {
      _showErrorSnackBar('Please complete all address fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final address = Address(
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        country: 'Indonesia',
      );

      for (int i = 0; i < _cartItems.length; i++) {
        _cartItems[i] = CheckoutItem(
          namaBarang: _cartItems[i].namaBarang,
          jenis: _cartItems[i].jenis,
          deskripsi: _cartItems[i].deskripsi,
          harga: _cartItems[i].harga,
          jumlahBarang: _cartItems[i].jumlahBarang,
          alamat: address,
          image: _cartItems[i].image,
        );
      }


      final result = await _processApiCheckout(
        items: _cartItems,
        paymentMethod: 'card',
        cardNumber: _cardNumberController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true || result['status'] == 'success') {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pembayaran Berhasil'),
            content: Text('Terima kasih telah berbelanja!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        _showErrorSnackBar('Checkout failed: ${result['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Checkout error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Color(0xFFE8C4D8),
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(),
            SizedBox(height: 16),
            ..._cartItems.map(_buildCartItem).toList(),
            SizedBox(height: 16),
            _buildOrderSummary(),
            SizedBox(height: 16),
            _buildPaymentSection(),
            SizedBox(height: 24),
            _buildCheckoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCartItem(CheckoutItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE8C4D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFBD8FA6),
            child: Icon(Icons.shopping_bag, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaBarang, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(item.deskripsi, style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qty: ${item.jumlahBarang}', style: TextStyle(fontSize: 12, color: Colors.black54)),
              Text(
                'Rp. ${(item.harga * item.jumlahBarang).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSummaryRow('Total', 'Rp. ${_subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
          _buildSummaryRow('Shipping', 'Rp. ${_shippingFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
        _buildSummaryRow('Fee', 'Rp. ${_processingFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'), Divider(),
        _buildSummaryRow('Total Bayar', 'Rp. ${_total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildTextField(_streetController, 'Street Address'),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_cityController, 'City')),
              SizedBox(width: 8),
              Expanded(child: _buildTextField(_stateController, 'State')),
            ],
          ),
          SizedBox(height: 8),
          _buildTextField(_zipController, 'ZIP Code'),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment', style: TextStyle(fontSize: 16)),
              Text('Card Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          _buildTextField(_cardNumberController, 'Enter card number'),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B4B6B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color(0xFFE8C4D8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home, color: Colors.black54),
          Icon(Icons.notifications, color: Colors.black54),
          Icon(Icons.shopping_cart, color: Colors.black54),
          Icon(Icons.person, color: Colors.black54),
        ],
      ),
    );
  }
}
