import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class Deudores extends StatefulWidget {
  const Deudores({super.key});

  @override
  State<Deudores> createState() => _DeudoresState();
}

class _DeudoresState extends State<Deudores> {
  late Future<List<Map<String, dynamic>>> _futureDeudores;

  @override
  void initState() {
    super.initState();
    _futureDeudores = Dao.obtenerDeudores();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureDeudores,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final deudores = snapshot.data ?? [];

              if (deudores.isEmpty) {
                return const Center(child: Text('No hay usuarios deudores.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: screenWidth * 0.05,
                        columns: const [
                          DataColumn(label: Text('Matrícula')),
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Carrera')),
                        ],
                        rows: deudores.map((d) {
                          return DataRow(cells: [
                            DataCell(Text(d['matricula'] ?? '')),
                            DataCell(Text(d['nombre_solicitante'] ?? '')),
                            DataCell(Text(d['carrera'] ?? '')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
