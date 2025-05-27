import 'dart:io';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class LibrosPorCategoria extends StatefulWidget {
  final Categoria categoria;

  const LibrosPorCategoria({Key? key, required this.categoria})
      : super(key: key);

  @override
  State<LibrosPorCategoria> createState() => _LibrosPorCategoriaState();
}

class _LibrosPorCategoriaState extends State<LibrosPorCategoria> {
  List<Libro> _libros = [];

  @override
  void initState() {
    super.initState();
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    final libros =
        await Dao.listaLibrosPorCategoria(idCategoria: widget.categoria.id);

    // Agrupar por título para evitar duplicados
    final Map<String, Libro> unicosPorTitulo = {};

    for (var libro in libros) {
      final titulo = (libro.titulo ?? '').trim();
      if (titulo.isNotEmpty && !unicosPorTitulo.containsKey(titulo)) {
        unicosPorTitulo[titulo] = libro;
      }
    }

    setState(() {
      _libros = unicosPorTitulo.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Libros de "${widget.categoria.nombre}"')),
      body: _libros.isEmpty
          ? const Center(child: Text("No hay libros en esta categoría."))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _libros.length,
              itemBuilder: (context, index) {
                final libro = _libros[index];
                return Card(
                  child: ListTile(
                    title: Text(libro.titulo ?? "Sin título"),
                    subtitle: Text("Páginas: ${libro.numeroPaginas ?? 0}"),
                    leading: libro.imagen != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(libro.imagen!)))
                        : const CircleAvatar(child: Icon(Icons.book)),
                  ),
                );
              },
            ),
    );
  }
}
