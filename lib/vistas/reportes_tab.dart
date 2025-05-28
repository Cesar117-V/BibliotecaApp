import 'package:flutter/material.dart';
import 'estadistica_prestamos.dart';
import 'deudores.dart';

class ReportesTab extends StatefulWidget {
  const ReportesTab({super.key});

  @override
  State<ReportesTab> createState() => _ReportesTabState();
}

class _ReportesTabState extends State<ReportesTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Reportes"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Estadística de Préstamos",
                icon: Icon(Icons.bar_chart),
              ),
              Tab(
                text: "Deudores de Préstamos",
                icon: Icon(Icons.warning_amber_rounded),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(8),
          child: const TabBarView(
            children: [
              EstadisticaPrestamos(),
              Deudores(),
            ],
          ),
        ),
      ),
    );
  }
}