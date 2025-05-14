import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/listas_libros.dart';
import 'package:biblioteca_app/vistas/temas/lista_categorias.dart';
import 'package:biblioteca_app/vistas/temas/lista_autores.dart';
import 'package:biblioteca_app/vistas/temas/lista_prestamos.dart';
import 'package:biblioteca_app/vistas/temas/lista_entradas.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca del Itch"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('¿Cerrar sesión?'),
                      content: const Text(
                        '¿Estás seguro de que quieres cerrar sesión?',
                      ),
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
          _crearBoton(context, "Libros", Icons.book, const ListaLibros()),
          _crearBoton(
            context,
            "Categorías",
            Icons.category,
            const ListaCategorias(),
          ),
          _crearBoton(context, "Autores", Icons.person, const ListaAutores()),
          _crearBoton(
            context,
            "Préstamos",
            Icons.assignment_return,
            const ListaPrestamos(),
          ),
          _crearBoton(
            context,
            "Control de Entrada",
            Icons.login,
            const ListaEntradas(),
          ),
        ],
      ),
    );
  }

  Widget _crearBoton(
    BuildContext context,
    String titulo,
    IconData icono,
    Widget pagina,
  ) {
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
