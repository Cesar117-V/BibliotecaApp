import 'dart:io';

import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';
import 'package:flutter/material.dart';

// ... imports ...

Future<bool> confirmarEliminacion(BuildContext context, String mensaje) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Confirmar eliminación"),
              content: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Eliminar"),
                ),
              ],
            ),
      ) ??
      false;
}

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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionLibro()),
          );
          _cargarLibros();
        },
      ),
      body: ListView.builder(
        itemCount: _libros.length,
        itemBuilder: (context, index) {
          final libro = _libros[index];
          return ListTile(
            leading:
                libro.imagen != null
                    ? CircleAvatar(
                      backgroundImage: FileImage(File(libro.imagen!)),
                    )
                    : const CircleAvatar(child: Icon(Icons.book)),
            title: Text(libro.titulo ?? ""),
            subtitle: Text("Páginas: ${libro.numeroPaginas ?? 0}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmar = await confirmarEliminacion(
                  context,
                  "¿Deseas eliminar este libro?",
                );
                if (confirmar) {
                  await Dao.deleteLibro(libro.id!);
                  _cargarLibros();
                }
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EdicionLibro(libro: libro)),
              );
              _cargarLibros();
            },
          );
        },
      ),
    );
  }
}
