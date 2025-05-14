import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:flutter/material.dart';

class EdicionAutor extends StatefulWidget {
  final Autor? autor;

  const EdicionAutor({Key? key, this.autor}) : super(key: key);

  @override
  _EdicionAutorState createState() => _EdicionAutorState();
}

class _EdicionAutorState extends State<EdicionAutor> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController =
      TextEditingController(); // NUEVO controlador para correo

  @override
  void initState() {
    super.initState();
    if (widget.autor != null) {
      _nombreController.text = widget.autor!.nombre ?? "";
      _apellidoController.text = widget.autor!.apellidos ?? "";
      _correoController.text =
          widget.autor!.correo ?? ""; // Cargar correo si edita
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.autor == null ? "Nuevo Autor" : "Editar Autor"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo obligatorio"
                            : null,
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: "Apellido"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo obligatorio"
                            : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: "Correo electrónico"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obligatorio";
                  }
                  if (!RegExp(
                    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                  ).hasMatch(value)) {
                    return "Correo inválido";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _guardarAutor, child: Text("Guardar")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarAutor() async {
    if (_formKey.currentState!.validate()) {
      final autor = Autor(
        nombre: _nombreController.text,
        apellidos: _apellidoController.text,
        correo: _correoController.text,
      );
      if (widget.autor == null) {
        await Dao.createAutor(autor);
      } else {
        autor.id = widget.autor!.id;
        await Dao.updateAutor(autor);
      }
      Navigator.pop(context);
    }
  }
}
