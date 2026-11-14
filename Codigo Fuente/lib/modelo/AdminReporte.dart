// /**
//  * Archivo/Clase : AdminReporte.dart / AdminReporte, AdminAvistamiento
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelos de proyección administrativa para moderar reportes de mascotas
//  *                 perdidas y avistamientos enriquecidos con los datos del autor.
//  * Se vincula con: - USA: Tipos de Dart Core y conversión dinámica de Timestamp de Firestore.
//  *                 - ES USADO POR: AdminReportesVM (AdminReportes_vm.dart) y
//  *                   PantallaAdminReporte (pantallaAdminReporte.dart).
//  * Funcionamiento: Combina la información del documento de reporte o avistamiento con el
//  *                 nombre y correo del usuario creador para su auditoría y baja lógica.
//  * Requerimiento : RF-16 (Gestionar y moderar reportes y avistamientos como administrador)
//  */

// modelo/AdminReporte.dart

/// Proyección administrativa de un reporte de mascota perdida.
///
/// Incluye datos del animal, geolocalización, información del usuario creador
/// y el motivo de eliminación en caso de moderación.
class AdminReporte {
  String id;
  String nombre;
  String tipo;
  String raza;
  String estado;
  String direccion;
  String distrito;
  String fechaPerdida;
  String usuarioId;
  String nombreUsuario;
  String emailUsuario;
  List<String> fotos;
  double? latitud;
  double? longitud;
  DateTime? fechaRegistro;
  String motivoEliminacion;

  /// Crea una instancia de [AdminReporte] con valores predeterminados.
  AdminReporte({
    this.id = "",
    this.nombre = "",
    this.tipo = "",
    this.raza = "",
    this.estado = "PERDIDO",
    this.direccion = "",
    this.distrito = "",
    this.fechaPerdida = "",
    this.usuarioId = "",
    this.nombreUsuario = "",
    this.emailUsuario = "",
    List<String>? fotos,
    this.latitud,
    this.longitud,
    this.fechaRegistro,
    this.motivoEliminacion = "",
  }) : fotos = fotos ?? [];

  /// Construye un [AdminReporte] a partir del mapa [map] de Firestore y su [docId].
  ///
  /// - Parámetros: [map] datos del documento en `reportes_mascotas`; [docId] ID del documento.
  /// - Valor de retorno: Instancia de [AdminReporte] con el estado normalizado en mayúsculas.
  /// - Errores: Puede lanzar [NoSuchMethodError] si `fechaRegistro` no implementa `.toDate()`.
  factory AdminReporte.fromMap(Map<String, dynamic> map, String docId) {
    return AdminReporte(
      id: docId,
      nombre: map["nombre"] ?? "",
      tipo: map["tipo"] ?? "",
      raza: map["raza"] ?? "",
      estado: (map["estado"] ?? "PERDIDO").toString().toUpperCase(),
      direccion: map["direccion"] ?? "",
      distrito: map["distrito"] ?? "",
      fechaPerdida: map["fechaPerdida"] ?? "",
      usuarioId: map["usuarioId"] ?? "",
      nombreUsuario: map["nombreUsuario"] ?? "",
      emailUsuario: map["emailUsuario"] ?? "",
      fotos: List<String>.from(map["fotos"] ?? []),
      latitud: (map["latitud"] as num?)?.toDouble(),
      longitud: (map["longitud"] as num?)?.toDouble(),
      fechaRegistro: map["fechaRegistro"] != null
          ? (map["fechaRegistro"] as dynamic).toDate()
          : null,
    );
  }
}

/// Proyección administrativa de un avistamiento registrado por un ciudadano.
///
/// Agrega los datos de contacto del autor y soporte para registrar el motivo de baja.
class AdminAvistamiento {
  String id;
  String descripcion;
  String estado;
  String direccion;
  String distrito;
  String fechaAvistamiento;
  String usuarioId;
  String nombreUsuario;
  String emailUsuario;
  String foto;
  String? reporteId;
  double? latitud;
  double? longitud;
  DateTime? fechaRegistro;
  String motivoEliminacion;

  /// Crea una instancia de [AdminAvistamiento] con valores iniciales por defecto.
  AdminAvistamiento({
    this.id = "",
    this.descripcion = "",
    this.estado = "AVISTADO",
    this.direccion = "",
    this.distrito = "",
    this.fechaAvistamiento = "",
    this.usuarioId = "",
    this.nombreUsuario = "",
    this.emailUsuario = "",
    this.foto = "",
    this.reporteId,
    this.latitud,
    this.longitud,
    this.fechaRegistro,
    this.motivoEliminacion = "",
  });

  /// Construye un [AdminAvistamiento] a partir de un documento de la colección `avistamientos`.
  ///
  /// - Parámetros: [map] datos del documento; [docId] identificador único en Firestore.
  /// - Valor de retorno: Instancia de [AdminAvistamiento] con el estado en mayúsculas.
  factory AdminAvistamiento.fromMap(Map<String, dynamic> map, String docId) {
    return AdminAvistamiento(
      id: docId,
      descripcion: map["descripcion"] ?? "",
      estado: (map["estado"] ?? "AVISTADO").toString().toUpperCase(),
      direccion: map["direccion"] ?? "",
      distrito: map["distrito"] ?? "",
      fechaAvistamiento: map["fechaAvistamiento"] ?? "",
      usuarioId: map["usuarioId"] ?? "",
      nombreUsuario: map["nombreUsuario"] ?? "",
      emailUsuario: map["emailUsuario"] ?? "",
      foto: map["foto"] ?? "",
      reporteId: map["reporteId"],
      latitud: (map["latitud"] as num?)?.toDouble(),
      longitud: (map["longitud"] as num?)?.toDouble(),
      fechaRegistro: map["fechaRegistro"] != null
          ? (map["fechaRegistro"] as dynamic).toDate()
          : null,
    );
  }
}