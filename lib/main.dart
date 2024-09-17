import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_5/routes.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Flutter App',
      initialRoute: AppRoutes.login, // Ruta inicial de tu aplicación
      getPages: AppPages.pages, // Configura las rutas
      debugShowCheckedModeBanner: false, // Opcional: elimina el banner de depuración
    );
  }
}
