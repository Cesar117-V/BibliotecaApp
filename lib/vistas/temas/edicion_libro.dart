import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class EdicionLibro extends StatefulWidget {
  final Libro? libro;
  const EdicionLibro({Key? key, this.libro}) : super(key: key);

  @override
  State<EdicionLibro> createState() => _EdicionLibroState();
}

class _EdicionLibroState extends State<EdicionLibro> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _numPaginasController = TextEditingController();
  final _stockController = TextEditingController();

  String? _rutaImagen;
  int? _idCategoriaSeleccionada;
  int? _idAutorSeleccionado;

  List<Categoria> _listaCategorias = [];
  List<Autor> _listaAutores = [];
  List<TextEditingController> _adquisicionControllers = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    if (widget.libro != null) {
      final libro = widget.libro!;
      _tituloController.text = libro.titulo ?? '';
      _descripcionController.text = libro.descripcion ?? '';
      _numPaginasController.text = libro.numeroPaginas?.toString() ?? '';
      _stockController.text = libro.stock?.toString() ?? '1';
      _rutaImagen = libro.imagen;
      _idCategoriaSeleccionada = libro.idCategoria;
      _idAutorSeleccionado = libro.idAutor;
      _generarCamposAdquisicion(int.tryParse(_stockController.text) ?? 1);
    } else {
      _generarCamposAdquisicion(1);
    }
  }

  Future<void> _cargarDatos() async {
    _listaCategorias = await Dao.listaCategorias();
    _listaAutores = await Dao.listaAutores();
    setState(() {});
  }

  void _generarCamposAdquisicion(int cantidad) {
    _adquisicionControllers =
        List.generate(cantidad, (_) => TextEditingController());
    setState(() {});
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _numPaginasController.dispose();
    _stockController.dispose();
    for (var controller in _adquisicionControllers) {
      controller.dispose();
    }
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _seleccionarImagen,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _rutaImagen != null ? FileImage(File(_rutaImagen!)) : null,
                child: _rutaImagen == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: "Título del Libro"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Campo obligatorio" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numPaginasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Número de Páginas"),
              validator: (v) =>
                  v == null || v.isEmpty ? "Campo obligatorio" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Cantidad de ejemplares"),
              validator: (v) {
                if (v == null || v.isEmpty) return "Campo obligatorio";
                final value = int.tryParse(v);
                if (value == null || value <= 0) {
                  return "Debe ser un número válido";
                }
                return null;
              },
              onChanged: (v) {
                final value = int.tryParse(v);
                if (value != null && value > 0) {
                  _generarCamposAdquisicion(value);
                }
              },
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_adquisicionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: _adquisicionControllers[index],
                    decoration: InputDecoration(
                      labelText: "No. Adquisición ${index + 1}",
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Campo obligatorio" : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Categoría"),
              value: _idCategoriaSeleccionada,
              items: _listaCategorias
                  .map((cat) => DropdownMenuItem(
                      value: cat.id, child: Text(cat.nombre ?? '')))
                  .toList(),
              onChanged: (v) => setState(() => _idCategoriaSeleccionada = v),
              validator: (v) => v == null ? "Seleccione una categoría" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: "Autor"),
              value: _idAutorSeleccionado,
              items: _listaAutores
                  .map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text("${a.nombre} ${a.apellidos}"),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _idAutorSeleccionado = v),
              validator: (v) => v == null ? "Seleccione un autor" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarLibro,
              child: const Text("Guardar"),
            ),
          ],
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
      final titulo = _tituloController.text;
      final descripcion = _descripcionController.text;
      final paginas = int.tryParse(_numPaginasController.text) ?? 0;
      final stock = int.tryParse(_stockController.text) ?? 0;
      final categoriaId = _idCategoriaSeleccionada;
      final autorId = _idAutorSeleccionado;
      final imagen = _rutaImagen;

      for (var i = 0; i < stock; i++) {
        final libro = Libro(
          titulo: titulo,
          descripcion: descripcion,
          numeroPaginas: paginas,
          imagen: imagen,
          idCategoria: categoriaId,
          idAutor: autorId,
          stock: 1,
          numAdquisicion: _adquisicionControllers[i].text,
          cantidadEjemplares: 1,
          disponible: true,
        );

        await Dao.createLibro(libro);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Libro(s) guardado(s) exitosamente")),
      );

      Navigator.pop(context, true);
    }
  }
}
