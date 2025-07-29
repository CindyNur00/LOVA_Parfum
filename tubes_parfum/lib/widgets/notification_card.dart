import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan untuk format tanggal
import 'package:tubes_parfum/model/notifikasi.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Tanggal tidak tersedia';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return 'Format tanggal salah';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                notification.productName ?? "Tanpa nama produk",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),


              Text(
                notification.statusDescription ?? "Tidak ada deskripsi",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 10),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(notification.purchaseDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),


                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: notification.read ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notification.read ? "Sudah dibaca" : "Belum dibaca",
                      style: TextStyle(
                        color: notification.read ? Colors.green.shade800 : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
