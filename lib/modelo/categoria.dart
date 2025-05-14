class Categoria {
  int? id;
  String? nombre;

  // Constructor principal
  Categoria({this.id, this.nombre});

  // Constructor desde JSON
  Categoria.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre};
  }
}
