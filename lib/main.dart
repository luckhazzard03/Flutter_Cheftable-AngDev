import 'package:flutter/material.dart';
import 'package:flutter_application_5/routes.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';

import 'package:flutter_application_5/routes.dart'; // Asegúrate de que la ruta sea correcta


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Cheftable',
      initialRoute: isLoggedIn ? AppRoutes.userManagement : AppRoutes.login,
      getPages: AppPages.pages,
      title: 'My Flutter App',
      initialRoute: AppRoutes.login, // Ruta inicial de tu aplicación
      getPages: AppPages.pages, // Configura las rutas
      debugShowCheckedModeBanner: false, // Opcional: elimina el banner de depuración main
    );
  }
}
