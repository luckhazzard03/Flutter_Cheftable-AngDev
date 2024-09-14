// lib/controllers/user_controller.dart
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class UserController with ChangeNotifier {
  final UserService userService;
  List<User> users = [];
  bool isLoading = false;
  String? errorMessage;

  UserController(this.userService);

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();
    try {
      users = await userService.fetchUsers();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
