class Order {
  final String id;
  final String date;
  final String status;

  Order({
    required this.id,
    required this.date,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id_pembayaran'].toString(),
      date: json['tanggal_pembayaran'] ?? '',
      status: json['status'] ?? 'Unknown',
    );
  }
}
