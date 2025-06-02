import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';
import 'package:biblioteca_app/vistas/temas/libros_por_autor.dart';

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

class ListaAutores extends StatefulWidget {
  const ListaAutores({Key? key}) : super(key: key);

  @override
  ListaAutoresState createState() => ListaAutoresState();
}

class ListaAutoresState extends State<ListaAutores> {
  final TextEditingController _searchController = TextEditingController();
  List<Autor> _autoresOriginales = [];
  List<Autor> _autoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final autores = await Dao.listaAutores();
    if (!mounted) return;
    setState(() {
      _autoresOriginales = autores;
      _autoresFiltrados = autores;
    });
  }

  void _filtrarAutores(String query) {
    final filtrados = _autoresOriginales.where((autor) {
      final nombreCompleto =
          "${autor.nombre ?? ''} ${autor.apellidos ?? ''}".toLowerCase();
      return nombreCompleto.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _autoresFiltrados = filtrados;
    });
  }

  Future<void> _editarAutor([Autor? autor]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EdicionAutor(autor: autor)),
    );
    if (resultado == true && mounted) {
      await cargarDatos();
    }
  }

  void _verLibrosDelAutor(Autor autor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LibrosPorAutor(autor: autor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (_) {
            FocusScope.of(context).unfocus(); // Oculta teclado al hacer scroll
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 1,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar autor...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: _filtrarAutores,
                  ),
                ),
                toolbarHeight: 70,
                pinned: false,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final autor = _autoresFiltrados[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          "${autor.nombre?.trim() ?? ""} ${autor.apellidos?.trim() ?? ""}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Ver libros del autor',
                              icon: const Icon(Icons.menu_book,
                                  color: Colors.blueAccent),
                              onPressed: () => _verLibrosDelAutor(autor),
                            ),
                            IconButton(
                              tooltip: 'Editar autor',
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _editarAutor(autor),
                            ),
                            IconButton(
                              tooltip: 'Eliminar autor',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmar = await confirmarEliminacion(
                                  context,
                                  "¿Deseas eliminar este autor?",
                                );
                                if (confirmar) {
                                  await Dao.deleteAutor(autor.id!);
                                  if (mounted) await cargarDatos();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _autoresFiltrados.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
