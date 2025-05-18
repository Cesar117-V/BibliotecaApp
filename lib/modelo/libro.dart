class Libro {
  int? id;
  String? titulo;
  String? descripcion;
  String? imagen;
  int? idCategoria;
  int? numeroPaginas;
  int? idAutor;
  int? stock;

  // Constructor principal
  Libro({
    this.id,
    this.titulo,
    this.descripcion,
    this.imagen,
    this.idCategoria,
    this.numeroPaginas,
    this.idAutor,
    this.stock = 0,
  });

  // Constructor desde JSON
  Libro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titulo = json['titulo'];
    descripcion = json['descripcion'];
    imagen = json['imagen'];
    idCategoria = json['id_categoria'];
    numeroPaginas = json['numero_paginas'];
    idAutor = json['id_autor'];
    stock = json['stock'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagen': imagen,
      'id_categoria': idCategoria,
      'numero_paginas': numeroPaginas,
      'id_autor': idAutor,
      'stock': stock,
    };
  }
}
