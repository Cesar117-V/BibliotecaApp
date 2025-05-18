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
  final _stockController = TextEditingController(); // ← controller para stock

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
      _stockController.text =
          widget.libro!.stock?.toString() ?? "0"; // ← poblamos stock
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
    _stockController.dispose(); // ← liberamos el controller
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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _rutaImagen != null
                      ? FileImage(File(_rutaImagen!))
                      : null,
                  child: _rutaImagen == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              TextFormField(
                controller: _tituloController,
                decoration:
                    const InputDecoration(labelText: "Título del Libro"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 12),

              // Número de páginas
              TextFormField(
                controller: _numPaginasController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Número de Páginas"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 12),

              // Stock
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Stock (ejemplares)"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Campo obligatorio";
                  if (int.tryParse(v) == null) return "Debe ser un número";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Categoría
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Categoría"),
                value: _idCategoriaSeleccionada,
                items: _listaCategorias.map((cat) {
                  return DropdownMenuItem(
                      value: cat.id, child: Text(cat.nombre ?? ""));
                }).toList(),
                onChanged: (v) => setState(() => _idCategoriaSeleccionada = v),
                validator: (v) => v == null ? "Seleccione una categoría" : null,
              ),
              const SizedBox(height: 12),

              // Autor
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Autor"),
                value: _idAutorSeleccionado,
                items: _listaAutores.map((a) {
                  return DropdownMenuItem(
                    value: a.id,
                    child: Text("${a.nombre} ${a.apellidos}"),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _idAutorSeleccionado = v),
                validator: (v) => v == null ? "Seleccione un autor" : null,
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              ElevatedButton(
                onPressed: _guardarLibro,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _rutaImagen = picked.path);
  }

  Future<void> _guardarLibro() async {
    if (_rutaImagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una imagen del libro")),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      final libro = Libro(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        numeroPaginas: int.tryParse(_numPaginasController.text),
        imagen: _rutaImagen,
        idCategoria: _idCategoriaSeleccionada,
        idAutor: _idAutorSeleccionado,
        stock: int.tryParse(_stockController.text) ?? 0, // ← leemos stock
      );

      if (widget.libro == null) {
        await Dao.createLibro(libro);
      } else {
        libro.id = widget.libro!.id;
        await Dao.updateLibro(libro);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Libro guardado exitosamente")),
      );
      // devolvemos 'true' para que la lista se recargue
      Navigator.pop(context, true);
    }
  }
}
