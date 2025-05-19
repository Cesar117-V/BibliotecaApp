import 'package:flutter/material.dart';

class GestionBibliotecariosScreen extends StatelessWidget {
  const GestionBibliotecariosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo
    final List<String> bibliotecarios = [
      'Juan Pérez',
      'Ana López',
      'Carlos Ramírez',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Bibliotecarios'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: bibliotecarios.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(bibliotecarios[index]),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Aquí luego puedes abrir un formulario de edición
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí luego puedes abrir un formulario para agregar bibliotecario
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar bibliotecario',
      ),
    );
  }
}
