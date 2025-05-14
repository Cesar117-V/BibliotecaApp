import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_prestamo.dart';

Future<bool> confirmarEliminacion(BuildContext context, String mensaje) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
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

class _ListaPrestamosState extends State<ListaPrestamos> {
  List<Prestamo> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    final prestamos = await Dao.listaPrestamos();
    setState(() {
      _prestamos = prestamos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de Préstamos")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionPrestamo()),
          );
          _cargarPrestamos();
        },
      ),
      body: ListView.builder(
        itemCount: _prestamos.length,
        itemBuilder: (context, index) {
          final prestamo = _prestamos[index];
          return ListTile(
            title: Text(
              "${prestamo.nombreSolicitante} - ${prestamo.matricula}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Carrera: ${prestamo.carrera}\n"
              "Libro/Clasificador: ${prestamo.numeroClasificador}\n"
              "Préstamo: ${_formatearFecha(prestamo.fechaPrestamo)}\n"
              "Devolución: ${_formatearFecha(prestamo.fechaDevolucion)}",
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmar = await confirmarEliminacion(
                  context,
                  "¿Deseas eliminar este préstamo?",
                );
                if (confirmar) {
                  await Dao.deletePrestamo(prestamo.id!);
                  _cargarPrestamos();
                }
              },
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EdicionPrestamo(prestamo: prestamo),
                ),
              );
              _cargarPrestamos();
            },
          );
        },
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
}
