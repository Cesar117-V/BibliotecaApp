class Autor {
  int? id;
  String? nombre;
  String? apellidos;
  String? correo;

  Autor({this.id, this.nombre, this.apellidos, this.correo});

  Autor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    apellidos = json['apellidos'];
    correo = json['correo'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
    };
  }
}
