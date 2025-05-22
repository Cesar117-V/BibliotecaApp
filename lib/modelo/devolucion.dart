class Devolucion {
  int? id;
  int idPrestamo;
  String fechaEntregaReal;
  String estadoLibro;
  String observaciones;
  String responsableDevolucion;

  Devolucion({
    this.id,
    required this.idPrestamo,
    required this.fechaEntregaReal,
    required this.estadoLibro,
    required this.observaciones,
    required this.responsableDevolucion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_prestamo': idPrestamo,
        'fecha_EntregaReal': fechaEntregaReal,
        'estado_libro': estadoLibro,
        'observaciones': observaciones,
        'responsable_devolucion': responsableDevolucion,
      };

  factory Devolucion.fromJson(Map<String, dynamic> json) => Devolucion(
        id: json['id'],
        idPrestamo: json['id_prestamo'],
        fechaEntregaReal: json['fecha_EntregaReal'],
        estadoLibro: json['estado_libro'],
        observaciones: json['observaciones'],
        responsableDevolucion: json['responsable_devolucion'].toString(),
      );
}
