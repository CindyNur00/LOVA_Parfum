class NotificationModel {
  final int notificationId;
  final String productName;
  final String type;
  final String status;
  final String statusDescription;
  final DateTime purchaseDate;
  final bool read;

  NotificationModel({
    required this.notificationId,
    required this.productName,
    required this.type,
    required this.status,
    required this.statusDescription,
    required this.purchaseDate,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notification_id'],
      productName: json['product_name'],
      type: json['type'],
      status: json['status'],
      statusDescription: json['status_description'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'product_name': productName,
      'type': type,
      'status': status,
      'status_description': statusDescription,
      'purchase_date': purchaseDate.toIso8601String(),
      'read': read,
    };
  }
}
