import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un comentario publicado sobre un reporte o avistamiento.
///
/// Los comentarios se almacenan como subcolección en Firestore bajo la ruta:
/// - `reportes_mascotas/{reporteId}/comentarios` (tipo reporte)
/// - `avistamientos/{reporteId}/comentarios`     (tipo avistamiento)
class Comentario {
  /// Identificador único del documento en Firestore.
  final String id;

  /// Contenido textual del comentario.
  final String texto;

  /// Nombre completo del autor del comentario.
  final String autor;

  /// UID del usuario autenticado que publicó el comentario.
  final String uid;

  /// Marca temporal del momento en que se creó el comentario.
  final DateTime fecha;

  /// URL del archivo multimedia adjunto (imagen), si existe.
  final String? mediaUrl;

  /// Tipo MIME del archivo multimedia (`'image'`, `'video'`, etc.).
  final String? mediaType;

  /// Lista de UIDs de usuarios que dieron "like" al comentario.
  final List<String> likes;

  /// Lista de UIDs de usuarios que dieron "dislike" al comentario.
  final List<String> dislikes;

  /// Número de veces que el comentario fue compartido.
  final int shares;

  const Comentario({
    required this.id,
    required this.texto,
    required this.autor,
    required this.uid,
    required this.fecha,
    this.mediaUrl,
    this.mediaType,
    required this.likes,
    required this.dislikes,
    required this.shares,
  });

  /// Crea un [Comentario] a partir del [id] del documento y su [data] de Firestore.
  factory Comentario.fromMap(String id, Map<String, dynamic> data) {
    return Comentario(
      id: id,
      texto: data['texto'] ?? '',
      autor: data['autor'] ?? 'Anónimo',
      uid: data['uid'] ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mediaUrl: data['mediaUrl'],
      mediaType: data['mediaType'],
      likes: List<String>.from(data['likes'] ?? []),
      dislikes: List<String>.from(data['dislikes'] ?? []),
      shares: data['shares'] ?? 0,
    );
  }

  /// Convierte la instancia a un [Map] listo para persistir en Firestore.
  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'autor': autor,
      'uid': uid,
      'fecha': fecha,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'likes': likes,
      'dislikes': dislikes,
      'shares': shares,
    };
  }
}
