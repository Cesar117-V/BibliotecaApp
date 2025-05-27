import 'dart:io';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class LibrosPorAutor extends StatefulWidget {
  final Autor autor;

  const LibrosPorAutor({Key? key, required this.autor}) : super(key: key);

  @override
  State<LibrosPorAutor> createState() => _LibrosPorAutorState();
}

class _LibrosPorAutorState extends State<LibrosPorAutor> {
  List<Libro> _libros = [];

  @override
  void initState() {
    super.initState();
    cargarLibrosDelAutor();
  }

  Future<void> cargarLibrosDelAutor() async {
    if (widget.autor.id == null) return;

    final libros = await Dao.obtenerLibrosPorAutor(widget.autor.id!);

    // Agrupar por título para evitar duplicados visuales
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
      appBar: AppBar(title: Text('Libros de ${widget.autor.nombre}')),
      body: _libros.isEmpty
          ? const Center(child: Text("Este autor no tiene libros."))
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
