// /**
//  * Archivo/Clase : avistamiento.dart / Avistamiento
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelo de dominio que representa el avistamiento ciudadano de una
//  *                 mascota en la vía pública y su posible vínculo con un reporte activo.
//  * Se vincula con: - USA: Tipos primitivos de Dart Core.
//  *                 - ES USADO POR: AvistamientoVM (avistamiento_vm.dart),
//  *                   pruebas unitarias RF-05 (rf05_avistamiento_test.dart y avistamiento_vm_test.dart).
//  * Funcionamiento: Encapsula la fotografía, dirección, coordenadas geográficas y descripción
//  *                 del avistamiento para persistirlos en la colección 'avistamientos'.
//  * Requerimiento : RF-05 (Registrar avistamiento y emparejamiento inteligente)
//  */

/// Modelo de dominio que representa el avistamiento público de una mascota en la calle.
///
/// Permite alertar a la comunidad y vincular potencialmente la ubicación
/// con un reporte de mascota perdida previamente registrado.
class Avistamiento {
  String id;
  String reporteId;
  String usuarioId;
  String foto;
  String direccion;
  String distrito;
  double? latitud;
  double? longitud;
  String fechaAvistamiento;
  String horaAvistamiento;
  String descripcion;

  /// Crea una instancia de [Avistamiento] con valores iniciales vacíos por defecto.
  ///
  /// - Parámetros: Identificadores ([id], [reporteId], [usuarioId]), evidencia
  ///   ([foto], [descripcion]) y geolocalización ([direccion], [distrito], [latitud], [longitud]).
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

  /// Convierte el avistamiento en un mapa clave-valor para su almacenamiento en Firestore.
  ///
  /// - Parámetros: Ninguno.
  /// - Valor de retorno: `Map<String, dynamic>` con las propiedades del avistamiento.
  /// - Efectos secundarios: Ninguno.
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

  /// Crea una instancia de [Avistamiento] a partir de un mapa proveniente de Firestore.
  ///
  /// - Parámetros: [map] diccionario de campos leído de la colección `avistamientos`.
  /// - Valor de retorno: Instancia de [Avistamiento] hidratada.
  /// - Efectos secundarios: Ninguno.
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
