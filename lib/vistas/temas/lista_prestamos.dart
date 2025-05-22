import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_prestamo.dart';

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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar"),
            ),
          ],
        ),
      ) ??
      false;
}

class ListaPrestamos extends StatefulWidget {
  const ListaPrestamos({Key? key}) : super(key: key);

  @override
  State<ListaPrestamos> createState() => _ListaPrestamosState();
}

class _ListaPrestamosState extends State<ListaPrestamos>
    with AutomaticKeepAliveClientMixin {
  List<Prestamo> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    final prestamos = await Dao.obtenerPrestamosActivos();
    if (!mounted) return;
    setState(() {
      _prestamos = prestamos;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para keepAlive
    return ListView.builder(
      itemCount: _prestamos.length,
      itemBuilder: (context, index) {
        final prestamo = _prestamos[index];

        final titulos = (prestamo.tituloLibro ?? "Sin título").split(', ');
        final Map<String, int> conteo = {};
        for (var titulo in titulos) {
          if (titulo.trim().isEmpty) continue;
          conteo[titulo] = (conteo[titulo] ?? 0) + 1;
        }
        final librosFormateados = conteo.entries
            .map((entry) => "📚 ${entry.key} (x${entry.value})")
            .join('\n');

        return ExpansionTile(
          key: PageStorageKey("prestamo_${prestamo.id}"),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
          title: Text(
            "${prestamo.nombreSolicitante.toUpperCase()} - ${prestamo.matricula}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Carrera: ${prestamo.carrera}"),
                const SizedBox(height: 4),
                const Text("Libros:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(librosFormateados, style: const TextStyle(height: 1.4)),
                const SizedBox(height: 4),
                Text("Cantidad: ${prestamo.cantidadLibros}"),
                Text("Préstamo: ${_formatearFecha(prestamo.fechaPrestamo)}"),
                Text(
                    "Devolución: ${_formatearFecha(prestamo.fechaDevolucion)}"),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EdicionPrestamo(prestamo: prestamo),
                            ),
                          );
                          if (!mounted) return;
                          if (result == true) await _cargarPrestamos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmar = await confirmarEliminacion(
                            context,
                            "¿Deseas eliminar este préstamo?",
                          );
                          if (confirmar) {
                            await Dao.restaurarStockPorPrestamo(prestamo.id!);
                            await Dao.eliminarDetallePrestamoPorIdPrestamo(
                                prestamo.id!);
                            await Dao.deletePrestamo(prestamo.id!);
                            if (!mounted) return;
                            await _cargarPrestamos();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Préstamo eliminado y libros restaurados correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatearFecha(String? fechaISO) {
    if (fechaISO == null || fechaISO.isEmpty) return "Sin fecha";
    try {
      final date = DateTime.parse(fechaISO);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return fechaISO;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
