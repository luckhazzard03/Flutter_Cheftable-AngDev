// // lib/controllers/user_controller.dart
// import 'package:flutter/material.dart';
// import '../services/user_service.dart';
// import '../models/user.dart';

// class UserController with ChangeNotifier {
//   final UserService userService;
//   List<User> users = [];
//   bool isLoading = false;
//   String? errorMessage;

//   UserController(this.userService);

//   Future<void> loadUsers() async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       users = await userService.fetchUsers();
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> addUser(User user) async {
//     try {
//       final newUser = await userService.createUser(user);
//       users.add(newUser);
//       notifyListeners();
//     } catch (e) {
//       errorMessage = e.toString();
//     }
//   }

//   Future<void> updateUser(User user) async {
//     try {
//       final updatedUser = await userService.updateUser(user);
//       final index = users.indexWhere((u) => u.idUsuario == user.idUsuario);
//       if (index != -1) {
//         users[index] = updatedUser;
//         notifyListeners();
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     }
//   }

//   Future<void> deleteUser(int id) async {
//     try {
//       await userService.deleteUser(id);
//       users.removeWhere((u) => u.idUsuario == id);
//       notifyListeners();
//     } catch (e) {
//       errorMessage = e.toString();
//     }
//   }
// }
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
    try {
      final fetchedUsers = await userService.fetchUsers();
      users = fetchedUsers;
    } catch (e) {
      // Manejar errores
      print('Error loading users: $e');
    }
  }

  Future<List<User>> getUsers() async {
    // Asegúrate de cargar los usuarios antes de devolverlos
    if (users.isEmpty) {
      await loadUsers();
    }
    return users;
  }

  Future<void> addUser(User newUser) async {
    try {
      await userService
          .createUser(newUser); // Llamada al servicio para agregar usuario
    } catch (e) {
      throw Exception('Error al agregar usuario: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await userService.updateUser(
          updatedUser); // Llamada al servicio para actualizar usuario
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await userService.deleteUser(userId); // Llama al servicio para eliminar
      // Actualiza el estado después de la eliminación si es necesario
      users.removeWhere((user) => user.idUsuario == userId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
