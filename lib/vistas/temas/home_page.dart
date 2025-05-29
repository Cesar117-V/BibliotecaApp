import 'package:flutter/material.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart';
import 'package:biblioteca_app/vistas/temas/inventario_screen.dart';
import 'package:biblioteca_app/vistas/temas/gestion_bibliotecarios.dart';
import 'package:biblioteca_app/vistas/temas/gestion_trabajadores.dart';
import 'package:biblioteca_app/vistas/temas/prestamos_tab_screen.dart';
import 'package:biblioteca_app/vistas/temas/edicion_devolucion.dart';
import 'package:biblioteca_app/vistas/reportes_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Biblioteca del Itch",
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
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _crearBoton(context, "Inventario", Icons.inventory, const InventarioScreen()),
              _crearBoton(context, "Gestión de Bibliotecarios", Icons.manage_accounts, const GestionBibliotecariosScreen()),
              _crearBoton(context, "Gestión de Trabajadores", Icons.people_alt, const GestionTrabajadoresScreen()),
              _crearBoton(context, "Préstamos", Icons.assignment_return, const PrestamosTabScreen()),
              _crearBoton(context, "Devoluciones", Icons.assignment_turned_in, const EdicionDevolucion()),
              _crearBoton(context, "Reportes", Icons.bar_chart, const ReportesTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearBoton(BuildContext context, String titulo, IconData icono, Widget pagina) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
