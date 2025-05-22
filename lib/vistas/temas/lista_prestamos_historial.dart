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
    _futureHistorial = Dao.obtenerHistorialPrestamos();
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

        // Agrupar por título, nombre y matrícula
        final agrupados = <String, Map<String, dynamic>>{};

        for (var h in historial) {
          final titulo = h['titulo'] ?? '';
          final adquisicion = h['no_adquisicion'] ?? '';
          final nombre = h['nombre_solicitante'] ?? '';
          final matricula = h['matricula'] ?? '';
          final fecha = h['fecha_devolucion'] ?? '';

          final key = "$titulo|$nombre|$matricula|$fecha";

          if (!agrupados.containsKey(key)) {
            agrupados[key] = {
              'titulo': titulo,
              'adquisiciones': [adquisicion],
              'nombre': nombre,
              'matricula': matricula,
              'fecha': fecha
            };
          } else {
            agrupados[key]!['adquisiciones'].add(adquisicion);
          }
        }

        final items = agrupados.values.toList();

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final h = items[i];

            final titulo = h['titulo'];
            final nombre = h['nombre'];
            final matricula = h['matricula'];
            final fechaDev = _formatearFecha(h['fecha']);
            final adquisiciones = (h['adquisiciones'] as List).join(', ');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.book_outlined),
                title: Text(titulo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${nombre.toString().toUpperCase()} - $matricula"),
                    Text("Adquisiciones: $adquisiciones"),
                    Text("Devuelto: $fechaDev"),
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
