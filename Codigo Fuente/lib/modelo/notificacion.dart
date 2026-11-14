// /**
//  * Archivo/Clase : notificacion.dart / Notificacion
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelo de dominio que representa una alerta o notificación dirigida
//  *                 a un usuario específico dentro de la bandeja de notificaciones.
//  * Se vincula con: - USA: cloud_firestore (Timestamp, FieldValue).
//  *                 - ES USADO POR: NotificacionServicio (notificacion_servicio.dart),
//  *                   NotificacionVM (notificacion_vm.dart) y PantallaNotificaciones
//  *                   (pantalla_notificacion.dart).
//  * Funcionamiento: Mapea los documentos de la colección 'notificaciones' de Firestore,
//  *                 controlando el estado de lectura ('leido') y la marca de tiempo.
//  * Requerimiento : RF-07 (Enviar y recibir notificaciones push e internas)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';

/// Entidad que representa una notificación almacenada para un usuario en Firestore.
class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime? fecha;
  final String usuarioId;
  final String tipo;
  final bool leido;

  /// Crea una instancia de [Notificacion].
  ///
  /// - Parámetros: Identificador [id], contenido ([titulo], [mensaje]), destinatario
  ///   [usuarioId], categoría [tipo], marca temporal opcional [fecha] e indicador [leido].
  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.usuarioId,
    required this.tipo,
    this.fecha,
    this.leido = false,
  });

  /// Crea una instancia de [Notificacion] desde un documento de Cloud Firestore.
  ///
  /// - Parámetros: [id] ID del documento; [data] mapa de campos del documento.
  /// - Valor de retorno: Instancia de [Notificacion].
  /// - Efectos secundarios: Ninguno.
  factory Notificacion.fromMap(String id, Map<String, dynamic> data) {
    return Notificacion(
      id: id,
      titulo: data['titulo'] ?? '',
      mensaje: data['mensaje'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      tipo: data['tipo'] ?? '',
      leido: data['leido'] ?? false,
      fecha: (data['fecha'] is Timestamp)
          ? (data['fecha'] as Timestamp).toDate()
          : null,
    );
  }

  /// Serializa la notificación a un mapa clave-valor para su guardado en Firestore.
  ///
  /// - Parámetros: Ninguno.
  /// - Valor de retorno: `Map<String, dynamic>` con los campos de la notificación.
  /// - Efectos secundarios: Si [fecha] es nulo, asigna [FieldValue.serverTimestamp].
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'usuarioId': usuarioId,
      'tipo': tipo,
      'leido': leido,
      'fecha': fecha ?? FieldValue.serverTimestamp(),
    };
  }
}
