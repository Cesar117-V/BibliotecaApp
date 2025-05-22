import 'dart:io' show Platform;
import 'package:biblioteca_app/vistas/temas/lista_prestamos_tab.dart';
import 'package:biblioteca_app/vistas/temas/prestamos_tab_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'package:biblioteca_app/vistas/temas/temas.dart';
import 'package:biblioteca_app/vistas/temas/home_page.dart';
import 'package:biblioteca_app/vistas/temas/login.dart';
import 'package:biblioteca_app/vistas/temas/edicion_prestamo.dart'; // 👈 Asegúrate de importar esta pantalla

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Biblioteca",
      theme: temaPrincipal,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (c) => const LoginScreen(),
        '/home': (c) => const HomePage(),
        '/prestamos': (context) => const PrestamosTabScreen(),
        '/crearPrestamo': (context) =>
            const EdicionPrestamo(), // ✅ Ruta añadida
      },
    );
  }
}
