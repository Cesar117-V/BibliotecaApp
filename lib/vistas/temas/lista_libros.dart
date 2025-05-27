import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';

class ListaLibros extends StatefulWidget {
  const ListaLibros({Key? key}) : super(key: key);

  @override
  _ListaLibrosState createState() => _ListaLibrosState();
}

class _ListaLibrosState extends State<ListaLibros> {
  List<Libro> _libros = [];

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  Future<void> _cargarLibros() async {
    _libros = await Dao.listaLibros();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Libros")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navega a la pantalla de creación de libro
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionLibro()),
          );
          _cargarLibros();
        },
      ),
      body:
          _libros.isEmpty
              ? const Center(child: Text("No hay libros registrados"))
              : ListView.builder(
                itemCount: _libros.length,
                itemBuilder: (context, index) {
                  final libro = _libros[index];
                  return ListTile(
                    title: Text(libro.titulo ?? ""),
                    subtitle: Text(libro.nombre ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await Dao.deleteLibro(libro.id!);
                        _cargarLibros();
                      },
                    ),
                    onTap: () async {
                      // Navega a la pantalla de edición, pasando el libro
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EdicionLibro(libro: libro),
                        ),
                      );
                      _cargarLibros();
                    },
                  );
                },
              ),
    );
  }
}
