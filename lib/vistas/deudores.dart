import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class Deudores extends StatefulWidget {
  const Deudores({super.key});

  @override
  // Cambia aquí: Quita el guion bajo
  State<Deudores> createState() => DeudoresState();
}

// Cambia aquí: Quita el guion bajo
class DeudoresState extends State<Deudores> {
  List<Map<String, dynamic>> _deudores = [];
  bool _isLoading = true;
  String? _error;

  // Getter público para que ReportesTab pueda acceder a la lista
  List<Map<String, dynamic>> get deudores => _deudores;

  @override
  void initState() {
    super.initState();
    _cargarDeudores();
  }

  Future<void> _cargarDeudores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final deudoresCargados = await Dao.obtenerDeudores();
      setState(() {
        _deudores = deudoresCargados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _deudores.isEmpty
                      ? const Center(child: Text('No hay usuarios deudores.'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth),
                                child: DataTable(
                                  columnSpacing: screenWidth * 0.05,
                                  columns: const [
                                    DataColumn(label: Text('Matrícula')),
                                    DataColumn(label: Text('Nombre')),
                                    DataColumn(label: Text('Carrera')),
                                  ],
                                  rows: _deudores.map((d) {
                                    return DataRow(cells: [
                                      DataCell(Text(d['matricula'] ?? '')),
                                      DataCell(
                                          Text(d['nombre_solicitante'] ?? '')),
                                      DataCell(Text(d['carrera'] ?? '')),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
