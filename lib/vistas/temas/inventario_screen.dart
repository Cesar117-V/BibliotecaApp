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

  final GlobalKey<ListaLibrosState> librosKey = GlobalKey<ListaLibrosState>();
  final GlobalKey<ListaCategoriasState> categoriasKey =
      GlobalKey<ListaCategoriasState>();
  final GlobalKey<ListaAutoresState> autoresKey =
      GlobalKey<ListaAutoresState>();

  late final List<Widget> _views = [
    ListaLibros(key: librosKey),
    ListaCategorias(key: categoriasKey),
    ListaAutores(key: autoresKey),
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
    return FloatingActionButton(
      onPressed: () async {
        bool? result;

        switch (_activeIndex) {
          case 0:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionLibro()),
            );
            if (result == true) {
              librosKey.currentState?.cargarDatos();
            }
            break;

          case 1:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionCategoria()),
            );
            if (result == true) {
              categoriasKey.currentState?.cargarDatos();
            }
            break;

          case 2:
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdicionAutor()),
            );
            if (result == true) {
              autoresKey.currentState?.cargarDatos();
            }
            break;
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
        child: IndexedStack(
          index: _activeIndex,
          children: _views,
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}
