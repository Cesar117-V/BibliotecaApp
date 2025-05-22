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

  final List<Widget> _views = const [
    ListaPrestamos(key: PageStorageKey('activos')),
    ListaPrestamosHistorial(key: PageStorageKey('historial')),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _views.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _activeIndex = _tabController.index;
        });
      }
    });
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EdicionPrestamo()),
          );
          setState(() {}); // recarga la pestaña activa
        },
        child: const Icon(Icons.add),
      );
    }
    return null; // no mostrar FAB en historial
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        color: Colors.grey[100],
        padding: const EdgeInsets.all(8),
        child: TabBarView(
          controller: _tabController,
          children: _views,
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}
