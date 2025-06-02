import 'package:biblioteca_app/modelo/trabajador.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:flutter/material.dart';

class GestionTrabajadoresScreen extends StatefulWidget {
  const GestionTrabajadoresScreen({Key? key}) : super(key: key);

  @override
  State<GestionTrabajadoresScreen> createState() =>
      _GestionTrabajadoresScreenState();
}

class _GestionTrabajadoresScreenState extends State<GestionTrabajadoresScreen> {
  List<Trabajador> trabajadores = [];

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  Future<void> _cargarTrabajadores() async {
    final lista = await Dao.listaTrabajadores();
    setState(() {
      trabajadores = lista;
    });
  }

  Future<void> _agregarOEditarTrabajador({Trabajador? trabajador}) async {
    if (trabajador == null && trabajadores.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solo se pueden registrar hasta 3 trabajadores.')),
      );
      return;
    }

    final resultado = await showDialog<Trabajador>(
      context: context,
      builder: (_) => _FormularioTrabajadorDialog(trabajador: trabajador),
    );

    if (resultado != null) {
      if (resultado.id != null) {
        await Dao.updateTrabajador(resultado);
      } else {
        await Dao.createTrabajador(resultado);
      }
      _cargarTrabajadores();
    }
  }

  Future<void> _eliminarTrabajador(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar trabajador?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Dao.deleteTrabajador(id);
      _cargarTrabajadores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Trabajadores')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (trabajadores.isEmpty) {
            return const Center(child: Text('No hay trabajadores registrados'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: trabajadores.length,
                  itemBuilder: (context, index) {
                    final t = trabajadores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('${t.nombre} ${t.apellidos}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Correo: ${t.correo}'),
                            Text('Código: ${t.codigo}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _agregarOEditarTrabajador(trabajador: t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarTrabajador(t.id!),
                            ),
                          ],
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
        onPressed: _agregarOEditarTrabajador,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FormularioTrabajadorDialog extends StatefulWidget {
  final Trabajador? trabajador;

  const _FormularioTrabajadorDialog({Key? key, this.trabajador})
      : super(key: key);

  @override
  State<_FormularioTrabajadorDialog> createState() =>
      _FormularioTrabajadorDialogState();
}

class _FormularioTrabajadorDialogState
    extends State<_FormularioTrabajadorDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final correoController = TextEditingController();
  final codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.trabajador != null) {
      nombreController.text = widget.trabajador!.nombre;
      apellidosController.text = widget.trabajador!.apellidos;
      correoController.text = widget.trabajador!.correo;
      codigoController.text = widget.trabajador!.codigo;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    codigoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final trabajador = Trabajador(
        id: widget.trabajador?.id,
        nombre: nombreController.text.trim(),
        apellidos: apellidosController.text.trim(),
        correo: correoController.text.trim(),
        codigo: codigoController.text.trim(),
      );
      Navigator.pop(context, trabajador);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.trabajador == null ? 'Nuevo Trabajador' : 'Editar Trabajador'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo('Nombre', nombreController),
              _campo('Apellidos', apellidosController),
              _campo('Correo', correoController, tipoCorreo: true),
              _campo('Código (6 dígitos)', codigoController, tipoCodigo: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _campo(String label, TextEditingController controller,
      {bool tipoCorreo = false, bool tipoCodigo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: tipoCorreo
            ? TextInputType.emailAddress
            : tipoCodigo
                ? TextInputType.number
                : TextInputType.text,
        maxLength: tipoCodigo ? 6 : null,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo obligatorio';
          if (tipoCorreo && (!value.contains('@') || !value.contains('.'))) {
            return 'Correo inválido';
          }
          if (tipoCodigo &&
              (value.length != 6 || int.tryParse(value) == null)) {
            return 'Debe ser un número de 6 dígitos';
          }
          return null;
        },
      ),
    );
  }
}
