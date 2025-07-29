class NotificationModel {
  final int notificationId;
  final String title;
  final String message;
  final String productName;
  final String type;
  final String status;
  final String statusDescription;
  final DateTime purchaseDate;
  // final DateTime? createdAt;
  final bool read;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.productName,
    required this.type,
    required this.status,
    required this.statusDescription,
    required this.purchaseDate,
    // this.createdAt,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      title: json['title'],
      message: json['message'],
      productName: json['product_name'],
      type: json['type'],
      status: json['status'],
      statusDescription: json['status_description'],
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      // createdAt: json['created_at'] != null // <-- Pastikan parsing untuk createdAt
      //     ? DateTime.tryParse(json['created_at'] as String)
      //     : null,
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'title': title,
      'message': message,
      'product_name': productName,
      'type': type,
      'status': status,
      'status_description': statusDescription,
      'purchase_date': purchaseDate.toIso8601String(),
      // 'created_at': createdAt,
      'read': read,
    };
  }
}
