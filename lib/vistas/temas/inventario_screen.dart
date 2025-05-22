import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/listas_libros.dart';
import 'package:biblioteca_app/vistas/temas/lista_categorias.dart';
import 'package:biblioteca_app/vistas/temas/lista_autores.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';
import 'package:biblioteca_app/vistas/temas/edicion_categoria.dart';
import 'package:biblioteca_app/vistas/temas/edicion_autor.dart';
import 'package:biblioteca_app/vistas/temas/lista_devoluciones.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeIndex = 0;

  final GlobalKey<ListaLibrosState> librosKey = GlobalKey<ListaLibrosState>();

  late final List<Widget> _views = [
    ListaLibros(key: librosKey),
    const ListaCategorias(key: PageStorageKey('categorias')),
    const ListaAutores(key: PageStorageKey('autores')),
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
    return FloatingActionButton(
      onPressed: () async {
        bool? result;

        switch (_activeIndex) {
          case 0:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionLibro()),
            );
            break;
          case 1:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionCategoria()),
            );
            break;
          case 2:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionAutor()),
            );
            break;
        }

        if (result == true) {
          setState(() {}); // Refresca la vista activa
          if (_activeIndex == 0) {
            librosKey.currentState
                ?.cargarLibros(); // Asegúrate de que sea pública
          }
        }
      },
      child: const Icon(Icons.add),
    );
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
