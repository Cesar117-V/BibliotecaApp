import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_categoria.dart';

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

  Future<void> _editarCategoria([Categoria? categoria]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EdicionCategoria(categoria: categoria),
      ),
    );

    if (resultado == true) {
      _cargarCategorias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _categorias.length,
      itemBuilder: (context, index) {
        final categoria = _categorias[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(categoria.nombre ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
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
            onTap: () => _editarCategoria(categoria),
          ),
        );
      },
    );
  }
}
