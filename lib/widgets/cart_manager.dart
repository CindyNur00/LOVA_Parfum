import 'package:tubes_parfum/model/product_model.dart';
import 'package:tubes_parfum/model/checkout.dart';
import 'package:flutter/foundation.dart'; // Untuk @required

class CartItem {
  final ProductDetail product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Metode untuk mengonversi CartItem ke CheckoutItem
  CheckoutItem toCheckoutItem() {
    return CheckoutItem(
      namaBarang: product.name,
      jenis: product.category ?? 'Unknown', // Asumsi ada fragranceType
      deskripsi: product.description,
      harga: product.price.toDouble(), // Pastikan double
      jumlahBarang: quantity,
      alamat: null, // Akan diisi di CheckoutPage
      imageUrl: product.imageUrl,
    );
  }
}

class CartManager extends ChangeNotifier {
  // Singleton instance
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // Menambahkan produk ke keranjang atau memperbarui kuantitas jika sudah ada
  void addOrUpdateProduct(ProductDetail product, int quantity) {
    int existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      // Jika produk sudah ada, tambahkan kuantitasnya
      _items[existingIndex].quantity += quantity;
    } else {
      // Jika produk belum ada, tambahkan sebagai item baru
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners(); // Beri tahu listener (misal: ParfumCart) bahwa data telah berubah
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  double get totalCartPrice {
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Metode untuk membersihkan keranjang setelah checkout
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}