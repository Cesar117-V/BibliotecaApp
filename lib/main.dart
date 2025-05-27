import 'package:flutter/material.dart';
import 'vistas/temas/tema.dart';
import 'vistas/temas/home_page.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Biblioteca",
      theme: temaPrincipal,
      home: const HomePage(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
