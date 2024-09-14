// lib/controllers/order_controller.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class OrderController with ChangeNotifier {
  final OrderService orderService;
  List<Order> orders = [];
  bool isLoading = false;
  String? errorMessage;

  OrderController(this.orderService);

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      orders = await orderService.fetchOrders();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
