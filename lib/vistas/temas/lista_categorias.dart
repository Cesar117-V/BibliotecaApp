import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_categoria.dart';
import 'package:biblioteca_app/vistas/temas/libros_por_categoria.dart'; // 👈 Import necesario

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
  ListaCategoriasState createState() => ListaCategoriasState();
}

class ListaCategoriasState extends State<ListaCategorias> {
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final categorias = await Dao.listaCategorias();
    if (!mounted) return;
    setState(() {
      _categorias = categorias;
    });
  }

  Future<void> _editarCategoria([Categoria? categoria]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EdicionCategoria(categoria: categoria),
      ),
    );

    if (resultado == true && mounted) {
      await cargarDatos();
    }
  }

  void _verLibrosDeCategoria(Categoria categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibrosPorCategoria(categoria: categoria),
      ),
    );
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver libros de la categoría',
                  icon: const Icon(Icons.menu_book, color: Colors.blueAccent),
                  onPressed: () => _verLibrosDeCategoria(categoria),
                ),
                IconButton(
                  tooltip: 'Editar categoría',
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => _editarCategoria(categoria),
                ),
                IconButton(
                  tooltip: 'Eliminar categoría',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmar = await confirmarEliminacion(
                      context,
                      "¿Deseas eliminar esta categoría?",
                    );
                    if (confirmar) {
                      await Dao.deleteCategoria(categoria.id!);
                      if (mounted) await cargarDatos();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
