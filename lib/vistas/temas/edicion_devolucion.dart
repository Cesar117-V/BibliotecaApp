import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/devolucion.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart';

class EdicionDevolucion extends StatefulWidget {
  final Devolucion? devolucion;

  const EdicionDevolucion({super.key, this.devolucion});

  @override
  State<EdicionDevolucion> createState() => _EdicionDevolucionState();
}

class _EdicionDevolucionState extends State<EdicionDevolucion> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController observacionesController = TextEditingController();
  final TextEditingController trabajadorController = TextEditingController();

  DateTime? fechaEntrega;
  List<Prestamo> prestamosActivos = [];
  Prestamo? prestamoSeleccionado;
  String? estadoSeleccionado;

  final List<String> estadosLibro = [
    'En buen estado',
    'Dañado',
    'Páginas faltantes',
    'Mojado',
    'Perdido',
  ];

  @override
  void initState() {
    super.initState();
    trabajadorController.text = SesionUsuario.nombre;

    if (widget.devolucion != null) {
      final d = widget.devolucion!;
      fechaEntrega = DateTime.tryParse(d.fechaEntregaReal);
      estadoSeleccionado = d.estadoLibro;
      observacionesController.text = d.observaciones;
    }

    Dao.obtenerPrestamosActivos().then((prestamos) {
      setState(() {
        prestamosActivos = prestamos;
      });
    });
  }

  @override
  void dispose() {
    observacionesController.dispose();
    trabajadorController.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final devolucion = Devolucion(
        id: widget.devolucion?.id,
        idPrestamo: prestamoSeleccionado!.id!,
        fechaEntregaReal:
            fechaEntrega?.toIso8601String() ?? DateTime.now().toIso8601String(),
        estadoLibro: estadoSeleccionado!,
        observaciones: observacionesController.text,
        responsableDevolucion: SesionUsuario.nombre,
      );
      if (widget.devolucion == null) {
        await Dao.createDevolucion(devolucion);
        await Dao.liberarLibrosPorDevolucion(devolucion.idPrestamo);

        // 🔁 Mover esta llamada antes de eliminar el detalle
        await Dao.guardarHistorialPrestamo(
          devolucion.idPrestamo,
          devolucion.fechaEntregaReal,
        );

        await Dao.eliminarDetallePrestamoPorIdPrestamo(devolucion.idPrestamo);
        await Dao.updatePrestamoActivo(devolucion.idPrestamo, false);
      } else {
        await Dao.updateDevolucion(devolucion);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devolución guardada exitosamente')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _seleccionarFechaEntrega() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaEntrega ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => fechaEntrega = picked);
    }
  }

  String _formatearFecha(String? fechaISO) {
    if (fechaISO == null || fechaISO.isEmpty) return "Sin fecha";
    try {
      final date = DateTime.parse(fechaISO);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return fechaISO;
    }
  }

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case 'En buen estado':
        return Colors.green;
      case 'Dañado':
        return Colors.red;
      case 'Páginas faltantes':
        return Colors.orange;
      case 'Mojado':
        return Colors.blue;
      case 'Perdido':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Devolución")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Prestamo>(
                decoration:
                    const InputDecoration(labelText: "Seleccionar préstamo"),
                value: prestamoSeleccionado,
                items: prestamosActivos.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text("${p.nombreSolicitante} - ${p.matricula}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    prestamoSeleccionado = value;
                    estadoSeleccionado = 'En buen estado';
                    observacionesController.text = "Sin observaciones";
                    fechaEntrega = DateTime.now();
                  });
                },
                validator: (value) =>
                    value == null ? "Selecciona un préstamo" : null,
              ),
              if (prestamoSeleccionado != null)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Carrera: ${prestamoSeleccionado!.carrera}"),
                        Text(
                            "Libros: ${prestamoSeleccionado!.tituloLibro ?? 'Desconocido'}"),
                        Text(
                            "Préstamo: ${_formatearFecha(prestamoSeleccionado!.fechaPrestamo)}"),
                        Text(
                            "Devolución esperada: ${_formatearFecha(prestamoSeleccionado!.fechaDevolucion)}"),
                      ],
                    ),
                  ),
                ),
              TextFormField(
                controller: trabajadorController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Trabajador"),
              ),
              ListTile(
                title: const Text("Fecha de entrega"),
                subtitle: Text(
                  fechaEntrega != null
                      ? "${fechaEntrega!.day}/${fechaEntrega!.month}/${fechaEntrega!.year}"
                      : "Seleccione una fecha",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _seleccionarFechaEntrega,
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: "Estado del libro"),
                value: estadoSeleccionado,
                items: estadosLibro.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(
                      estado,
                      style: TextStyle(color: _colorPorEstado(estado)),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => estadoSeleccionado = value);
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Selecciona un estado'
                    : null,
                style: TextStyle(
                  color: estadoSeleccionado != null
                      ? _colorPorEstado(estadoSeleccionado!)
                      : Colors.black,
                ),
              ),
              TextFormField(
                controller: observacionesController,
                decoration: const InputDecoration(labelText: "Observaciones"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
