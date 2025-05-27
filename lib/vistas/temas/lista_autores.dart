import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';
import 'package:flutter/material.dart';

class ListaAutores extends StatefulWidget {
  const ListaAutores({Key? key}) : super(key: key);

  @override
  _ListaAutoresState createState() => _ListaAutoresState();
}

class _ListaAutoresState extends State<ListaAutores> {
  List<Autor> _autores = [];

  @override
  void initState() {
    super.initState();
    _cargarAutores();
  }

  Future<void> _cargarAutores() async {
    _autores = await Dao.listaAutores();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Autores")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navega a la pantalla de creación
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionAutor()),
          );
          _cargarAutores();
        },
      ),
      body: ListView.builder(
        itemCount: _autores.length,
        itemBuilder: (context, index) {
          final autor = _autores[index];
          return ListTile(
            title: Text(autor.nombre ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await Dao.deleteAutor(autor.id!);
                _cargarAutores();
              },
            ),
            onTap: () async {
              // Navega a la pantalla de edición pasándole el autor
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EdicionAutor(autor: autor)),
              );
              _cargarAutores();
            },
          );
        },
      ),
    );
  }
}
