import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';

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
  List<Autor> _autores = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final autores = await Dao.listaAutores();
    if (!mounted) return;
    setState(() {
      _autores = autores;
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _autores.length,
      itemBuilder: (context, index) {
        final autor = _autores[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text("${autor.nombre ?? ""} ${autor.apellidos ?? ""}"),
            trailing: IconButton(
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
            onTap: () => _editarAutor(autor),
          ),
        );
      },
    );
  }
}
