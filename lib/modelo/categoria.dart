
class Categoria {
  int? id;
  String? nombre;
 
  Categoria({this.id, this.nombre});

  Categoria.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
   }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
