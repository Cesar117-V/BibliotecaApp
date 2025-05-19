import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'package:biblioteca_app/vistas/temas/temas.dart';
import 'package:biblioteca_app/vistas/temas/home_page.dart';
import 'package:biblioteca_app/vistas/temas/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Escritorio
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // Android/iOS: no es necesario hacer nada, usa sqflite por defecto
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
