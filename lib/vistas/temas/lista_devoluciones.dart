import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/devolucion.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_devolucion.dart';

class ListaDevoluciones extends StatefulWidget {
  const ListaDevoluciones({super.key});

  @override
  State<ListaDevoluciones> createState() => _ListaDevolucionesState();
}

class _ListaDevolucionesState extends State<ListaDevoluciones> {
  List<Devolucion> lista = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final datos = await Dao.listaDevoluciones();
    if (!mounted) return;
    setState(() {
      lista = datos;
    });
  }

  Future<void> _eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Estás seguro de eliminar esta devolución?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirmar == true) {
      await Dao.deleteDevolucion(id);
      cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Devoluciones")),
      body: lista.isEmpty
          ? const Center(child: Text("No hay devoluciones registradas aún."))
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final d = lista[index];
                return ListTile(
                  leading: const Icon(Icons.assignment_turned_in),
                  title: Text("Entrega: ${d.fechaEntregaReal}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Estado del libro: ${d.estadoLibro}"),
                      Text("Responsable: ${d.responsableDevolucion}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EdicionDevolucion(devolucion: d),
                            ),
                          );
                          cargarDatos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(d.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionDevolucion()),
          );
          cargarDatos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
