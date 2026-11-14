/// Representa un avistamiento de mascota reportado por un usuario.
///
/// Un avistamiento puede estar vinculado a un reporte de mascota
/// perdida mediante [reporteId], lo que permite correlacionar ambos
/// registros cuando se detecta una posible coincidencia.
class Avistamiento {
  /// Identificador único del documento en Firestore.
  String id;

  /// ID del reporte de mascota perdida relacionado (opcional).
  /// Vacío si el avistamiento no fue vinculado a ningún reporte.
  String reporteId;

  /// UID del usuario autenticado que registró el avistamiento.
  String usuarioId;

  /// URL de la foto del avistamiento almacenada en Firebase Storage.
  String foto;

  /// Dirección textual del lugar donde se realizó el avistamiento.
  String direccion;

  /// Nombre del distrito donde ocurrió el avistamiento.
  String distrito;

  /// Latitud geográfica del punto de avistamiento.
  double? latitud;

  /// Longitud geográfica del punto de avistamiento.
  double? longitud;

  /// Fecha del avistamiento en formato `dd/MM/yyyy`.
  String fechaAvistamiento;

  /// Hora del avistamiento en formato `HH:mm`.
  String horaAvistamiento;

  /// Descripción textual libre del avistamiento escrita por el usuario.
  String descripcion;

  Avistamiento({
    this.id = "",
    this.reporteId = "",
    this.usuarioId = "",
    this.foto = "",
    this.direccion = "",
    this.distrito = "",
    this.latitud,
    this.longitud,
    this.fechaAvistamiento = "",
    this.horaAvistamiento = "",
    this.descripcion = "",
  });

  /// Convierte la instancia a un [Map] compatible con Firestore.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "reporteId": reporteId,
      "usuarioId": usuarioId,
      "foto": foto,
      "direccion": direccion,
      "distrito": distrito,
      "latitud": latitud,
      "longitud": longitud,
      "fechaAvistamiento": fechaAvistamiento,
      "horaAvistamiento": horaAvistamiento,
      "descripcion": descripcion,
    };
  }

  /// Crea una instancia de [Avistamiento] a partir de un [Map] de Firestore.
  ///
  /// Los campos ausentes se reemplazan por sus valores por defecto.
  factory Avistamiento.fromMap(Map<String, dynamic> map) {
    return Avistamiento(
      id: map["id"] ?? "",
      reporteId: map["reporteId"] ?? "",
      usuarioId: map["usuarioId"] ?? "",
      foto: map["foto"] ?? "",
      direccion: map["direccion"] ?? "",
      distrito: map["distrito"] ?? "",
      latitud: (map["latitud"] as num?)?.toDouble(),
      longitud: (map["longitud"] as num?)?.toDouble(),
      fechaAvistamiento: map["fechaAvistamiento"] ?? "",
      horaAvistamiento: map["horaAvistamiento"] ?? "",
      descripcion: map["descripcion"] ?? "",
    );
  }
}
