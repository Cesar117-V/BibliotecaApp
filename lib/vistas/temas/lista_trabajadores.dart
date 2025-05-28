import 'package:flutter/material.dart';
import 'package:biblioteca_app/modelo/trabajador.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';

class ListaTrabajadores extends StatefulWidget {
  const ListaTrabajadores({Key? key}) : super(key: key);

  @override
  State<ListaTrabajadores> createState() => _ListaTrabajadoresState();
}

class _ListaTrabajadoresState extends State<ListaTrabajadores> {
  List<Trabajador> trabajadores = [];

  @override
  void initState() {
    super.initState();
    _cargarTrabajadores();
  }

  Future<void> _cargarTrabajadores() async {
    final lista = await Dao.listaTrabajadores();
    setState(() {
      trabajadores = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Trabajadores'),
      ),
      body: trabajadores.isEmpty
          ? const Center(child: Text('No hay trabajadores registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trabajadores.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final t = trabajadores[index];
                return ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text('${t.nombre} ${t.apellidos}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correo: ${t.correo}'),
                      Text('Código: ${t.codigo}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
