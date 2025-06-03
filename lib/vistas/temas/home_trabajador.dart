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
        backgroundColor: const Color(0xFF0D47A1),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: const [
              BotonAnimado(
                titulo: "Préstamos",
                icono: Icons.assignment_return,
                pagina: ListaPrestamosTab(),
              ),
              BotonAnimado(
                titulo: "Inventario",
                icono: Icons.inventory_2,
                pagina: InventarioScreen(),
              ),
              BotonAnimado(
                titulo: "Devoluciones",
                icono: Icons.assignment_turned_in,
                pagina: EdicionDevolucion(),
              ),
              BotonAnimado(
                titulo: "Reportes",
                icono: Icons.bar_chart,
                pagina: ReportesTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotonAnimado extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final Widget pagina;

  const BotonAnimado({
    Key? key,
    required this.titulo,
    required this.icono,
    required this.pagina,
  }) : super(key: key);

  @override
  State<BotonAnimado> createState() => _BotonAnimadoState();
}

class _BotonAnimadoState extends State<BotonAnimado> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: _hover ? Colors.blue.shade800 : Colors.blue.shade700,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget.pagina),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icono, size: 60, color: Colors.white),
                const SizedBox(height: 14),
                Text(
                  widget.titulo,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
