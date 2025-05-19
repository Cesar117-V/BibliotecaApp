import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/bibliotecario.dart';

class EdicionBibliotecario extends StatefulWidget {
  final Bibliotecario? bibliotecario;
  const EdicionBibliotecario({Key? key, this.bibliotecario}) : super(key: key);

  @override
  State<EdicionBibliotecario> createState() => _EdicionBibliotecarioState();
}

class _EdicionBibliotecarioState extends State<EdicionBibliotecario> {
  final _formKey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final matriculaController = TextEditingController();
  final carreraController = TextEditingController();
  final correoController = TextEditingController();
  final codigoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bibliotecario != null) {
      nombreController.text = widget.bibliotecario!.nombre;
      apellidosController.text = widget.bibliotecario!.apellidos;
      matriculaController.text = widget.bibliotecario!.matricula;
      carreraController.text = widget.bibliotecario!.carrera;
      correoController.text = widget.bibliotecario!.correo;
      codigoController.text = widget.bibliotecario!.codigo;
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidosController.dispose();
    matriculaController.dispose();
    carreraController.dispose();
    correoController.dispose();
    codigoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final b = Bibliotecario(
        id: widget.bibliotecario?.id,
        nombre: nombreController.text.trim(),
        apellidos: apellidosController.text.trim(),
        matricula: matriculaController.text.trim(),
        carrera: carreraController.text.trim(),
        correo: correoController.text.trim(),
        codigo: codigoController.text.trim(),
      );
      Navigator.pop(context, b);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bibliotecario == null
          ? 'Nuevo Bibliotecario'
          : 'Editar Bibliotecario'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _campo('Nombre', nombreController),
              _campo('Apellidos', apellidosController),
              _campo('Matrícula', matriculaController),
              _campo('Carrera', carreraController),
              _campo('Correo', correoController, tipoCorreo: true),
              _campo('Código (6 dígitos)', codigoController, tipoCodigo: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
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
            labelText: label, border: const OutlineInputBorder()),
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
