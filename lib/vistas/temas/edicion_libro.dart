import 'dart:io';

import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EdicionLibro extends StatefulWidget {
  final Libro? libro;

  const EdicionLibro({Key? key, this.libro}) : super(key: key);

  @override
  _EdicionLibroState createState() => _EdicionLibroState();
}

class _EdicionLibroState extends State<EdicionLibro> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numPaginasController = TextEditingController();
  String? _rutaImagen;
  int? _idCategoriaSeleccionada;
  int? _idAutorSeleccionado;
  List<Categoria> _listaCategorias = [];
  List<Autor> _listaAutores = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    if (widget.libro != null) {
      _tituloController.text = widget.libro!.titulo ?? "";
      _descripcionController.text = widget.libro!.descripcion ?? "";
      _numPaginasController.text =
          widget.libro!.numeroPaginas?.toString() ?? "";
      _rutaImagen = widget.libro!.imagen;
      _idCategoriaSeleccionada = widget.libro!.idCategoria;
      _idAutorSeleccionado = widget.libro!.idAutor;
    }
  }

  Future<void> _cargarDatos() async {
    _listaCategorias = await Dao.listaCategorias();
    _listaAutores = await Dao.listaAutores();
    setState(() {});
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _numPaginasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.libro == null ? "Nuevo Libro" : "Editar Libro"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _rutaImagen != null
                          ? FileImage(File(_rutaImagen!))
                          : null,
                  child:
                      _rutaImagen == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 20),

              // Título del libro
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: "Título del Libro"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo obligatorio"
                            : null,
              ),

              // Número de páginas
              TextFormField(
                controller: _numPaginasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Número de Páginas"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo obligatorio"
                            : null,
              ),

              // Categoría
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Categoría"),
                value: _idCategoriaSeleccionada,
                items:
                    _listaCategorias.map((categoria) {
                      return DropdownMenuItem<int>(
                        value: categoria.id,
                        child: Text(categoria.nombre ?? ""),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _idCategoriaSeleccionada = value),
                validator:
                    (value) =>
                        value == null ? "Seleccione una categoría" : null,
              ),

              // Autor
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Autor"),
                value: _idAutorSeleccionado,
                items:
                    _listaAutores.map((autor) {
                      return DropdownMenuItem<int>(
                        value: autor.id,
                        child: Text(
                          "${autor.nombre ?? ""} ${autor.apellidos ?? ""}",
                        ),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _idAutorSeleccionado = value),
                validator:
                    (value) => value == null ? "Seleccione un autor" : null,
              ),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: "Descripción"),
                maxLines: 5,
              ),

              const SizedBox(height: 20),

              // Botón Guardar
              ElevatedButton(onPressed: _guardarLibro, child: Text("Guardar")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _rutaImagen = pickedFile.path;
      });
    }
  }

  Future<void> _guardarLibro() async {
    if (_rutaImagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecciona una imagen del libro")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // AQUI agregas los prints
      print("Datos a guardar:");
      print("Título: ${_tituloController.text}");
      print("Número de páginas: ${_numPaginasController.text}");
      print("Categoría ID: $_idCategoriaSeleccionada");
      print("Autor ID: $_idAutorSeleccionado");
      print("Ruta Imagen: $_rutaImagen");

      final libro = Libro(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        numeroPaginas: int.tryParse(_numPaginasController.text),
        imagen: _rutaImagen,
        idCategoria: _idCategoriaSeleccionada,
        idAutor: _idAutorSeleccionado,
      );

      if (widget.libro == null) {
        await Dao.createLibro(libro);
      } else {
        libro.id = widget.libro!.id;
        await Dao.updateLibro(libro);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Libro guardado exitosamente")));

      Navigator.pop(context);
    }
  }
}
