import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dominio que representa el reporte de una mascota perdida.
///
/// Contiene la información descriptiva del animal, coordenadas geográficas,
/// archivos multimedia y el vector de características (embeddings) para
/// comparación mediante visión computacional.
class ReporteMascota {
  String id;
  String usuarioId;
  String estado;
  DateTime? fechaRegistro;
  String nombre;
  String tipo;
  String raza;
  String caracteristicas;
  String fechaPerdida;
  String horaPerdida;
  String direccion;
  String distrito;
  double? latitud;
  double? longitud;
  String referencia;
  String circunstancia;
  String detalles;
  int recompensaPataCoins;
  String montoRecompensa;
  List<String> fotos;
  List<String> videos;
  List<double> embedding;

  ReporteMascota({
    this.id = "",
    this.usuarioId = "",
    this.estado = "Perdido",
    this.fechaRegistro,
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
      "usuarioId": usuarioId,
      "estado": estado,
      "fechaRegistro": fechaRegistro != null
          ? Timestamp.fromDate(fechaRegistro!)
          : null,
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
      usuarioId: map["usuarioId"] ?? "",
      estado: map["estado"] ?? "Perdido",
      fechaRegistro: map["fechaRegistro"] is Timestamp
          ? (map["fechaRegistro"] as Timestamp).toDate()
          : null,
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
