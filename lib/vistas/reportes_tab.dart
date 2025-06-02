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
          backgroundColor: const Color(0xFF0D47A1),
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: TabBarView(
                  children: [
                    EstadisticaPrestamos(),
                    Deudores(),
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
