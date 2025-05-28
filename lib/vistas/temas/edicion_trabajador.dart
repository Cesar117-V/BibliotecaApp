import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/trabajador.dart';

class EdicionTrabajador extends StatefulWidget {
  final Trabajador? trabajador;
  const EdicionTrabajador({Key? key, this.trabajador}) : super(key: key);

  @override
  State<EdicionTrabajador> createState() => _EdicionTrabajadorState();
}

class _EdicionTrabajadorState extends State<EdicionTrabajador> {
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
      final t = Trabajador(
        id: widget.trabajador?.id,
        nombre: nombreController.text.trim(),
        apellidos: apellidosController.text.trim(),
        correo: correoController.text.trim(),
        codigo: codigoController.text.trim(),
      );
      Navigator.pop(context, t);
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
