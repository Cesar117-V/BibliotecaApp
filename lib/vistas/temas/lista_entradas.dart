import 'package:flutter/material.dart';

class ListaEntradas extends StatelessWidget {
  const ListaEntradas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Entrada")),
      body: const Center(
        child: Text(
          "Aquí se registrarán las entradas de personas.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
