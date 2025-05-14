import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_categoria.dart';
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

class ListaCategorias extends StatefulWidget {
  const ListaCategorias({Key? key}) : super(key: key);

  @override
  _ListaCategoriasState createState() => _ListaCategoriasState();
}

class _ListaCategoriasState extends State<ListaCategorias> {
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    _categorias = await Dao.listaCategorias();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Categorías")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionCategoria()),
          );
          _cargarCategorias();
        },
      ),
      body: ListView.builder(
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          return ListTile(
            title: Text(categoria.nombre ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmar = await confirmarEliminacion(
                  context,
                  "¿Deseas eliminar esta categoría?",
                );
                if (confirmar) {
                  await Dao.deleteCategoria(categoria.id!);
                  _cargarCategorias();
                }
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdicionCategoria(categoria: categoria),
                ),
              );
              _cargarCategorias();
            },
          );
        },
      ),
    );
  }
}
