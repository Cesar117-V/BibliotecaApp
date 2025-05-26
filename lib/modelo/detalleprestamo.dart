class DetallePrestamo {
  int? id;
  int idPrestamo;
  int idLibro;
  String titulo;
  String noAdquisicion;
  String categoria;
  String autor;

  DetallePrestamo({
    this.id,
    required this.idPrestamo,
    required this.idLibro,
    required this.titulo,
    required this.noAdquisicion,
    required this.categoria,
    required this.autor,
  });

  factory DetallePrestamo.fromJson(Map<String, dynamic> json) {
    return DetallePrestamo(
      id: json['id'],
      idPrestamo: json['id_prestamo'],
      idLibro: json['id_libro'],
      titulo: json['titulo'],
      noAdquisicion: json['no_adquisicion'],
      categoria: json['categoria'],
      autor: json['autor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_prestamo': idPrestamo,
      'id_libro': idLibro,
      'titulo': titulo,
      'no_adquisicion': noAdquisicion,
      'categoria': categoria,
      'autor': autor,
    };
  }
}
