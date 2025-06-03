import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'estadistica_prestamos.dart';
import 'deudores.dart';
import 'package:biblioteca_app/services/pdf_report_service.dart';
import 'package:printing/printing.dart';

class ReportesTab extends StatefulWidget {
  const ReportesTab({super.key});

  @override
  State<ReportesTab> createState() => _ReportesTabState();
}

class _ReportesTabState extends State<ReportesTab> {
  final GlobalKey<EstadisticaPrestamosState> _estadisticaKey = GlobalKey();
  final GlobalKey<DeudoresState> _deudoresKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF0D47A1),
              title: const Text("Reportes"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  tooltip: "Generar PDF del reporte actual",
                  onPressed: () async {
                    final int currentIndex = tabController.index;
                    if (currentIndex == 0) {
                      await _generateEstadisticaReport();
                    } else if (currentIndex == 1) {
                      await _generateDeudoresReport();
                    }
                  },
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    icon: Icon(Icons.bar_chart, color: Colors.white),
                    child: Text(
                      "Estadísticas de Préstamos",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
                    child: Text(
                      "Deudores de Préstamos",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            body: Container(
              color: const Color(0xFFF0F2F5),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFFFFFCF7),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TabBarView(
                      children: [
                        EstadisticaPrestamos(key: _estadisticaKey),
                        Deudores(key: _deudoresKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _generateEstadisticaReport() async {
    final estadisticaState = _estadisticaKey.currentState;
    if (estadisticaState != null) {
      final anio = estadisticaState.anio;
      final trimestre = estadisticaState.trimestre;
      final datos = estadisticaState.datos;
      final carreras = estadisticaState.carreras;
      final sexos = estadisticaState.sexos;

      if (datos.isEmpty) {
        _showSnackbar('No hay datos para generar el reporte de estadísticas.');
        return;
      }

      // Captura el gráfico como imagen PNG
      final Uint8List? graficoPng = await estadisticaState.capturarGraficoComoImagen();

      final pdfBytes = await PdfReportService.generateEstadisticasPdf(
        anio, trimestre, datos, carreras, sexos, graficoPng
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'reporte_estadisticas_prestamos.pdf',
      );
    } else {
      _showSnackbar('Cargando datos de estadísticas. Intenta de nuevo.');
    }
  }

  Future<void> _generateDeudoresReport() async {
    final deudoresState = _deudoresKey.currentState;
    if (deudoresState != null) {
      final deudores = deudoresState.deudores;

      if (deudores.isEmpty) {
        _showSnackbar('No hay deudores para generar el reporte.');
        return;
      }

      final pdfBytes = await PdfReportService.generateDeudoresPdf(deudores);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'reporte_deudores.pdf',
      );
    } else {
      _showSnackbar('Cargando datos de deudores. Intenta de nuevo.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}