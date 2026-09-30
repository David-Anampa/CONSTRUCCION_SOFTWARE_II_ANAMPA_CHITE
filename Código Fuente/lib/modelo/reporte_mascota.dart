class ReporteMascota {
  String id;
  String nombre;
  String tipo;
  String raza;
  String caracteristicas;
  String fechaPerdida;
  String horaPerdida;
  String direccion;
  String distrito; // 🆕 nuevo campo
  double? latitud; // 🆕 nuevo campo
  double? longitud; // 🆕 nuevo campo
  String referencia;
  String circunstancia;
  String detalles;
  int recompensaPataCoins;
  // 🏆 Recompensa personal del dueño
  String montoRecompensa;   // ej. "S/. 200" o vacío si no ofrece
  List<String> fotos; // imágenes
  List<String> videos; // videos de máx 10 seg
  List<double> embedding; // 🧠 nuevo campo IA

  ReporteMascota({
    this.id = "",
    this.nombre = "",
    this.tipo = "",
    this.raza = "",
    this.caracteristicas = "",
    this.fechaPerdida = "",
    this.horaPerdida = "",
    this.direccion = "",
    this.distrito = "",
    this.latitud,
    this.longitud,
    this.referencia = "",
    this.circunstancia = "",
    this.detalles = "",
    this.recompensaPataCoins = 50,
    this.montoRecompensa = "",
    List<String>? fotos,
    List<String>? videos,
    List<double>? embedding,
  }) : embedding = embedding ?? [],
       fotos = fotos ?? [],
       videos = videos ?? [];

  // 🔧 Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "nombre": nombre,
      "tipo": tipo,
      "raza": raza,
      "caracteristicas": caracteristicas,
      "fechaPerdida": fechaPerdida,
      "horaPerdida": horaPerdida,
      "direccion": direccion,
      "distrito": distrito,
      "latitud": latitud,
      "longitud": longitud,
      "referencia": referencia,
      "circunstancia": circunstancia,
      "detalles": detalles,
      "recompensaPataCoins": recompensaPataCoins,
      "montoRecompensa": montoRecompensa,
      "fotos": fotos,
      "videos": videos,
      "embedding": embedding,
    };
  }

  // 🔧 Para leer desde Firestore
  factory ReporteMascota.fromMap(Map<String, dynamic> map) {
    return ReporteMascota(
      id: map["id"] ?? "",
      nombre: map["nombre"] ?? "",
      tipo: map["tipo"] ?? "",
      raza: map["raza"] ?? "",
      caracteristicas: map["caracteristicas"] ?? "",
      fechaPerdida: map["fechaPerdida"] ?? "",
      horaPerdida: map["horaPerdida"] ?? "",
      direccion: map["direccion"] ?? "",
      distrito: map["distrito"] ?? "",
      latitud: (map["latitud"] != null)
          ? (map["latitud"] as num).toDouble()
          : null,
      longitud: (map["longitud"] != null)
          ? (map["longitud"] as num).toDouble()
          : null,
      referencia: map["referencia"] ?? "",
      circunstancia: map["circunstancia"] ?? "",
      detalles: map["detalles"] ?? "",
      recompensaPataCoins: map["recompensaPataCoins"] ?? 50,
      montoRecompensa: map["montoRecompensa"] ?? "",
      fotos: List<String>.from(map["fotos"] ?? []),
      videos: List<String>.from(map["videos"] ?? []),
      embedding: List<double>.from(map["embedding"] ?? []),
    );
  }
}
