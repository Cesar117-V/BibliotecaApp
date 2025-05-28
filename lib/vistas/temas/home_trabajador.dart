import 'package:flutter/material.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart';
import 'package:biblioteca_app/vistas/temas/lista_prestamos_tab.dart';
import 'package:biblioteca_app/vistas/temas/inventario_screen.dart';
import 'package:biblioteca_app/vistas/temas/edicion_devolucion.dart';
import 'package:biblioteca_app/vistas/reportes_tab.dart';

class HomeTrabajador extends StatelessWidget {
  const HomeTrabajador({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biblioteca - Trabajador",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              SesionUsuario.nombre,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Cerrar sesión?'),
                  content:
                      const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(height: 40, color: Colors.grey.shade400), // Borde superior
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _crearBoton(context, "Préstamos", Icons.assignment_return,
                      const ListaPrestamosTab()),
                  _crearBoton(context, "Inventario", Icons.inventory_2,
                      const InventarioScreen()),
                  _crearBoton(context, "Devoluciones",
                      Icons.assignment_turned_in, const EdicionDevolucion()),
                  _crearBoton(context, "Reportes", Icons.bar_chart,
                      const ReportesTab()),
                ],
              ),
            ),
          ),
          Container(height: 40, color: Colors.grey.shade400), // Borde inferior
        ],
      ),
    );
  }

  Widget _crearBoton(
      BuildContext context, String titulo, IconData icono, Widget pagina) {
    return SizedBox(
      width: 220,
      height: 220,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 65, color: Colors.white),
            const SizedBox(height: 16),
            Text(titulo,
                style: const TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
