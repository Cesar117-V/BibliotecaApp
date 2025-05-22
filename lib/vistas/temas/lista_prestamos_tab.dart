import 'package:flutter/material.dart';
import 'lista_prestamos.dart';
import 'lista_prestamos_historial.dart';

class ListaPrestamosTab extends StatelessWidget {
  const ListaPrestamosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Azul igual que administrador
          title: const Text("Préstamos"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Activos",
                icon: Icon(Icons.assignment_turned_in), // Ícono original sólido
              ),
              Tab(text: "Historial", icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100], // Fondo gris claro
          padding: const EdgeInsets.all(8),
          child: const TabBarView(
            children: [
              ListaPrestamos(),
              ListaPrestamosHistorial(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fabPrestamosTab',
          backgroundColor: Colors.purple.shade100, // Morado claro
          child: const Icon(Icons.add, color: Colors.deepPurple),
          onPressed: () {
            Navigator.pushNamed(context, '/crearPrestamo');
          },
        ),
      ),
    );
  }
}
