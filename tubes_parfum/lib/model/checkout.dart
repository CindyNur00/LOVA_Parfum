import 'address.dart';

class CheckoutItem {
  final String namaBarang;
  final String jenis;
  final String deskripsi;
  final double harga;
  final int jumlahBarang;
  final Address alamat;
  final String? image;

  // Field di bawah hanya dibutuhkan untuk display dari server response (bukan dikirim)
  final int? idPembayaran;
  final String? tanggalPembayaran;
  final int? totalHarga;

  CheckoutItem({
    required this.namaBarang,
    required this.jenis,
    required this.deskripsi,
    required this.harga,
    required this.jumlahBarang,
    required this.alamat,
    this.image,
    this.idPembayaran,
    this.tanggalPembayaran,
    this.totalHarga,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      idPembayaran: json['payment_id'],
      namaBarang: json['product_name'],
      jenis: json['type'],
      deskripsi: json['description'],
      harga: double.parse(json['price'].toString()),
      jumlahBarang: json['quantity'],
      alamat: Address.fromJson(json['address']),
      tanggalPembayaran: json['payment_date'],
      totalHarga: json['total_price'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_name": namaBarang,
      "type": jenis,
      "description": deskripsi,
      "price": harga,
      "quantity": jumlahBarang,
      // "payment_date": tanggalPembayaran,
      // "total_price": totalHarga,
      "address": alamat.toJson(),
      if (image != null)  "image" : image,
    };
  }

}
