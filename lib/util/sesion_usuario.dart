class SesionUsuario {
  static String nombre = '';
  static String tipo = ''; // "admin", "bibliotecario", o "trabajador"
  static String correo = '';

  static void limpiar() {
    nombre = '';
    tipo = '';
    correo = '';
  }
}
