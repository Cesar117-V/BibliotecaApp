import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class ListaPrestamosHistorial extends StatefulWidget {
  const ListaPrestamosHistorial({super.key});

  @override
  State<ListaPrestamosHistorial> createState() =>
      _ListaPrestamosHistorialState();
}

class _ListaPrestamosHistorialState extends State<ListaPrestamosHistorial>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, dynamic>>> _futureHistorial;

  @override
  void initState() {
    super.initState();
    _futureHistorial = Dao.obtenerHistorialPrestamosExtendido();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureHistorial,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Ocurrió un error: ${snapshot.error}"),
          );
        }

        final historial = snapshot.data;

        if (historial == null || historial.isEmpty) {
          return const Center(child: Text("No hay préstamos devueltos aún."));
        }

        // Agrupar por nombre, matrícula y fecha
        final agrupados = <String, Map<String, dynamic>>{};

        for (var h in historial) {
          final titulo = h['titulo'] ?? '';
          final adquisicion = h['no_adquisicion'] ?? '';
          final nombre = h['nombre_solicitante'] ?? '';
          final matricula = h['matricula'] ?? '';
          final fecha = h['fecha_devolucion'] ?? '';
          final trabajador = h['nombre_trabajador'] ?? '';
          final estadoLibro = h['estado_libro'] ?? '';
          final responsableDev = h['responsable_devolucion'] ?? '';

          final key = "$nombre|$matricula|$fecha";

          if (!agrupados.containsKey(key)) {
            agrupados[key] = {
              'nombre': nombre,
              'matricula': matricula,
              'fecha': fecha,
              'trabajador': trabajador,
              'estado_libro': estadoLibro,
              'responsable_devolucion': responsableDev,
              'libros': <Map<String, dynamic>>[]
            };
          }

          agrupados[key]!['libros'].add({
            'titulo': titulo,
            'adquisicion': adquisicion
          });
        }

        final items = agrupados.values.toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final h = items[i];

            final nombre = h['nombre'];
            final matricula = h['matricula'];
            final fechaDev = _formatearFecha(h['fecha']);
            final libros = h['libros'] as List<Map<String, dynamic>>;
            final trabajador = h['trabajador'];
            final estadoLibro = h['estado_libro'];
            final responsableDev = h['responsable_devolucion'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text("${nombre.toString().toUpperCase()} - $matricula"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    ...libros.map((libro) => Text(
                          "📚 ${libro['titulo']} (Adq: ${libro['adquisicion']})",
                          style: const TextStyle(fontSize: 14),
                        )),
                    const SizedBox(height: 6),
                    if (trabajador != null && trabajador.isNotEmpty)
                      Text("Entregado por: $trabajador"),
                    if (estadoLibro != null && estadoLibro.isNotEmpty)
                      Text("Estado del libro: $estadoLibro"),
                    if (responsableDev != null && responsableDev.trim().isNotEmpty)
                      Text("Responsable devolución: $responsableDev"),
                    Text(
                      "Devuelto: $fechaDev",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _formatearFecha(dynamic fecha) {
    try {
      if (fecha == null || fecha.toString().isEmpty) return 'Sin fecha';
      final f = DateTime.parse(fecha.toString());
      return "${f.day}/${f.month}/${f.year}";
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  @override
  bool get wantKeepAlive => true;
}