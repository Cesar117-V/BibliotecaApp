import 'dart:io';
import 'package:biblioteca_app/vistas/temas/edicion_ejemplar.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/vistas/temas/edicion_libro.dart';

Future<bool> confirmarEliminacion(BuildContext context, String mensaje) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        ),
      ) ??
      false;
}

class ListaLibros extends StatefulWidget {
  const ListaLibros({Key? key}) : super(key: key);

  @override
  State<ListaLibros> createState() => ListaLibrosState();
}

class ListaLibrosState extends State<ListaLibros> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<Libro>> _librosAgrupados = {};
  Map<String, List<Libro>> _librosOriginales = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final libros = await Dao.listaLibros();
    final agrupados = <String, List<Libro>>{};

    for (var libro in libros) {
      final titulo = libro.titulo?.trim().isNotEmpty == true
          ? libro.titulo!
          : 'Sin título';
      agrupados.putIfAbsent(titulo, () => []).add(libro);
    }

    final agrupadosOrdenados = Map.fromEntries(
      agrupados.entries.toList()
        ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
    );

    if (!mounted) return;
    setState(() {
      _librosOriginales = agrupadosOrdenados;
      _librosAgrupados = agrupadosOrdenados;
    });
  }

  void _filtrarLibros(String query) {
    final resultado = <String, List<Libro>>{};
    _librosOriginales.forEach((titulo, listaLibros) {
      if (titulo.toLowerCase().contains(query.toLowerCase())) {
        resultado[titulo] = listaLibros;
      }
    });

    setState(() {
      _librosAgrupados = resultado;
    });
  }

  Future<void> _editarLibro([Libro? libro]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EdicionLibro(libro: libro)),
    );
    if (result == true && mounted) {
      await cargarDatos();
    }
  }

  void _mostrarFormularioNuevoEjemplar(String? titulo) {
    final paginasController = TextEditingController();
    final adquisicionController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo ejemplar"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: paginasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Número de páginas"),
            ),
            TextField(
              controller: adquisicionController,
              decoration: const InputDecoration(labelText: "No. Adquisición"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final paginas = int.tryParse(paginasController.text.trim());
              final adquisicion = adquisicionController.text.trim();

              if (paginas == null || adquisicion.isEmpty || titulo == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Todos los campos son obligatorios.")),
                );
                return;
              }

              final libroBase = _librosAgrupados[titulo]?.first;

              if (libroBase != null) {
                final nuevoLibro = Libro(
                  titulo: libroBase.titulo,
                  descripcion: libroBase.descripcion,
                  imagen: libroBase.imagen,
                  idCategoria: libroBase.idCategoria,
                  idAutor: libroBase.idAutor,
                  numeroPaginas: paginas,
                  stock: 1,
                  numAdquisicion: adquisicion,
                  cantidadEjemplares: 1,
                  disponible: true,
                );

                await Dao.createLibro(nuevoLibro);
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Cierra modal
                  await cargarDatos();
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _mostrarEjemplaresModal(List<Libro> libros) {
    final disponibles = libros.where((l) => l.disponible ?? true).toList();
    final tituloGrupo = libros.first.titulo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: disponibles.length,
                itemBuilder: (context, index) {
                  final libro = disponibles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: libro.imagen != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(libro.imagen!)))
                          : const CircleAvatar(child: Icon(Icons.book)),
                      title: Text("Páginas: ${libro.numeroPaginas ?? 0}"),
                      subtitle: libro.numAdquisicion?.isNotEmpty == true
                          ? Text("Adquisición: ${libro.numAdquisicion!}")
                          : null,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Editar ejemplar',
                            icon: const Icon(Icons.edit, color: Colors.amber),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EdicionEjemplar(libro: libro),
                                ),
                              );
                              if (result == true && mounted) {
                                Navigator.pop(context);
                                await cargarDatos();
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar ejemplar',
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmar = await confirmarEliminacion(
                                context,
                                "¿Deseas eliminar este ejemplar?",
                              );
                              if (confirmar) {
                                await Dao.deleteLibro(libro.id!);
                                Navigator.pop(context);
                                await cargarDatos();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon:
                    const Icon(Icons.add_circle, size: 48, color: Colors.blue),
                tooltip: 'Agregar ejemplar',
                onPressed: () => _mostrarFormularioNuevoEjemplar(tituloGrupo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            FocusScope.of(context).unfocus(); // Oculta teclado al hacer scroll
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 1,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: _filtrarLibros,
                  ),
                ),
                toolbarHeight: 70,
                pinned: false,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _librosAgrupados.entries.elementAt(index);
                    final titulo = entry.key;
                    final libros = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          "$titulo (${libros.where((l) => l.disponible ?? true).length} disponibles)",
                        ),
                        subtitle:
                            Text("Páginas: ${libros.first.numeroPaginas ?? 0}"),
                        leading: libros.first.imagen != null
                            ? CircleAvatar(
                                backgroundImage:
                                    FileImage(File(libros.first.imagen!)))
                            : const CircleAvatar(child: Icon(Icons.book)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              tooltip: 'Ver descripción',
                              onPressed: () {
                                final libro = libros.first;
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(libro.titulo ?? 'Sin título'),
                                    content: SingleChildScrollView(
                                      child: Text(
                                        libro.descripcion?.isNotEmpty == true
                                            ? libro.descripcion!
                                            : 'Este libro no tiene descripción.',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'Opciones',
                              onSelected: (value) async {
                                final libroBase = libros.first;

                                if (value == 'editar') {
                                  await _editarLibro(libroBase);
                                }

                                if (value == 'eliminar') {
                                  final confirmar = await confirmarEliminacion(
                                    context,
                                    "¿Deseas eliminar todos los ejemplares de \"$titulo\"?",
                                  );

                                  if (confirmar) {
                                    for (var libro in libros) {
                                      await Dao.deleteLibro(libro.id!);
                                    }
                                    if (mounted) await cargarDatos();
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: ListTile(
                                    leading:
                                        Icon(Icons.edit, color: Colors.amber),
                                    title: Text('Editar todos los ejemplares'),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: ListTile(
                                    leading:
                                        Icon(Icons.delete, color: Colors.red),
                                    title:
                                        Text('Eliminar todos los ejemplares'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _mostrarEjemplaresModal(libros),
                      ),
                    );
                  },
                  childCount: _librosAgrupados.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
