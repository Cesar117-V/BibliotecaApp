import 'package:flutter/material.dart';
import 'package:biblioteca_app/vistas/temas/home_page.dart';
import 'package:biblioteca_app/vistas/temas/home_bibliotecario.dart';
import 'package:biblioteca_app/modelo/database/dao.dart';
import 'package:biblioteca_app/util/sesion_usuario.dart'; // ✅ Importar la clase de sesión

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<bool> _seleccionTipo = [true, false]; // [Administrador, Bibliotecario]

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final tipoUsuario = _seleccionTipo[0] ? 'admin' : 'bibliotecario';

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (tipoUsuario == 'admin') {
      if (email == 'anet13@outlook.es' && password == 'Viri2152') {
        // ✅ Guardar datos del administrador
        SesionUsuario.nombre = 'Administrador';
        SesionUsuario.tipo = 'admin';
        SesionUsuario.correo = email;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña de administrador incorrectos'),
          ),
        );
      }
    } else {
      // ✅ Verificar bibliotecario
      final bibliotecario = await Dao.obtenerBibliotecario(email, password);
      if (bibliotecario != null) {
        SesionUsuario.nombre =
            '${bibliotecario.nombre} ${bibliotecario.apellidos}';
        SesionUsuario.tipo = 'bibliotecario';
        SesionUsuario.correo = bibliotecario.correo;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeBibliotecario()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Correo o código incorrecto para bibliotecario')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo_itch.jpg', height: 80),
                const SizedBox(height: 20),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ToggleButtons(
                  isSelected: _seleccionTipo,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _seleccionTipo.length; i++) {
                        _seleccionTipo[i] = i == index;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFF0D47A1),
                  color: Colors.black87,
                  constraints:
                      const BoxConstraints(minHeight: 40, minWidth: 140),
                  children: const [
                    Text("Administrador"),
                    Text("Bibliotecario"),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'usuario@ejemplo.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _seleccionTipo[0]
                        ? 'Contraseña'
                        : 'Código de 6 dígitos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: _seleccionTipo[0]
                      ? TextInputType.visiblePassword
                      : TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Recuperar acceso'),
                        content: const Text(
                          'Si olvidaste la contraseña del administrador, contacta al responsable del sistema.',
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
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
