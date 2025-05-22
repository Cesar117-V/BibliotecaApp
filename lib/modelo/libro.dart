class Libro {
  int? id;
  String? titulo;
  String? descripcion;
  String? imagen;
  int? idCategoria;
  int? numeroPaginas;
  int? idAutor;
  int? stock;
  String? numAdquisicion;
  int? cantidadEjemplares;
  bool? disponible;

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
    this.numAdquisicion,
    this.cantidadEjemplares,
    this.disponible = true, // por defecto disponible
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
    numAdquisicion = json['num_adquisicion'];
    cantidadEjemplares = json['cantidad_ejemplares'];
    disponible = json['disponible'] == 1;
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
      'num_adquisicion': numAdquisicion,
      'cantidad_ejemplares': cantidadEjemplares,
      'disponible': (disponible ?? true) ? 1 : 0,
    };
  }
}
