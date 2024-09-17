// lib/controllers/user_controller.dart
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class UserController with ChangeNotifier {
  final UserService userService;
  List<User> users = [];
  bool isLoading = false;
  String? errorMessage;

  UserController(this.userService);

  get selectedUser => null;

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

  Future<void> addUser(User user) async {
    try {
      await userService.createUser(user);
      users.add(user);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await userService.updateUser(user);
      final index = users.indexWhere((u) => u.idUsuario == user.idUsuario);
      if (index != -1) {
        users[index] = user;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> deleteUser(User user) async {
    try {
      await userService.deleteUser(user.idUsuario!);
      users.remove(user);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
