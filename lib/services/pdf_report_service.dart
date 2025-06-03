import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Colors;

class PdfReportService {
  // Función para calcular el ancho de cada columna según el texto más largo
  static Map<int, pw.TableColumnWidth> calcularAnchosColumnas(
      List<String> headers, List<List<dynamic>> data, double factor) {
    final Map<int, double> maxLengths = {};
    for (int col = 0; col < headers.length; col++) {
      int maxLen = headers[col].toString().length;
      for (var row in data) {
        if (col < row.length) {
          maxLen = row[col].toString().length > maxLen
              ? row[col].toString().length
              : maxLen;
        }
      }
      maxLengths[col] = maxLen * factor;
    }
    return maxLengths.map((k, v) => MapEntry(k, pw.FixedColumnWidth(v)));
  }

  static Future<Uint8List> generateEstadisticasPdf(
    int anio,
    int trimestre,
    List<Map<String, dynamic>> datos,
    List<String> carreras,
    List<String> sexos,
    Uint8List? graficoPng,
  ) async {
    final pdf = pw.Document();

    final colors = [
      PdfColor.fromInt(Colors.pink.value),
      PdfColor.fromInt(Colors.blue.value),
      PdfColor.fromInt(Colors.green.value),
      PdfColor.fromInt(Colors.orange.value)
    ];

    final headers = [
      'Carrera',
      ...sexos.map((s) => s == 'M'
          ? 'Masculino'
          : s == 'F'
              ? 'Femenino'
              : s)
    ];

    final data = List<List<dynamic>>.generate(
      carreras.length,
      (index) {
        final carrera = carreras[index];
        List<dynamic> row = [carrera];
        for (var sexo in sexos) {
          final cantidad = datos.firstWhere(
            (element) => element['carrera'] == carrera && element['sexo'] == sexo,
            orElse: () => {'cantidad': 0},
          )['cantidad'] as int;
          row.add(cantidad);
        }
        return row;
      },
    );

    // Reducción de ancho de columnas para formato vertical
    final columnWidths = calcularAnchosColumnas(headers, data, 4.0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4, // vertical
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Reporte de Estadísticas de Préstamos',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Año: $anio, Trimestre: $trimestre',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),

            // Tabla de Datos
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.blueGrey200),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 7),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
              columnWidths: columnWidths,
            ),
            pw.SizedBox(height: 16),

            if (graficoPng != null) ...[
              pw.Text(
                'Gráfico de barras',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Image(pw.MemoryImage(graficoPng), width: 250),
              ),
              pw.SizedBox(height: 8),
              // Leyenda debajo del gráfico
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Valores:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    spacing: 12,
                    children: List.generate(sexos.length, (i) {
                      final sexo = sexos[i];
                      return pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 5,
                            height: 5,
                            color: colors[i % colors.length],
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            sexo == 'M'
                                ? 'Masculino'
                                : sexo == 'F'
                                    ? 'Femenino'
                                    : sexo,
                            style: const pw.TextStyle(fontSize: 7),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ] else ...[
              pw.Text(
                '**Gráfico no disponible**',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
              pw.Text(
                'No se pudo capturar el gráfico como imagen. Solo se muestran los datos en formato tabular.',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateDeudoresPdf(
      List<Map<String, dynamic>> deudores) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4, // formato vertical
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Reporte de Deudores de Préstamos',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Fecha del Reporte: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 16),
            if (deudores.isEmpty)
              pw.Center(
                child: pw.Text(
                  'No hay deudores registrados en este momento.',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              )
            else
              pw.Table.fromTextArray(
                headers: ['Matrícula', 'Nombre Solicitante', 'Carrera'],
                data: List<List<dynamic>>.generate(
                  deudores.length,
                  (index) => [
                    deudores[index]['matricula'],
                    deudores[index]['nombre_solicitante'],
                    deudores[index]['carrera'],
                  ],
                ),
                border: pw.TableBorder.all(color: PdfColors.blueGrey200),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 7),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
              ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}