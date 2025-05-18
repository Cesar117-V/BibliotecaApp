import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/listas_libros.dart';
import 'package:biblioteca_app/vistas/temas/lista_categorias.dart';
import 'package:biblioteca_app/vistas/temas/lista_autores.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';
import 'package:biblioteca_app/vistas/temas/edicion_categoria.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;

  final List<Widget> _views = const [
    ListaLibros(key: PageStorageKey('libros')),
    ListaCategorias(key: PageStorageKey('categorias')),
    ListaAutores(key: PageStorageKey('autores')),
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

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _views[_activeIndex],
    );
  }

  Widget? _buildFloatingButton() {
    switch (_activeIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionLibro()),
            );
            setState(() {});
          },
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionCategoria()),
            );
            setState(() {});
          },
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionAutor()),
            );
            setState(() {});
          },
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Libros'),
            Tab(icon: Icon(Icons.category), text: 'Categorías'),
            Tab(icon: Icon(Icons.person), text: 'Autores'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(8),
        child: _buildTabContent(),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}
