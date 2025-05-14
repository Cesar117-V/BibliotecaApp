class Autor {
  int? id;
  String? nombre;
  String? apellidos;
  String? correo;

  // Constructor principal
  Autor({this.id, this.nombre, this.apellidos, this.correo});

  // Constructor desde JSON
  Autor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    apellidos = json['apellidos'];
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
