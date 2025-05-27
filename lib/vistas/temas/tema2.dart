import 'package:flutter/material.dart';

final ThemeData temaPrincipal = ThemeData(
  primaryColor: const Color.fromARGB(255, 255, 187, 15),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: const Color.fromARGB(255, 203, 149, 72),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
  ),
);
