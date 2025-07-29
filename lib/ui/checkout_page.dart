import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tubes_parfum/model/checkout.dart';
import 'package:tubes_parfum/model/notifikasi.dart';
import 'package:tubes_parfum/model/address.dart';
import 'package:tubes_parfum/ui/home_screen.dart';
import 'package:tubes_parfum/ui/History_page.dart'; // <--- Ini yang penting!
import 'package:tubes_parfum/ui/notifikasi_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CheckoutItem> items;

  const CheckoutPage({super.key, required this.items});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const String baseUrlPembayaran = 'http://localhost:8080/api/pembayaran';
  static const String baseUrlNotifikasi = 'http://localhost:8080/api/notifikasi';

  late List<CheckoutItem> _cartItems;
  bool _isLoading = false;

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  double _subtotal = 0;
  final int _shippingFee = 10000;
  final int _processingFee = 1000;

  String _selectedPaymentMethod = 'QRIS';
  bool _qrisGenerated = false;

  @override
  void initState() {
    super.initState();
    _cartItems = widget.items;
    _calculateSubtotal();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _calculateSubtotal() {
    _subtotal = _cartItems.fold(0, (sum, item) => sum + (item.harga * item.jumlahBarang));
  }

  double get _total => _subtotal + _shippingFee + _processingFee;

  Future<Map<String, dynamic>> _processApiCheckout({
    required List<CheckoutItem> items,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrlPembayaran),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': items.map((e) => e.toJson()).toList(),
        'payment_method': paymentMethod,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      String errorMessage = 'Checkout gagal. Kode status: ${response.statusCode}';
      try {
        final errorBody = json.decode(response.body);
        if (errorBody['message'] != null) {
          errorMessage += '\nPesan: ${errorBody['message']}';
        }
      } catch (e) {
        errorMessage += '\nRespons tidak dapat diurai.';
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> _sendNotification(
      String title,
      String message,
      String productName,
      String type,
      String status,
      String statusDescription,
      String purchaseDate) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlNotifikasi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'message': message,
          'product_name': productName,
          'type': type,
          'status': status,
          'status_description': statusDescription,
          'purchase_date': purchaseDate,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Notification sent successfully!');
      } else {
        print('Failed to send notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> _processCheckout() async {
    String orderSummary = _cartItems.map((e) => '${e.namaBarang} (${e.jumlahBarang}x)').join(', ');
    String firstProductName = _cartItems.isNotEmpty ? _cartItems[0].namaBarang : 'Produk';
    String statusDescriptionForNotif = 'Pesanan Anda telah berhasil dibayar dan sedang diproses.';
    String currentPurchaseDate = DateTime.now().toIso8601String().substring(0, 10);

    if (_streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _zipController.text.isEmpty) {
      _showErrorSnackBar('Harap lengkapi semua bidang alamat.');
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

      List<CheckoutItem> itemsWithAddress = [];
      for (var item in _cartItems) {
        itemsWithAddress.add(
          CheckoutItem(
            namaBarang: item.namaBarang,
            jenis: item.jenis,
            deskripsi: item.deskripsi,
            harga: item.harga,
            jumlahBarang: item.jumlahBarang,
            alamat: address,
            imageUrl: item.imageUrl,
          ),
        );
      }

      final result = await _processApiCheckout(
        items: itemsWithAddress,
        paymentMethod: _selectedPaymentMethod,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true || result['status'] == 'success' || result['status'] == 'pending') {
        setState(() {
          _qrisGenerated = true;
        });

        _showSuccessQrisDialog(
          orderSummary: orderSummary,
          total: _total.toInt(),
          firstProductName: firstProductName,
          productType: _cartItems.isNotEmpty ? _cartItems[0].jenis : '-',
          purchaseDate: currentPurchaseDate,
        );
      } else {
        _showErrorSnackBar('Checkout gagal: ${result['message'] ?? 'Kesalahan tidak diketahui'}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Terjadi kesalahan saat checkout: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color(0xFF781D26)),
    );
  }

  void _showSuccessQrisDialog({
    required String orderSummary,
    required int total,
    required String firstProductName,
    required String productType,
    required String purchaseDate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran Menunggu Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Silakan scan QRIS di bawah untuk menyelesaikan pembayaran:'),
            SizedBox(height: 16),
            Image.asset(
              'src/assets/img/Lova.png', // Sesuaikan path ini dengan gambar QRIS Anda
              width: 200, // Ukuran disesuaikan
              height: 123, // Ukuran disesuaikan (menjaga rasio)
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('QRIS berhasil diunduh! (Simulasi)')),
                );
              },
              icon: Icon(Icons.download),
              label: Text('Unduh QRIS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4B6B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Kirim notifikasi konfirmasi pembayaran setelah pengguna menekan 'Oke'
              await _sendNotification(
                'Pembayaran Dilakukan!',
                'Pesanan Anda ($orderSummary) senilai Rp. $total sedang menunggu verifikasi pembayaran QRIS.',
                firstProductName,
                productType,
                'pending',
                'Pembayaran QRIS sedang diproses. Mohon tunggu konfirmasi.',
                purchaseDate,
              );

              Navigator.of(context).pop(); // Tutup dialog QRIS

              // --- NAVIGASI KE ORDERHISTORYSCREEN DI SINI ---
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()), // <--- Ini sudah menavigasi ke sana
                    (Route<dynamic> route) => false, // Hapus semua route sebelumnya
              );
            },
            child: Text('Oke, Saya Sudah Membayar'),
          ),
        ],
      ),
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
            _buildPaymentMethodSection(),
            SizedBox(height: 24),
            _buildCheckoutButton(),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(), // Jika Anda tidak ingin BottomNavBar di halaman Checkout
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
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFCA99AB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, color: Colors.white);
                },
              ),
            ),
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
          _buildSummaryRow('Fee', 'Rp. ${_processingFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
          Divider(),
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
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        children: [
          Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Larger, bolder title
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

  // --- Widget baru untuk bagian metode pembayaran (QRIS) ---
  Widget _buildPaymentMethodSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Color(0xFFE8E8E8), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        children: [
          Text('Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Larger, bolder title
          SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text('QRIS'),
            value: 'QRIS',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: Color(0xFF8B4B6B), // Warna aktif
          ),
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
          'Bayar Sekarang', // Ganti teks tombol
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Bottom Nav Bar standar Anda (jika ini memang harus ada di CheckoutPage)
  // Perhatikan bahwa halaman checkout biasanya tidak memiliki Bottom Nav Bar
  // karena itu adalah alur transaksi yang terfokus. Jika tidak diperlukan, hapus.
  Widget _buildBottomNavBar() {
    return Container(
      height: 80, // Tinggi BottomNavigationBar
      decoration: BoxDecoration(
        color: Color(0xFFE8C4D8), // Warna latar belakang BottomNavigationBar
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)), // Radius hanya di bagian atas
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.black54),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black54),
            onPressed: () {
              // Navigasi ke halaman notifikasi (jika ada)
              // Pastikan Anda mengimpor NotificationPage jika digunakan
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => NotificationPage()),
              //   (Route<dynamic> route) => false,
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black54),
            onPressed: () {
              // Navigasi ke halaman keranjang (jika ada)
              // Pastikan Anda mengimpor ParfumCart jika digunakan
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => ParfumCart()),
              //   (Route<dynamic> route) => false,
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.black54),
            onPressed: () {
              // Navigasi ke halaman akun (jika ada)
              // Pastikan Anda mengimpor MyAccountPage jika digunakan
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyAccountPage()),
              //   (Route<dynamic> route) => false,
              // );
            },
          ),
        ],
      ),
    );
  }
}