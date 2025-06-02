import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/modelo/autor.dart';
import 'package:biblioteca_app/modelo/categoria.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart';
import 'package:biblioteca_app/vistas/seleccion_libros.dart';

class EdicionPrestamo extends StatefulWidget {
  final Prestamo? prestamo;

  const EdicionPrestamo({super.key, this.prestamo});

  @override
  State<EdicionPrestamo> createState() => _EdicionPrestamoState();
}

class _EdicionPrestamoState extends State<EdicionPrestamo> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController nombreSolicitanteController =
      TextEditingController();
  final TextEditingController trabajadorController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  DateTime? fechaDevolucion;
  DateTime? fechaPrestamo;

  final List<String> carreras = ['IINF', 'CP', 'IGE', 'IC', 'ISC'];
  String? carreraSeleccionada;

  final List<String> generos = ['M', 'F'];
  String? generoSeleccionado;

  int? cantidadSeleccionada;
  List<Libro> librosSeleccionados = [];

  Map<int, String> mapAutores = {};
  Map<int, String> mapCategorias = {};

  @override
  void initState() {
    super.initState();
    trabajadorController.text = SesionUsuario.nombre;

    Future.wait([
      Dao.listaAutores(),
      Dao.listaCategorias(),
    ]).then((results) {
      final autores = results[0] as List<Autor>;
      final categorias = results[1] as List<Categoria>;
      setState(() {
        mapAutores = {for (var a in autores) a.id!: a.nombre!};
        mapCategorias = {for (var c in categorias) c.id!: c.nombre!};
      });
    });

    if (widget.prestamo != null) {
      final p = widget.prestamo!;
      matriculaController.text = p.matricula;
      nombreSolicitanteController.text = p.nombreSolicitante;
      carreraSeleccionada = p.carrera;
      trabajadorController.text = p.trabajador;
      observacionesController.text = p.observaciones;
      fechaDevolucion = DateTime.tryParse(p.fechaDevolucion);
      fechaPrestamo = DateTime.tryParse(p.fechaPrestamo ?? '');
      generoSeleccionado = p.sexo;
      cantidadSeleccionada = p.cantidadLibros;
    }
  }

  @override
  void dispose() {
    matriculaController.dispose();
    nombreSolicitanteController.dispose();
    trabajadorController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  Future<void> _irASeleccionLibros() async {
    if (cantidadSeleccionada == null) return;
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeleccionLibrosScreen(
          cantidadMaxima: cantidadSeleccionada!,
          librosPreseleccionados: librosSeleccionados,
          mapAutores: mapAutores,
          mapCategorias: mapCategorias,
        ),
      ),
    );
    if (resultado != null && resultado is List<Libro>) {
      setState(() {
        librosSeleccionados = resultado;
      });
    }
  }

  void _guardarPrestamo() async {
    if (_formKey.currentState!.validate()) {
      if (fechaPrestamo == null ||
          fechaDevolucion == null ||
          cantidadSeleccionada == null ||
          librosSeleccionados.length != cantidadSeleccionada) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Es necesario llenar todos los apartados')),
        );
        return;
      }

      final prestamo = Prestamo(
        id: widget.prestamo?.id,
        matricula: matriculaController.text,
        nombreSolicitante: nombreSolicitanteController.text,
        carrera: carreraSeleccionada!,
        sexo: generoSeleccionado,
        cantidadLibros: cantidadSeleccionada!,
        numeroClasificador:
            librosSeleccionados.map((l) => l.numAdquisicion).join(', '),
        trabajador: trabajadorController.text,
        fechaPrestamo: fechaPrestamo?.toIso8601String(),
        fechaDevolucion: fechaDevolucion?.toIso8601String() ?? '',
        observaciones: observacionesController.text,
      );

      final db = await Dao.database;

      if (widget.prestamo == null) {
        final idPrestamo = await db.insert('prestamos', prestamo.toJson());

        for (var libro in librosSeleccionados) {
          await db.insert('detalleprestamos', {
            'id_prestamo': idPrestamo,
            'id_libro': libro.id,
            'titulo': libro.titulo ?? 'Sin título',
            'no_adquisicion': libro.numAdquisicion,
            'autor': mapAutores[libro.idAutor] ?? 'Desconocido',
            'categoria': mapCategorias[libro.idCategoria] ?? 'Sin categoría',
          });

          await db.rawUpdate('''
            UPDATE libros
            SET stock = CASE WHEN stock - 1 < 0 THEN 0 ELSE stock - 1 END
            WHERE id = ?
          ''', [libro.id]);

          await db.update(
            'libros',
            {'disponible': 0},
            where: 'id = ?',
            whereArgs: [libro.id],
          );
        }
      } else {
        await Dao.updatePrestamo(prestamo);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Préstamo guardado exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Es necesario llenar todos los apartados')),
      );
    }
  }

  Future<void> _seleccionarFechaDevolucion() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaDevolucion ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => fechaDevolucion = picked);
  }

  Future<void> _seleccionarFechaPrestamo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fechaPrestamo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => fechaPrestamo = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text("Préstamo"),
      ),
      body: Container(
        color: const Color(0xFFF0F2F5),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            color: const Color(0xFFFFFCF7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: matriculaController,
                      decoration: const InputDecoration(labelText: "Matrícula"),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreSolicitanteController,
                      decoration: const InputDecoration(
                          labelText: "Nombre del Solicitante"),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "Carrera del Solicitante"),
                      value: carreraSeleccionada,
                      items: carreras
                          .map((carrera) => DropdownMenuItem(
                              value: carrera, child: Text(carrera)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => carreraSeleccionada = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Seleccione una carrera'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Género"),
                      value: generoSeleccionado,
                      items: generos
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => generoSeleccionado = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Seleccione un género'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                          labelText: "Cantidad de Libros"),
                      value: cantidadSeleccionada,
                      items: List.generate(3, (i) => i + 1)
                          .map((n) =>
                              DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          cantidadSeleccionada = value;
                          librosSeleccionados = [];
                        });
                      },
                      validator: (value) => value == null
                          ? 'Seleccione la cantidad de libros'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (cantidadSeleccionada != null)
                      ElevatedButton(
                        onPressed: _irASeleccionLibros,
                        child: const Text('Seleccionar Libros'),
                      ),
                    const SizedBox(height: 16),
                    if (librosSeleccionados.isNotEmpty)
                      ...librosSeleccionados.map((libro) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(libro.titulo ?? 'Sin título'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Adquisición: ${libro.numAdquisicion ?? ''}'),
                                  Text(
                                      'Autor: ${mapAutores[libro.idAutor] ?? 'Desconocido'}'),
                                  Text(
                                      'Categoría: ${mapCategorias[libro.idCategoria] ?? 'Sin categoría'}'),
                                ],
                              ),
                            ),
                          )),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: trabajadorController,
                      decoration:
                          const InputDecoration(labelText: "Trabajador"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text("Fecha del Préstamo"),
                      subtitle: Text(
                        fechaPrestamo != null
                            ? "${fechaPrestamo!.day}/${fechaPrestamo!.month}/${fechaPrestamo!.year}"
                            : "Seleccione una fecha",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFechaPrestamo,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text("Fecha de Devolución"),
                      subtitle: Text(
                        fechaDevolucion != null
                            ? "${fechaDevolucion!.day}/${fechaDevolucion!.month}/${fechaDevolucion!.year}"
                            : "Seleccione una fecha",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFechaDevolucion,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: observacionesController,
                      decoration:
                          const InputDecoration(labelText: "Observaciones"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _guardarPrestamo,
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
