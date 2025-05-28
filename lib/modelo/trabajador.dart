class Trabajador {
  int? id;
  final String nombre;
  final String apellidos;
  final String correo;
  final String codigo;

  Trabajador({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.codigo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'correo': correo,
        'codigo': codigo,
      };

  factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
        id: json['id'],
        nombre: json['nombre'],
        apellidos: json['apellidos'],
        correo: json['correo'],
        codigo: json['codigo'],
      );
}
