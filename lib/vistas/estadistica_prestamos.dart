import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:flutter/rendering.dart';

class EstadisticaPrestamos extends StatefulWidget {
  const EstadisticaPrestamos({super.key});

  @override
  State<EstadisticaPrestamos> createState() => EstadisticaPrestamosState();
}

class EstadisticaPrestamosState extends State<EstadisticaPrestamos> {
  final GlobalKey _chartKey = GlobalKey();

  int _anio = DateTime.now().year;
  int _trimestre = 1;
  List<Map<String, dynamic>> _datos = [];
  int? _touchedGroupIndex;
  int? _touchedRodIndex;

  int get anio => _anio;
  int get trimestre => _trimestre;
  List<Map<String, dynamic>> get datos => _datos;
  List<String> get carreras => _carreras;
  List<String> get sexos => _sexos;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datosCargados = await Dao.prestamosPorTrimestreGeneroCarrera(
      year: _anio,
      trimestre: _trimestre,
    );
    setState(() {
      _datos = datosCargados;
      _touchedGroupIndex = null;
      _touchedRodIndex = null;
    });
  }

  List<String> get _carreras =>
      _datos.map((e) => e['carrera'] as String).toSet().toList();

  List<String> get _sexos =>
      _datos.map((e) => e['sexo'] as String).toSet().toList();

  List<BarChartGroupData> _crearBarGroups() {
    final carreras = _carreras;
    final sexos = _sexos;
    final colors = [Colors.pink, Colors.blue, Colors.green, Colors.orange];

    return List.generate(carreras.length, (i) {
      final carrera = carreras[i];
      return BarChartGroupData(
        x: i,
        barRods: List.generate(sexos.length, (j) {
          final sexo = sexos[j];
          final registro = _datos.firstWhere(
            (e) => e['carrera'] == carrera && e['sexo'] == sexo,
            orElse: () => {'cantidad': 0},
          );
          return BarChartRodData(
            toY: (registro['cantidad'] as int?)?.toDouble() ?? 0,
            color: colors[j % colors.length],
            width: 18,
            borderRadius: BorderRadius.circular(4),
          );
        }),
        showingTooltipIndicators: _touchedGroupIndex == i
            ? (_touchedRodIndex != null ? [_touchedRodIndex!] : [])
            : [],
      );
    });
  }

  Widget _buildLegend() {
    final sexos = _sexos;
    final colors = [Colors.pink, Colors.blue, Colors.green, Colors.orange];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      children: List.generate(sexos.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: colors[i % colors.length],
            ),
            const SizedBox(width: 4),
            Text(
              sexos[i] == 'M'
                  ? 'Masculino'
                  : sexos[i] == 'F'
                      ? 'Femenino'
                      : sexos[i],
            ),
          ],
        );
      }),
    );
  }

  /// Captura el gráfico como imagen PNG y devuelve un Uint8List.
  Future<Uint8List?> capturarGraficoComoImagen() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return capturarGraficoComoImagen();
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error al capturar el gráfico: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final carreras = _carreras;
    final sexos = _sexos;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 20,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Año: "),
                      DropdownButton<int>(
                        value: _anio,
                        items: List.generate(5, (i) {
                          final y = DateTime.now().year - i;
                          return DropdownMenuItem(value: y, child: Text("$y"));
                        }),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _anio = v;
                              _cargarDatos();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Trimestre: "),
                      DropdownButton<int>(
                        value: _trimestre,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text("Ene-Mar")),
                          DropdownMenuItem(value: 2, child: Text("Abr-Jun")),
                          DropdownMenuItem(value: 3, child: Text("Jul-Sep")),
                          DropdownMenuItem(value: 4, child: Text("Oct-Dic")),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _trimestre = v;
                              _cargarDatos();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _datos.isEmpty
                    ? const Center(child: Text("No hay datos para este periodo."))
                    : Column(
                        children: [
                          Expanded(
                            child: RepaintBoundary(
                              key: _chartKey,
                              child: BarChart(
                                BarChartData(
                                  barGroups: _crearBarGroups(),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      axisNameWidget: const Text(
                                        'Distribución de Préstamos por Género y Carrera',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      axisNameSize: 32,
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value % 1 == 0) {
                                            return Text(value.toInt().toString());
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      axisNameWidget: const Text(
                                        'Carreras',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      axisNameSize: 32,
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx >= 0 && idx < carreras.length) {
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                carreras[idx],
                                                style: TextStyle(
                                                  fontSize:
                                                      screenWidth < 350 ? 8 : 10,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor: Colors.black87,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        if (_touchedGroupIndex == groupIndex &&
                                            _touchedRodIndex == rodIndex) {
                                          final sexo = sexos[rodIndex];
                                          return BarTooltipItem(
                                            '${carreras[group.x.toInt()]}\n'
                                            '${sexo == 'M' ? 'Masculino' : sexo == 'F' ? 'Femenino' : sexo}: '
                                            '${rod.toY.toInt()}',
                                            const TextStyle(color: Colors.white),
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                    touchCallback: (event, response) {
                                      setState(() {
                                        if (event.isInterestedForInteractions &&
                                            response?.spot != null) {
                                          _touchedGroupIndex =
                                              response!.spot!.touchedBarGroupIndex;
                                          _touchedRodIndex =
                                              response.spot!.touchedRodDataIndex;
                                        } else {
                                          _touchedGroupIndex = null;
                                          _touchedRodIndex = null;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLegend(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}