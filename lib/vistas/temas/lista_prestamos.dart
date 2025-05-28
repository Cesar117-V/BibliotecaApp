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
  State<ListaPrestamos> createState() => ListaPrestamosState();
}

class ListaPrestamosState extends State<ListaPrestamos>
    with AutomaticKeepAliveClientMixin {
  List<Prestamo> _prestamos = [];
  List<Prestamo> _prestamosFiltrados = [];

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
    mesSeleccionado = null; // ← ahora inicia limpio
    anioSeleccionado = null; // ← ahora inicia limpio
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prestamos = await Dao.obtenerPrestamosActivos();
    if (!mounted) return;
    setState(() {
      _prestamos = prestamos;
      aplicarFiltro();
    });
  }

  void aplicarFiltro() {
    final nuevosPrestamosFiltrados = _prestamos.where((prestamo) {
      final fecha = DateTime.tryParse(prestamo.fechaPrestamo ?? '');
      final coincideFecha =
          (mesSeleccionado == null || anioSeleccionado == null)
              ? true
              : (fecha != null &&
                  fecha.month == mesSeleccionado &&
                  fecha.year == anioSeleccionado);

      final coincideBusqueda = textoBusqueda.trim().isEmpty
          ? true
          : (prestamo.nombreSolicitante
                      ?.toLowerCase()
                      .contains(textoBusqueda.toLowerCase()) ??
                  false) ||
              (prestamo.matricula
                      ?.toLowerCase()
                      .contains(textoBusqueda.toLowerCase()) ??
                  false);

      return coincideFecha && coincideBusqueda;
    }).toList();

    setState(() {
      _prestamosFiltrados = nuevosPrestamosFiltrados;
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
    super.build(context); // keepAlive
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
          child: _prestamosFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No hay préstamos que coincidan.",
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Ver todos"),
                        onPressed: limpiarFiltro,
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _prestamosFiltrados.length,
                  itemBuilder: (context, index) {
                    final prestamo = _prestamosFiltrados[index];
                    final titulos =
                        (prestamo.tituloLibro ?? "Sin título").split(', ');
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
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Carrera: ${prestamo.carrera}"),
                            const SizedBox(height: 4),
                            const Text("Libros:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(librosFormateados,
                                style: const TextStyle(height: 1.4)),
                            const SizedBox(height: 4),
                            Text("Cantidad: ${prestamo.cantidadLibros}"),
                            Text(
                                "Préstamo: ${_formatearFecha(prestamo.fechaPrestamo)}"),
                            Text(
                                "Devolución: ${_formatearFecha(prestamo.fechaDevolucion)}"),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EdicionPrestamo(
                                              prestamo: prestamo),
                                        ),
                                      );
                                      if (!mounted) return;
                                      if (result == true) await cargarDatos();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirmar =
                                          await confirmarEliminacion(
                                        context,
                                        "¿Deseas eliminar este préstamo?",
                                      );
                                      if (confirmar) {
                                        await Dao.restaurarStockPorPrestamo(
                                            prestamo.id!);
                                        await Dao
                                            .eliminarDetallePrestamoPorIdPrestamo(
                                                prestamo.id!);
                                        await Dao.deletePrestamo(prestamo.id!);
                                        if (!mounted) return;
                                        await cargarDatos();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                ),
        ),
      ],
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
