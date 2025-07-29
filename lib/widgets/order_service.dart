import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tubes_parfum/model/history.dart';

class OrderService {
  static const String baseUrl = 'http://localhost:8080/api/order';

  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('Response body: $body');
        final List<dynamic> orderList = body['data'] ?? [];
        return orderList.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }


  static Future<Order> getOrderById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data'] == null || body['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid data format from API');
        }

        return Order.fromJson(body['data']); // ✅ satu objek
      } else {
        throw Exception('Failed to load order (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

}
