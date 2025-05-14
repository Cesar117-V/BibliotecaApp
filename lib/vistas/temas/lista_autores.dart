import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';
import 'package:flutter/material.dart';

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
            title: Text("${autor.nombre ?? ""} ${autor.apellidos ?? ""}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmar = await confirmarEliminacion(
                  context,
                  "¿Deseas eliminar este autor?",
                );
                if (confirmar) {
                  await Dao.deleteAutor(autor.id!);
                  _cargarAutores();
                }
              },
            ),
            onTap: () async {
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
