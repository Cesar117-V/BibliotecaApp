import 'package:biblioteca_app/vistas/temas/lista_autores.dart';
import 'package:biblioteca_app/vistas/temas/lista_categorias.dart';
import 'package:biblioteca_app/vistas/temas/lista_libros.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Biblioteca del Itch"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _crearBoton(context, "Libros", Icons.pages, const ListaLibros()),
          _crearBoton(context, "Categorías", Icons.category, const ListaCategorias()),
          _crearBoton(context, "Autores", Icons.person, const ListaAutores()),
        ],
      ),
    );
  }

  Widget _crearBoton(BuildContext context, String titulo, IconData icono, Widget pagina) {
    return MaterialButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => pagina)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 50),
          SizedBox(height: 10),
          Text(titulo, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

