import 'package:flutter/material.dart';
import 'package:tubes_parfum/model/notifikasi.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap; // You can keep this if you still need it for other actions

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16.0),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          notification.message, // Display a summary of the message
          maxLines: 1, // Show only one line initially
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(), // Optional: Add a divider for better separation
                Text(
                  'Full Message: ${notification.message}', // Full message
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Date: ${notification.purchaseDate}', // Assuming 'date' is a property in NotificationModel
                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                // Add more details here if your NotificationModel has them
                // For example:
                // Text('Type: ${notification.type}', style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
              ],
            ),
          ),
        ],
        onExpansionChanged: (isExpanded) {
          // You can add logic here if you want to perform an action when the tile expands/collapses
          // e.g., mark as read, log an event
          print('Notification ${notification.title} isExpanded: $isExpanded');
        },
      ),
    );
  }
}