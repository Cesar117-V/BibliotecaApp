class Libro {
  int? id;
  String? nombre;
  String? titulo;
  String? descripcion;
  String? imagen;
  int? idCategoria;
  int? numPaginas;
  int? idAutor;

  Libro({
    this.id,
    this.nombre,
    this.titulo,
    this.descripcion,
    this.imagen,
    this.idCategoria,
    this.numPaginas,
    this.idAutor,
  });

  Libro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    titulo = json['titulo'];
    descripcion = json['descripcion'];
    imagen = json['imagen'];
    idCategoria = json['id_categoria'];
    numPaginas = json['num_paginas'];
    idAutor = json['id_autor'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagen': imagen,
      'id_categoria': idCategoria,
      'num_paginas': numPaginas,
      'id_autor': idAutor,
    };
  }
}
