import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/bibliotecario.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_bibliotecario.dart';

class GestionBibliotecariosScreen extends StatefulWidget {
  const GestionBibliotecariosScreen({Key? key}) : super(key: key);

  @override
  State<GestionBibliotecariosScreen> createState() =>
      _GestionBibliotecariosScreenState();
}

class _GestionBibliotecariosScreenState
    extends State<GestionBibliotecariosScreen> {
  List<Bibliotecario> bibliotecarios = [];

  @override
  void initState() {
    super.initState();
    _cargarBibliotecarios();
  }

  Future<void> _cargarBibliotecarios() async {
    final lista = await Dao.listaBibliotecarios();
    setState(() {
      bibliotecarios = lista;
    });
  }

  Future<void> _mostrarFormulario() async {
    final nuevo = await showDialog<Bibliotecario>(
      context: context,
      builder: (_) => const EdicionBibliotecario(),
    );

    if (nuevo != null) {
      await Dao.createBibliotecario(nuevo);
      _cargarBibliotecarios();
    }
  }

  Future<void> _editarBibliotecario(Bibliotecario b) async {
    final actualizado = await showDialog<Bibliotecario>(
      context: context,
      builder: (_) => EdicionBibliotecario(bibliotecario: b),
    );

    if (actualizado != null) {
      await Dao.updateBibliotecario(actualizado);
      _cargarBibliotecarios();
    }
  }

  Future<void> _confirmarEliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar bibliotecario?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmar == true) {
      await Dao.deleteBibliotecario(id);
      _cargarBibliotecarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Bibliotecarios')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (bibliotecarios.isEmpty) {
            return const Center(
                child: Text('No hay bibliotecarios registrados'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: bibliotecarios.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = bibliotecarios[index];
                    return Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('${b.nombre} ${b.apellidos}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Correo: ${b.correo}'),
                              Text('Código: ${b.codigo}'),
                              Text('Matrícula: ${b.matricula}'),
                              Text('Carrera: ${b.carrera}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarBibliotecario(b),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmarEliminar(b.id!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        tooltip: 'Agregar bibliotecario',
        child: const Icon(Icons.add),
      ),
    );
  }
}
