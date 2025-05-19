class Bibliotecario {
  int? id;
  final String nombre;
  final String apellidos;
  final String matricula;
  final String carrera;
  final String correo;
  final String codigo;

  Bibliotecario({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.matricula,
    required this.carrera,
    required this.correo,
    required this.codigo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'matricula': matricula,
        'carrera': carrera,
        'correo': correo,
        'codigo': codigo,
      };

  factory Bibliotecario.fromJson(Map<String, dynamic> json) => Bibliotecario(
        id: json['id'],
        nombre: json['nombre'],
        apellidos: json['apellidos'],
        matricula: json['matricula'],
        carrera: json['carrera'],
        correo: json['correo'],
        codigo: json['codigo'],
      );
}
