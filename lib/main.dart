import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/temas.dart';
import 'package:biblioteca_app/vistas/temas/home_page.dart';
import 'package:biblioteca_app/vistas/temas/login.dart';

void main() {
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
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
