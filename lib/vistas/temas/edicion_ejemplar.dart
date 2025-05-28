import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class EdicionEjemplar extends StatefulWidget {
  final Libro libro;

  const EdicionEjemplar({Key? key, required this.libro}) : super(key: key);

  @override
  State<EdicionEjemplar> createState() => _EdicionEjemplarState();
}

class _EdicionEjemplarState extends State<EdicionEjemplar> {
  late TextEditingController _paginasController;
  late TextEditingController _adquisicionController;

  @override
  void initState() {
    super.initState();

    _paginasController = TextEditingController(
      text: widget.libro.numeroPaginas?.toString() ?? '',
    );
    _adquisicionController = TextEditingController(
      text: widget.libro.numAdquisicion ?? '',
    );
  }

  @override
  void dispose() {
    _paginasController.dispose();
    _adquisicionController.dispose();
    super.dispose();
  }

  // Mostrar diálogo de confirmación
  Future<void> _mostrarDialogo(String mensaje) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmación"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  // Guardar cambios del ejemplar
  Future<void> _guardarCambios() async {
    final paginas = int.tryParse(_paginasController.text.trim());
    final adquisicion = _adquisicionController.text.trim();

    if (paginas == null || adquisicion.isEmpty) {
      await _mostrarDialogo("Todos los campos son obligatorios.");
      return;
    }

    final libroActualizado = widget.libro.copyWith(
      numeroPaginas: paginas,
      numAdquisicion: adquisicion,
    );

    await Dao.updateLibro(libroActualizado);
    await _mostrarDialogo("Ejemplar actualizado exitosamente");
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar ejemplar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _paginasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Número de páginas'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adquisicionController,
              decoration: const InputDecoration(labelText: 'No. Adquisición'),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save),
              label: const Text("Guardar cambios"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
