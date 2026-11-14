// /**
//  * Archivo/Clase : comentario_model.dart / Comentario
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelo de dominio para los comentarios comunitarios, adjuntos multimedia
//  *                 y contadores de interacción social (likes, dislikes, shares).
//  * Se vincula con: - USA: cloud_firestore (Timestamp).
//  *                 - ES USADO POR: ComentariosViewModel (comentarios_viewmodel.dart),
//  *                   PantallaComentarios (pantalla_comentarios.dart), RepliesPage (replies_page.dart)
//  *                   y pruebas unitarias RF-12 (rf12_comentarios_test.dart).
//  * Funcionamiento: Serializa y deserializa documentos de la colección 'comentarios' y
//  *                 subcolecciones asociadas a reportes y avistamientos.
//  * Requerimiento : RF-12 (Agregar comentarios y reacciones en reportes/comunidad)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un comentario publicado por un usuario en el muro comunitario o en un reporte.
///
/// Incluye metadatos del autor, contenido textual, recurso multimedia opcional
/// y listas de UIDs para el control de reacciones (me gusta / no me gusta).
class Comentario {
  final String id;
  final String texto;
  final String autor;
  final String uid;
  final DateTime fecha;
  final String? mediaUrl;
  final String? mediaType;
  final List<String> likes;
  final List<String> dislikes;
  final int shares;

  /// Crea una instancia inmutable de [Comentario].
  ///
  /// - Parámetros: Identificador [id], contenido [texto], datos del emisor ([autor], [uid]),
  ///   marca temporal [fecha], adjunto opcional ([mediaUrl], [mediaType]) y métricas de
  ///   interacción ([likes], [dislikes], [shares]).
  Comentario({
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

  /// Reconstruye un [Comentario] a partir de su [id] de documento y el mapa [data] de Firestore.
  ///
  /// - Parámetros: [id] identificador del documento; [data] campos almacenados en Firestore.
  /// - Valor de retorno: Instancia de [Comentario] con valores por defecto (`Anónimo`, listas vacías).
  /// - Efectos secundarios: Si `fecha` es nulo, asigna `DateTime.now()`.
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

  /// Convierte la instancia de [Comentario] en un mapa clave-valor para Firestore.
  ///
  /// - Parámetros: Ninguno.
  /// - Valor de retorno: `Map<String, dynamic>` listo para persistencia.
  /// - Efectos secundarios: Ninguno.
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
