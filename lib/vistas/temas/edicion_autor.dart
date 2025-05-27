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

  @override
  void initState() {
    super.initState();
    if (widget.autor != null) {
      _nombreController.text = widget.autor!.nombre ?? "";
    }
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
                    (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _guardarAutor, child: Text("Guardar")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarAutor() async {
    if (_formKey.currentState!.validate()) {
      final autor = Autor(nombre: _nombreController.text);
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
