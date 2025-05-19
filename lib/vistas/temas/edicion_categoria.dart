import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class EdicionCategoria extends StatefulWidget {
  final Categoria? categoria;

  const EdicionCategoria({Key? key, this.categoria}) : super(key: key);

  @override
  _EdicionCategoriaState createState() => _EdicionCategoriaState();
}

class _EdicionCategoriaState extends State<EdicionCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nombreController.text = widget.categoria!.nombre ?? "";
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.categoria == null ? "Nueva Categoría" : "Editar Categoría"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) =>
                    value!.trim().isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCategoria,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarCategoria() async {
    if (_formKey.currentState!.validate()) {
      final nuevoNombre = _nombreController.text.trim();
      final nuevaCategoria = Categoria(
        id: widget.categoria?.id,
        nombre: nuevoNombre,
      );

      if (widget.categoria == null) {
        await Dao.createCategoria(nuevaCategoria);
      } else {
        await Dao.updateCategoria(nuevaCategoria);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
