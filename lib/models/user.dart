// lib/models/user.dart

// Necesario para formatear fechas si es necesario

class User {
  int? idUsuario;
  String? nombre;
  String? password;
  String? email;
  String? telefono;
  int? idRolesFk;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.idUsuario,
    this.nombre,
    required this.password,
    required this.email,
    this.telefono,
    this.idRolesFk,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create an instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUsuario: json['idUsuario'],
      nombre: json['Nombre'],
      password: json['Password'],
      email: json['Email'],
      telefono: json['Telefono'],
      idRolesFk: json['idRoles_fk'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,
      'Nombre': nombre,
      'Password': password,
      'Email': email,
      'Telefono': telefono,
      'idRoles_fk': idRolesFk,
      'created_at': createdAt?.toIso8601String() ?? '',
      'updated_at': updatedAt?.toIso8601String() ?? '',
    };
  }
}
// class User {
//   String? nombre;
//   String? email;
//   String? password;

//   User({required this.email, required this.password});
// }
