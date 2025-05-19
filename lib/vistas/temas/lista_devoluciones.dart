import 'package:flutter/material.dart';

class ListaDevoluciones extends StatelessWidget {
  const ListaDevoluciones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista simulada de devoluciones
    final List<String> devoluciones = [
      'Devolución - Juan Pérez',
      'Devolución - Ana López',
      'Devolución - Carlos Ramírez',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Devoluciones'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: devoluciones.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.assignment_turned_in),
            title: Text(devoluciones[index]),
            onTap: () {
              // Más adelante puedes agregar navegación a detalles
            },
          );
        },
      ),
    );
  }
}
