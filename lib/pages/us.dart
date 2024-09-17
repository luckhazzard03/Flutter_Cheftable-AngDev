import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart'; // Importamos Dio
import '../models/user.dart';
import 'login_page.dart'; // Importa la página de inicio de sesión
import 'order_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final Dio _dio = Dio(); // Instancia de Dio para peticiones HTTP
  final String apiUrl = 'https://example.com/api/users'; // URL base de la API
  final List<User> _users = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  User? _editingUser;
  bool _isFormVisible = false;

  final Map<String, int> _roleToIdMap = {
    'Admin': 1,
    'Chef': 2,
    'Mesero': 3,
  };

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Obtener los usuarios al iniciar
  }

  // Obtener usuarios desde la API
  Future<void> _fetchUsers() async {
    try {
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        setState(() {
          _users.clear();
          _users.addAll(List<User>.from(
              response.data.map((user) => User.fromJson(user))));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener usuarios: $e')));
    }
  }

  // Crear o actualizar usuarios
  Future<void> _addUser() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final password = _hashPassword(_passwordController.text);
      final role = _selectedRole!;

      if (_editingUser != null) {
        // Editar usuario existente
        await _updateUser(_editingUser!.idUsuario!, name, email, phone, password, _roleToIdMap[role]!);
      } else {
        // Crear un nuevo usuario
        await _createUser(name, email, phone, password, _roleToIdMap[role]!);
      }

      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos correctamente.')),
      );
    }
  }

  // Crear usuario en la base de datos mediante la API
  Future<void> _createUser(String name, String email, String phone, String password, int roleId) async {
    try {
      final response = await _dio.post(apiUrl, data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': roleId,
      });
      if (response.statusCode == 201) {
        _fetchUsers(); // Recargar usuarios
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Usuario creado.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear usuario: $e')));
    }
  }

  // Actualizar usuario en la base de datos mediante la API
  Future<void> _updateUser(int id, String name, String email, String phone, String password, int roleId) async {
    try {
      final response = await _dio.put('$apiUrl/$id', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': roleId,
      });
      if (response.statusCode == 200) {
        _fetchUsers(); // Recargar usuarios
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Usuario actualizado.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar usuario: $e')));
    }
  }

  // Eliminar usuario de la base de datos mediante la API
  Future<void> _deleteUser(int id) async {
    try {
      final response = await _dio.delete('$apiUrl/$id');
      if (response.statusCode == 200) {
        _fetchUsers(); // Recargar usuarios
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Usuario eliminado.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar usuario: $e')));
    }
  }

  void _editUser(User user) {
    _nameController.text = user.nombre!;
    _emailController.text = user.email!;
    _phoneController.text = user.telefono!;
    _selectedRole = _roleToIdMap.entries
        .firstWhere((entry) => entry.value == user.idRolesFk,
            orElse: () => MapEntry('', 0))
        .key;
    setState(() {
      _editingUser = user;
      _isFormVisible = true;
    });
  }

  void _deleteUserConfirm(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de eliminar a ${user.nombre}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                _deleteUser(user.idUsuario!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 9);
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    setState(() {
      _selectedRole = null;
      _editingUser = null;
      _isFormVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove('is_logged_in');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFormVisible)
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nombre es requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Correo electrónico es requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Teléfono es requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Contraseña es requerida' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('Selecciona un rol'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    items: _roleToIdMap.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null ? 'Rol es requerido' : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(214, 99, 219, 0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                    ),
                    child: Text(_editingUser != null
                        ? 'Actualizar Usuario'
                        : 'Añadir Usuario'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  child: ListTile(
                    title: Text(user.nombre!),
                    subtitle: Text(
                        'Correo: ${user.email}\nRol: ${user.idRolesFk}\nCel: ${user.telefono}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.green,
                          onPressed: () => _editUser(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.green,
                          onPressed: () => _deleteUserConfirm(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
