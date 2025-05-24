import 'package:flutter/material.dart';
import 'lista_prestamos.dart';
import 'lista_prestamos_historial.dart';
import 'edicion_prestamo.dart'; // Asegúrate de importar esta pantalla

class ListaPrestamosTab extends StatefulWidget {
  const ListaPrestamosTab({super.key});

  @override
  State<ListaPrestamosTab> createState() => _ListaPrestamosTabState();
}

class _ListaPrestamosTabState extends State<ListaPrestamosTab> {
  final GlobalKey<ListaPrestamosState> prestamosKey =
      GlobalKey<ListaPrestamosState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Préstamos"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Activos",
                icon: Icon(Icons.assignment_turned_in),
              ),
              Tab(text: "Historial", icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(8),
          child: TabBarView(
            children: [
              ListaPrestamos(key: prestamosKey),
              const ListaPrestamosHistorial(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fabPrestamosTab',
          backgroundColor: Colors.purple.shade100,
          child: const Icon(Icons.add, color: Colors.deepPurple),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionPrestamo()),
            );
            if (result == true) {
              prestamosKey.currentState?.cargarDatos(); // ✅ actualiza lista
            }
          },
        ),
      ),
    );
  }
}
