import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio para enviar y gestionar notificaciones push (FCM) y en Firestore.
///
/// Archivo copiado íntegramente de:
/// [SosMascota/lib/servicios/notificacion_servicio.dart]
class NotificacionServicio {
  // Scopes requeridos por la API de FCM v1
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Ruta al archivo JSON de la cuenta de servicio (incluido como asset)
  static const _jsonKeyPath = 'assets/keys/service_account.json';

  // Referencia a la instancia de Firestore
  static final _db = FirebaseFirestore.instance;

  /// Envía una notificación global a todos los usuarios (excepto el emisor).
  ///
  /// Guarda las notificaciones en Firestore en batch para mayor eficiencia.
  static Future<void> enviarPush({
    required String titulo,
    required String cuerpo,
  }) async {
    try {
      // 1. Leer credenciales del archivo JSON de la cuenta de servicio
      final contenido = await rootBundle.loadString(_jsonKeyPath);
      final jsonKey = jsonDecode(contenido);
      print("✅ Credenciales cargadas ($_jsonKeyPath)");

      // 2. Crear cliente autorizado para FCM v1
      final serviceAccount = ServiceAccountCredentials.fromJson(
        jsonEncode(jsonKey),
      );
      final client = await clientViaServiceAccount(serviceAccount, _scopes);

      // 3. Construir y enviar mensaje al topic global "mascotas"
      final projectId = jsonKey['project_id'];
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final message = {
        "message": {
          "topic": "mascotas",
          "notification": {"title": titulo, "body": cuerpo},
        },
      };

      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(message),
      );

      print('📨 FCM respuesta: ${response.statusCode} → ${response.body}');
      client.close();

      // 4. Guardar notificaciones en Firestore (batch para eficiencia)
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final usuariosSnap = await _db
          .collection('usuarios')
          .where(FieldPath.documentId, isNotEqualTo: currentUid)
          .get();

      final batch = _db.batch();

      // Notificación para todos los demás usuarios
      for (var usuario in usuariosSnap.docs) {
        final ref = _db.collection('notificaciones').doc();
        batch.set(ref, {
          'usuarioId': usuario.id,
          'titulo': titulo,
          'mensaje': cuerpo,
          'fecha': FieldValue.serverTimestamp(),
          'leido': false,
        });
      }

      // Notificación local solo para el emisor (confirmación)
      if (currentUid != null) {
        final ref = _db.collection('notificaciones').doc();
        batch.set(ref, {
          'usuarioId': currentUid,
          'titulo': 'Se generó tu reporte',
          'mensaje': 'Tu reporte fue registrado correctamente 🐾',
          'fecha': FieldValue.serverTimestamp(),
          'leido': false,
        });
      }

      await batch.commit();
      print(
        "✅ Notificaciones registradas correctamente para ${usuariosSnap.docs.length + 1} usuarios.",
      );
    } catch (e) {
      print("❌ Error en enviarPush: $e");
    }
  }

  /// Envía una notificación push a un usuario específico (por token FCM).
  ///
  /// También guarda la notificación en Firestore para el historial del usuario.
  static Future<void> enviarPushAUsuario({
    required String token,
    required String titulo,
    required String cuerpo,
    required String usuarioId,
    String tipo = '',
  }) async {
    try {
      // Guardar notificación en Firestore (solo para el usuario destino)
      await _db.collection('notificaciones').add({
        'usuarioId': usuarioId,
        'titulo': titulo,
        'mensaje': cuerpo,
        'tipo': tipo,
        'fecha': FieldValue.serverTimestamp(),
        'leido': false,
      });
      print("✅ Notificación individual guardada en Firestore para $usuarioId");
    } catch (e) {
      print("❌ Error guardando notificación en Firestore: $e");
    }

    if (token.isEmpty) {
      print("ℹ️ Token de FCM vacío; omitiendo envío push.");
      return;
    }

    try {
      final contenido = await rootBundle.loadString(_jsonKeyPath);
      final jsonKey = jsonDecode(contenido);
      final serviceAccount = ServiceAccountCredentials.fromJson(
        jsonEncode(jsonKey),
      );
      final client = await clientViaServiceAccount(serviceAccount, _scopes);

      final projectId = jsonKey['project_id'];
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final message = {
        "message": {
          "token": token,
          "notification": {"title": titulo, "body": cuerpo},
        },
      };

      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(message),
      );

      print(
        '📩 Push individual enviado → ${response.statusCode}: ${response.body}',
      );
      client.close();
    } catch (e) {
      print("❌ Error enviando notificación individual FCM push: $e");
    }
  }
}
