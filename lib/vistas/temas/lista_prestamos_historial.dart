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
  List<Map<String, dynamic>> _historialCompleto = [];
  List<Map<String, dynamic>> _historialFiltrado = [];

  int? mesSeleccionado;
  int? anioSeleccionado;
  String textoBusqueda = '';
  final TextEditingController _busquedaController = TextEditingController();

  final List<String> nombresMeses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  List<int> anios =
      List.generate(10, (index) => DateTime.now().year - 5 + index);

  @override
  void initState() {
    super.initState();
    mesSeleccionado = null;
    anioSeleccionado = null;
    _futureHistorial = Dao.obtenerHistorialPrestamosExtendido();
    _futureHistorial.then((value) {
      _historialCompleto = value;
      aplicarFiltro();
    });
  }

  void aplicarFiltro() {
    final filtrado = _historialCompleto.where((h) {
      final fecha = DateTime.tryParse(h['fecha_devolucion'] ?? '');
      final coincideFecha =
          (mesSeleccionado == null || anioSeleccionado == null)
              ? true
              : (fecha != null &&
                  fecha.month == mesSeleccionado &&
                  fecha.year == anioSeleccionado);

      final coincideBusqueda = textoBusqueda.trim().isEmpty
          ? true
          : (h['nombre_solicitante']
                      ?.toLowerCase()
                      .contains(textoBusqueda.toLowerCase()) ??
                  false) ||
              (h['matricula']
                      ?.toLowerCase()
                      .contains(textoBusqueda.toLowerCase()) ??
                  false);

      return coincideFecha && coincideBusqueda;
    }).toList();

    setState(() {
      _historialFiltrado = filtrado;
    });
  }

  void limpiarFiltro() {
    setState(() {
      textoBusqueda = '';
      _busquedaController.clear();
      mesSeleccionado = null;
      anioSeleccionado = null;
      aplicarFiltro();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (value) {
                    textoBusqueda = value;
                    aplicarFiltro();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre o matrícula',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, size: 28),
                tooltip: 'Filtrar por mes y año',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => _mostrarFiltroBottomSheet(context),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _historialFiltrado.isEmpty
              ? const Center(
                  child: Text("No hay préstamos devueltos que coincidan."))
              : ListView.builder(
                  itemCount: _historialFiltrado.length,
                  itemBuilder: (_, i) {
                    final h = _historialFiltrado[i];
                    return _buildHistorialCard(h);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistorialCard(Map<String, dynamic> h) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(
            "${h['nombre_solicitante'].toString().toUpperCase()} - ${h['matricula']}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("📚 ${h['titulo']} (Adq: ${h['no_adquisicion']})",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            if ((h['nombre_trabajador'] ?? '').toString().isNotEmpty)
              Text("Entregado por: ${h['nombre_trabajador']}"),
            if ((h['estado_libro'] ?? '').toString().isNotEmpty)
              Text("Estado del libro: ${h['estado_libro']}"),
            if ((h['responsable_devolucion'] ?? '')
                .toString()
                .trim()
                .isNotEmpty)
              Text("Responsable devolución: ${h['responsable_devolucion']}"),
            Text("Devuelto: ${_formatearFecha(h['fecha_devolucion'])}",
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _mostrarFiltroBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filtrar por mes y año",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Mes"),
                  value: mesSeleccionado,
                  items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(nombresMeses[index]),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      mesSeleccionado = value;
                      aplicarFiltro();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Año"),
                  value: anioSeleccionado,
                  items: anios
                      .map((anio) => DropdownMenuItem(
                            value: anio,
                            child: Text(anio.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      anioSeleccionado = value;
                      aplicarFiltro();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Aplicar"),
                onPressed: () {
                  aplicarFiltro();
                  Navigator.pop(context);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.cleaning_services),
                label: const Text("Limpiar"),
                onPressed: () {
                  limpiarFiltro();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
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
