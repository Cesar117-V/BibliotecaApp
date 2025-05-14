class Prestamo {
  int? id;
  String matricula;
  String nombreSolicitante;
  String carrera;
  int cantidadLibros;
  String numeroClasificador;
  String trabajador;
  String? fechaPrestamo;
  String fechaDevolucion;
  String observaciones;

  Prestamo({
    this.id,
    required this.matricula,
    required this.nombreSolicitante,
    required this.carrera,
    required this.cantidadLibros,
    required this.numeroClasificador,
    required this.trabajador,
    this.fechaPrestamo,
    required this.fechaDevolucion,
    required this.observaciones,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'matricula': matricula,
    'nombre_solicitante': nombreSolicitante,
    'carrera': carrera,
    'cantidad_libros': cantidadLibros,
    'numero_clasificador': numeroClasificador,
    'trabajador': trabajador,
    'fecha_prestamo': fechaPrestamo,
    'fecha_devolucion': fechaDevolucion,
    'observaciones': observaciones,
  };

  factory Prestamo.fromJson(Map<String, dynamic> json) => Prestamo(
    id: json['id'],
    matricula: json['matricula'],
    nombreSolicitante: json['nombre_solicitante'],
    carrera: json['carrera'] ?? '',
    cantidadLibros: json['cantidad_libros'],
    numeroClasificador: json['numero_clasificador'] ?? '',
    trabajador: json['trabajador'],
    fechaPrestamo: json['fecha_prestamo'],
    fechaDevolucion: json['fecha_devolucion'],
    observaciones: json['observaciones'],
  );
}
