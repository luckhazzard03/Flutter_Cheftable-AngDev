// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter_application_5/utils/constans.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  final String baseUrl;

  UserService({this.baseUrl = baseUrlLogin});

  // Obtener todos los usuarios
  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrlUsuarios'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => User.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Obtener un usuario por ID
  Future<User> fetchUserById(int id) async {
    final response = await http.get(Uri.parse('$baseUrlUsuarios$id'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Crear un nuevo usuario
  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrlUsuarios'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to create user');
    }
  }

  // Actualizar un usuario existente
  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse(
          '$baseUrlUsuarios${user.idUsuario}'), // se usa la constante de constans.dart de los usuarios
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update user');
    }
  }

  // Eliminar un usuario
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrlUsuarios$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
