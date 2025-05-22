import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart';

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
  final TextEditingController cantidadLibrosController =
      TextEditingController();
  final TextEditingController numeroClasificadorController =
      TextEditingController();
  final TextEditingController trabajadorController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  DateTime? fechaDevolucion;
  DateTime? fechaPrestamo;

  List<Libro> librosDisponibles = [];
  List<Libro> librosOriginales = [];
  Libro? libroSeleccionado;

  final List<String> carreras = [
    'INGENIERIA INFORMATICA',
    'CONTADOR PUBLICO',
    'INGENIERIA EN GESTION EMPRESARIAL',
    'INGENIERIA CIVIL',
    'INGENIERIA EN SISTEMAS COMPUTACIONALES',
  ];

  String? carreraSeleccionada;

  @override
  void initState() {
    super.initState();
    trabajadorController.text = SesionUsuario.nombre;

    Dao.obtenerLibrosDisponibles().then((libros) {
      librosOriginales = libros;

      final Map<String, Libro> agrupados = {};
      for (var libro in libros) {
        final key = libro.titulo ?? '';
        if (!agrupados.containsKey(key)) {
          agrupados[key] = Libro(
            id: libro.id,
            titulo: libro.titulo,
            numAdquisicion: libro.numAdquisicion,
            cantidadEjemplares: libro.cantidadEjemplares ?? 1,
            stock: libro.stock ?? 1,
          );
        } else {
          agrupados[key]!.stock =
              (agrupados[key]!.stock ?? 0) + (libro.stock ?? 1);
          agrupados[key]!.cantidadEjemplares =
              (agrupados[key]!.cantidadEjemplares ?? 0) +
                  (libro.cantidadEjemplares ?? 1);
        }
      }

      setState(() {
        librosDisponibles = agrupados.values.toList();
      });
    });

    if (widget.prestamo != null) {
      final p = widget.prestamo!;
      matriculaController.text = p.matricula;
      nombreSolicitanteController.text = p.nombreSolicitante;
      carreraSeleccionada = p.carrera;
      cantidadLibrosController.text = p.cantidadLibros.toString();
      numeroClasificadorController.text = p.numeroClasificador ?? '';
      trabajadorController.text = p.trabajador;
      observacionesController.text = p.observaciones;
      fechaDevolucion = DateTime.tryParse(p.fechaDevolucion);
      fechaPrestamo = DateTime.tryParse(p.fechaPrestamo ?? '');
    }
  }

  @override
  void dispose() {
    matriculaController.dispose();
    nombreSolicitanteController.dispose();
    cantidadLibrosController.dispose();
    numeroClasificadorController.dispose();
    trabajadorController.dispose();
    observacionesController.dispose();
    super.dispose();
  }

  void _guardarPrestamo() async {
    if (_formKey.currentState!.validate()) {
      final prestamo = Prestamo(
        id: widget.prestamo?.id,
        matricula: matriculaController.text,
        nombreSolicitante: nombreSolicitanteController.text,
        carrera: carreraSeleccionada!,
        cantidadLibros: int.parse(cantidadLibrosController.text),
        numeroClasificador: numeroClasificadorController.text,
        trabajador: trabajadorController.text,
        fechaPrestamo: fechaPrestamo?.toIso8601String(),
        fechaDevolucion: fechaDevolucion?.toIso8601String() ?? '',
        observaciones: observacionesController.text,
      );

      final db = await Dao.database;

      if (widget.prestamo == null) {
        final idPrestamo = await db.insert('prestamos', prestamo.toJson());

        final ejemplaresSeleccionados = librosOriginales
            .where((l) => l.titulo == libroSeleccionado?.titulo)
            .take(prestamo.cantidadLibros)
            .toList();

        for (var libro in ejemplaresSeleccionados) {
          await db.insert('detalleprestamos', {
            'id_prestamo': idPrestamo,
            'id_libro': libro.id,
            'titulo': libro.titulo ?? 'Sin título',
            'no_adquisicion': libro.numAdquisicion,
            'clasificacion': 'General',
            'autor': 'Desconocido',
          });

          await db.rawUpdate('''
            UPDATE libros
            SET stock = CASE WHEN stock - 1 < 0 THEN 0 ELSE stock - 1 END
            WHERE id = ?
          ''', [libro.id]);

          // 🔒 Marcar como no disponible este ejemplar
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
      Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Préstamo")),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              TextFormField(
                controller: nombreSolicitanteController,
                decoration:
                    const InputDecoration(labelText: "Nombre del Solicitante"),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: "Carrera del Solicitante"),
                value: carreraSeleccionada,
                items: carreras.map((carrera) {
                  return DropdownMenuItem(
                    value: carrera,
                    child: Text(carrera),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    carreraSeleccionada = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Seleccione una carrera'
                    : null,
              ),
              DropdownButtonFormField<Libro>(
                value: libroSeleccionado,
                decoration:
                    const InputDecoration(labelText: 'Seleccionar Libro'),
                items: librosDisponibles.map((libro) {
                  return DropdownMenuItem(
                    value: libro,
                    child: Text(libro.titulo ?? 'Sin título'),
                  );
                }).toList(),
                onChanged: (libro) {
                  setState(() {
                    libroSeleccionado = libro;
                    cantidadLibrosController.text = '';
                    numeroClasificadorController.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un libro' : null,
              ),
              if (libroSeleccionado != null)
                DropdownButtonFormField<int>(
                  value: int.tryParse(cantidadLibrosController.text),
                  decoration:
                      const InputDecoration(labelText: "Cantidad de Libros"),
                  items: List.generate(
                    (libroSeleccionado?.stock ?? 1),
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      cantidadLibrosController.text = value.toString();
                      final ejemplares = librosOriginales
                          .where((l) => l.titulo == libroSeleccionado?.titulo)
                          .take(value ?? 1)
                          .toList();
                      final texto = ejemplares
                          .map((e) => "ID: ${e.id}, Adq: ${e.numAdquisicion}")
                          .join('\n');

                      numeroClasificadorController.text = texto;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione una cantidad válida' : null,
                ),
              TextFormField(
                controller: numeroClasificadorController,
                decoration: const InputDecoration(
                    labelText: "Número del libro y clasificador"),
                readOnly: true,
                maxLines: 4,
              ),
              TextFormField(
                controller: trabajadorController,
                decoration: const InputDecoration(labelText: "Trabajador"),
                readOnly: true,
              ),
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
              TextFormField(
                controller: observacionesController,
                decoration: const InputDecoration(labelText: "Observaciones"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarPrestamo,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
