import 'dart:io';
import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/libro.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/modelo/categoria.dart';

class SeleccionLibrosScreen extends StatefulWidget {
  final int cantidadMaxima;
  final List<Libro> librosPreseleccionados;
  final Map<int, String> mapAutores;
  final Map<int, String> mapCategorias;

  const SeleccionLibrosScreen({
    Key? key,
    required this.cantidadMaxima,
    this.librosPreseleccionados = const [],
    required this.mapAutores,
    required this.mapCategorias,
  }) : super(key: key);

  @override
  State<SeleccionLibrosScreen> createState() => _SeleccionLibrosScreenState();
}

class _SeleccionLibrosScreenState extends State<SeleccionLibrosScreen> {
  Map<String, List<Libro>> _librosAgrupados = {};
  List<Categoria> _categorias = [];
  String _busqueda = '';
  String _categoriaSeleccionada = 'Todas';
  List<Libro> seleccionados = [];
  Set<String> panelesAbiertos = {};

  @override
  void initState() {
    super.initState();
    seleccionados = List.from(widget.librosPreseleccionados);
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final libros = await Dao.listaLibros();
    final categorias = await Dao.listaCategorias();
    final agrupados = <String, List<Libro>>{};

    for (var libro in libros) {
      final titulo = (libro.titulo?.trim().isNotEmpty == true) ? libro.titulo! : 'Sin título';
      agrupados.putIfAbsent(titulo, () => []).add(libro);
    }

    setState(() {
      _librosAgrupados = agrupados;
      _categorias = [Categoria(id: -1, nombre: 'Todas'), ...categorias];
      _categoriaSeleccionada = 'Todas';
    });
  }

  @override
  Widget build(BuildContext context) {
    final librosFiltradosAgrupados = _librosAgrupados.entries.where((entry) {
      final tituloCoincide = entry.key.toLowerCase().contains(_busqueda.toLowerCase());
      final categoriaCoincide = _categoriaSeleccionada == 'Todas' ||
          entry.value.any((l) => widget.mapCategorias[l.idCategoria] == _categoriaSeleccionada);
      return tituloCoincide && categoriaCoincide;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 81, 87, 200),
        title: const Text("Seleccionar Libros", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar por título",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria.nombre,
                  child: Text(categoria.nombre!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Filtrar por categoría",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: librosFiltradosAgrupados.isEmpty
                ? const Center(child: Text("No hay libros para mostrar"))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: librosFiltradosAgrupados.map((entry) {
                      final titulo = entry.key;
                      final ejemplares = entry.value;
                      final abierto = panelesAbiertos.contains(titulo);

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          key: PageStorageKey(titulo),
                          title: Text(
                            "$titulo (${ejemplares.where((l) => l.disponible ?? true).length} disponibles)",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          initiallyExpanded: abierto,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              if (expanded) {
                                panelesAbiertos.add(titulo);
                              } else {
                                panelesAbiertos.remove(titulo);
                              }
                            });
                          },
                          children: ejemplares.map((libro) {
                            final yaSeleccionado = seleccionados.contains(libro);
                            final esDisponible = libro.disponible == true;

                            return IgnorePointer(
                              ignoring: !esDisponible,
                              child: Opacity(
                                opacity: esDisponible ? 1.0 : 0.4,
                                child: ListTile(
                                  leading: (libro.imagen != null && File(libro.imagen!).existsSync())
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(libro.imagen!),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const CircleAvatar(
                                          backgroundColor: Color(0xFFE0E0E0),
                                          child: Icon(Icons.book, color: Colors.black54),
                                        ),
                                  title: Text(
                                    "Adquisición: ${libro.numAdquisicion ?? ''}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Autor: ${widget.mapAutores[libro.idAutor] ?? 'Desconocido'}'),
                                      Text('Categoría: ${widget.mapCategorias[libro.idCategoria] ?? 'Sin categoría'}'),
                                      Text(libro.disponible == true ? 'Disponible' : 'No disponible',
                                          style: TextStyle(
                                            color: libro.disponible == true ? Colors.green : Colors.red,
                                          )),
                                    ],
                                  ),
                                  trailing: Checkbox(
                                    value: yaSeleccionado,
                                    onChanged: (checked) {
                                      if (!esDisponible) return;
                                      setState(() {
                                        if (checked == true) {
                                          if (seleccionados.length < widget.cantidadMaxima) {
                                            seleccionados.add(libro);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Ya no puedes seleccionar más libros'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
                                        } else {
                                          seleccionados.remove(libro);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    if (!esDisponible) return;
                                    setState(() {
                                      if (!yaSeleccionado) {
                                        if (seleccionados.length < widget.cantidadMaxima) {
                                          seleccionados.add(libro);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Ya no puedes seleccionar más libros'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      } else {
                                        seleccionados.remove(libro);
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 81, 87, 200),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () {
                if (seleccionados.length != widget.cantidadMaxima) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Debes seleccionar exactamente ${widget.cantidadMaxima} libros.')),
                  );
                  return;
                }
                Navigator.pop(context, seleccionados);
              },
              child: const Text('Finalizar selección'),
            ),
          ),
        ],
      ),
    );
  }
}
