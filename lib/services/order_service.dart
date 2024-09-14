// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter_application_5/utils/constans.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  final String baseUrl;

  OrderService({this.baseUrl = baseUrlComandas});

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrlComandas'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Order.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      // En caso de error, puede lanzar una excepción o devolver una lista vacía
      // dependiendo de cómo se maneja los errores en la aplicación.
      throw Exception('Failed to load orders: $e');
    }
  }
}

Future<Order> fetchOrderById(int id) async {
  final response = await http.get(Uri.parse('$baseUrlComandas$id'));

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Order.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load order');
  }
}

Future<Order> createOrder(Order order) async {
  final response = await http.post(
    Uri.parse('$baseUrlComandas'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: json.encode(order.toJson()),
  );

  if (response.statusCode == 201) {
    final jsonResponse = json.decode(response.body);
    return Order.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to create order');
  }
}

Future<Order> updateOrder(Order order) async {
  final response = await http.put(
    Uri.parse('$baseUrlComandas${order.id}'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: json.encode(order.toJson()),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Order.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to update order');
  }
}

Future<void> deleteOrder(int id) async {
  final response = await http.delete(Uri.parse('$baseUrlComandas$id'));

  if (response.statusCode != 204) {
    throw Exception('Failed to delete order');
  }
}
