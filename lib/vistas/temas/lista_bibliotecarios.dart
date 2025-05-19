import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/bibliotecario.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class ListaBibliotecarios extends StatefulWidget {
  const ListaBibliotecarios({Key? key}) : super(key: key);

  @override
  State<ListaBibliotecarios> createState() => _ListaBibliotecariosState();
}

class _ListaBibliotecariosState extends State<ListaBibliotecarios> {
  List<Bibliotecario> bibliotecarios = [];

  @override
  void initState() {
    super.initState();
    _cargarBibliotecarios();
  }

  Future<void> _cargarBibliotecarios() async {
    final lista = await Dao.listaBibliotecarios();
    setState(() {
      bibliotecarios = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Bibliotecarios'),
      ),
      body: bibliotecarios.isEmpty
          ? const Center(child: Text('No hay bibliotecarios registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bibliotecarios.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final b = bibliotecarios[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${b.nombre} ${b.apellidos}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correo: ${b.correo}'),
                      Text('Código: ${b.codigo}'),
                      Text('Matrícula: ${b.matricula}'),
                      Text('Carrera: ${b.carrera}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
