import 'package:biblioteca_app/vistas/temas/lista_prestamos_tab.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/lista_prestamos.dart';
import 'package:biblioteca_app/vistas/temas/lista_devoluciones.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart'; // ✅

class HomeBibliotecario extends StatelessWidget {
  const HomeBibliotecario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biblioteca - Bibliotecario",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              SesionUsuario.nombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Cerrar sesión?'),
                  content:
                      const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _crearBoton(context, "Préstamos", Icons.assignment_return,
              const ListaPrestamosTab()),
          _crearBoton(context, "Devoluciones", Icons.assignment_turned_in,
              const ListaDevoluciones()),
        ],
      ),
    );
  }

  Widget _crearBoton(
      BuildContext context, String titulo, IconData icono, Widget pagina) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 50),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
