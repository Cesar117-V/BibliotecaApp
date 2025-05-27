import 'dart:io';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';

Future<bool> confirmarEliminacion(BuildContext context, String mensaje) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
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
  State<ListaLibros> createState() => ListaLibrosState();
}

class ListaLibrosState extends State<ListaLibros> {
  Map<String, List<Libro>> _librosAgrupados = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final libros = await Dao.listaLibros();
    final agrupados = <String, List<Libro>>{};

    for (var libro in libros) {
      final titulo = libro.titulo?.trim().isNotEmpty == true
          ? libro.titulo!
          : 'Sin título';
      agrupados.putIfAbsent(titulo, () => []).add(libro);
    }

    if (!mounted) return;
    setState(() {
      _librosAgrupados = agrupados;
    });
  }

  Future<void> _editarLibro([Libro? libro]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EdicionLibro(libro: libro)),
    );
    if (result == true && mounted) {
      await cargarDatos();
    }
  }

  void _mostrarEjemplaresModal(List<Libro> libros) {
    final disponibles = libros.where((l) => l.disponible ?? true).toList();

    if (disponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay ejemplares disponibles")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: disponibles.length,
        itemBuilder: (context, index) {
          final libro = disponibles[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: libro.imagen != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(libro.imagen!)))
                  : const CircleAvatar(child: Icon(Icons.book)),
              title: Text("Páginas: ${libro.numeroPaginas ?? 0}"),
              subtitle: libro.numAdquisicion?.isNotEmpty == true
                  ? Text("Adquisición: ${libro.numAdquisicion!}")
                  : null,
              trailing: IconButton(
                tooltip: 'Eliminar ejemplar',
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirmar = await confirmarEliminacion(
                    context,
                    "¿Deseas eliminar este ejemplar?",
                  );
                  if (confirmar) {
                    await Dao.deleteLibro(libro.id!);
                    if (mounted) Navigator.pop(context);
                    await cargarDatos();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: _librosAgrupados.entries.map((entry) {
        final titulo = entry.key;
        final libros = entry.value;

        return Card(
          child: ListTile(
            title: Text(
              "$titulo (${libros.where((l) => l.disponible ?? true).length} disponibles)",
            ),
            subtitle: Text("Páginas: ${libros.first.numeroPaginas ?? 0}"),
            leading: libros.first.imagen != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(libros.first.imagen!)))
                : const CircleAvatar(child: Icon(Icons.book)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 👁️ Ver descripción
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  tooltip: 'Ver descripción',
                  onPressed: () {
                    final libro = libros.first;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(libro.titulo ?? 'Sin título'),
                        content: SingleChildScrollView(
                          child: Text(
                            libro.descripcion?.isNotEmpty == true
                                ? libro.descripcion!
                                : 'Este libro no tiene descripción.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // ☰ Opciones: editar o eliminar todos
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Opciones',
                  onSelected: (value) async {
                    final libroBase = libros.first;

                    if (value == 'editar') {
                      await _editarLibro(libroBase);
                    }

                    if (value == 'eliminar') {
                      final confirmar = await confirmarEliminacion(
                        context,
                        "¿Deseas eliminar todos los ejemplares de \"$titulo\"?",
                      );

                      if (confirmar) {
                        for (var libro in libros) {
                          await Dao.deleteLibro(libro.id!);
                        }
                        if (mounted) await cargarDatos();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Colors.amber),
                        title: Text('Editar todos los ejemplares'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Eliminar todos los ejemplares'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _mostrarEjemplaresModal(libros),
          ),
        );
      }).toList(),
    );
  }
}
