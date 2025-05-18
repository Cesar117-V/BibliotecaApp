import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// IMPORTA ESTO para desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// (Sólo si quieres correr en web también)
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:biblioteca_app/vistas/temas/temas.dart';
import 'package:biblioteca_app/vistas/temas/home_page.dart';
import 'package:biblioteca_app/vistas/temas/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // si vas a soportar web, descomenta:
    // databaseFactory = databaseFactoryFfiWeb;
  } else {
    // ¡Esto es crítico!
    // Inicializa la implementación de sqflite para desktop
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
      },
    );
  }
}
