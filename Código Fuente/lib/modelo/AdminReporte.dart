// modelo/AdminReporte.dart

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