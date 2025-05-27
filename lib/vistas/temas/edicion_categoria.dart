import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria == null ? "Nueva Categoría" : "Editar Categoría")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCategoria,
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarCategoria() async {
    if (_formKey.currentState!.validate()) {
      final categoria = Categoria(nombre: _nombreController.text);
      if (widget.categoria == null) {
        await Dao.createCategoria(categoria);
      } else {
        categoria.id = widget.categoria!.id;
        await Dao.updateCategoria(categoria);
      }
      Navigator.pop(context);
    }
  }
}
