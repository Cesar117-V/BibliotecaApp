import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_devolucion.dart';

class ListaDevoluciones extends StatefulWidget {
  const ListaDevoluciones({super.key});

  @override
  State<ListaDevoluciones> createState() => _ListaDevolucionesState();
}

class _ListaDevolucionesState extends State<ListaDevoluciones> {
  List<Map<String, dynamic>> lista = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final datos = await Dao.listaDevolucionesConPrestamo();
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: lista.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text("No hay devoluciones registradas aún."),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final d = lista[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      color: const Color(0xFFF5F0FA),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Usuario: ${d['nombre_solicitante'] ?? '-'}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "Matrícula: ${d['matricula'] ?? '-'}"),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Libros: ${d['titulos_libros'] ?? 'Sin libros'}"),
                                      Text(
                                          "Estado del libro: ${d['estado_libro'] ?? '-'}"),
                                      Text(
                                          "Responsable: ${d['responsable_devolucion'] ?? '-'}"),
                                      Text(
                                          "Entrega: ${d['fecha_EntregaReal'] ?? '-'}"),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EdicionDevolucion(
                                              devolucion: null,
                                            ),
                                          ),
                                        );
                                        cargarDatos();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _eliminar(d['id'] as int),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
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
