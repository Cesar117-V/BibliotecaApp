import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/lista_prestamos.dart';
import 'package:biblioteca_app/vistas/temas/lista_prestamos_historial.dart';
import 'package:biblioteca_app/vistas/temas/edicion_prestamo.dart';

class PrestamosTabScreen extends StatefulWidget {
  const PrestamosTabScreen({super.key});

  @override
  State<PrestamosTabScreen> createState() => _PrestamosTabScreenState();
}

class _PrestamosTabScreenState extends State<PrestamosTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;

  final GlobalKey<ListaPrestamosState> prestamosKey =
      GlobalKey<ListaPrestamosState>();

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _activeIndex = _tabController.index;
        });
      }
    });

    _views = [
      ListaPrestamos(key: prestamosKey),
      const ListaPrestamosHistorial(key: PageStorageKey('historial')),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _buildFloatingButton() {
    if (_activeIndex == 0) {
      return FloatingActionButton(
        heroTag: 'fabPrestamos',
        backgroundColor: Colors.purple.shade100,
        child: const Icon(Icons.add, color: Colors.deepPurple),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionPrestamo()),
          );
          if (result == true) {
            prestamosKey.currentState?.cargarDatos(); // ✅ recarga automática
          }
        },
      );
    }
    return null; // No mostrar FAB en historial
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text("Préstamos"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Activos'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: const Color(0xFFFFFCF7),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: TabBarView(
                controller: _tabController,
                children: _views,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}
