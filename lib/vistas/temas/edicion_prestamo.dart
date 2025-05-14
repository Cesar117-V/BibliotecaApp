import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/prestamo.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

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
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController cantidadLibrosController =
      TextEditingController();
  final TextEditingController numeroClasificadorController =
      TextEditingController();
  final TextEditingController trabajadorController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  DateTime? fechaDevolucion;
  DateTime? fechaPrestamo;

  @override
  void initState() {
    super.initState();
    if (widget.prestamo != null) {
      final p = widget.prestamo!;
      matriculaController.text = p.matricula;
      nombreSolicitanteController.text = p.nombreSolicitante;
      carreraController.text = p.carrera ?? '';
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
    carreraController.dispose();
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
        carrera: carreraController.text,
        cantidadLibros: int.parse(cantidadLibrosController.text),
        numeroClasificador: numeroClasificadorController.text,
        trabajador: trabajadorController.text,
        fechaPrestamo: fechaPrestamo?.toIso8601String(),
        fechaDevolucion: fechaDevolucion?.toIso8601String() ?? '',
        observaciones: observacionesController.text,
      );

      if (widget.prestamo == null) {
        await Dao.createPrestamo(prestamo);
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaDevolucion ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => fechaDevolucion = picked);
    }
  }

  Future<void> _seleccionarFechaPrestamo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaPrestamo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => fechaPrestamo = picked);
    }
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
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: nombreSolicitanteController,
                decoration: const InputDecoration(
                  labelText: "Nombre del Solicitante",
                ),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: carreraController,
                decoration: const InputDecoration(
                  labelText: "Carrera del Solicitante",
                ),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: cantidadLibrosController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cantidad de Libros",
                ),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: numeroClasificadorController,
                decoration: const InputDecoration(
                  labelText: "Número del libro y clasificador",
                ),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: trabajadorController,
                decoration: const InputDecoration(labelText: "Trabajador"),
                validator:
                    (value) => value!.isEmpty ? 'Campo obligatorio' : null,
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
