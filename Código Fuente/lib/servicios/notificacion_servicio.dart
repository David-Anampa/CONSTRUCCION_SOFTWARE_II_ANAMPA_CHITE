import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sos_mascotas/modelo/notificacion.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacionServicio {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  static const _jsonKeyPath = 'assets/keys/service_account.json';
  static final _db = FirebaseFirestore.instance;

  /// ✅ Guardar notificación en Firestore
  static Future<void> guardarNotificacion(Notificacion notif) async {
    await _db.collection('notificaciones').add(notif.toMap());
  }

  /// ✅ Obtener notificaciones de un usuario en tiempo real
  static Stream<List<Notificacion>> obtenerNotificaciones(String usuarioId) {
    return _db
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Notificacion.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// 🔔 Enviar notificación global (solo a otros usuarios)
  static Future<void> enviarPush({
    required String titulo,
    required String cuerpo,
  }) async {
    try {
      // 1️⃣ Leer credenciales del archivo JSON
      final contenido = await rootBundle.loadString(_jsonKeyPath);
      final jsonKey = jsonDecode(contenido);
      print("✅ Credenciales cargadas ($_jsonKeyPath)");

      // 2️⃣ Crear cliente autorizado para FCM
      final serviceAccount = ServiceAccountCredentials.fromJson(
        jsonEncode(jsonKey),
      );
      final client = await clientViaServiceAccount(serviceAccount, _scopes);

      // 3️⃣ Configurar mensaje para el topic global
      final projectId = jsonKey['project_id'];
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final message = {
        "message": {
          "topic": "mascotas",
          "notification": {"title": titulo, "body": cuerpo},
        },
      };

      // 4️⃣ Enviar notificación FCM global
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(message),
      );

      print('📨 FCM respuesta: ${response.statusCode} → ${response.body}');
      client.close();

      // 5️⃣ Guardar las notificaciones en Firestore (de forma eficiente)
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final usuariosSnap = await _db
          .collection('usuarios')
          .where(FieldPath.documentId, isNotEqualTo: currentUid)
          .get();

      final batch = _db.batch();

      // 🔹 Notificaciones para todos los demás usuarios
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

      // 🔹 Notificación solo local para el emisor
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

  /// 🎯 Enviar notificación push a un usuario específico (por token)
  static Future<void> enviarPushAUsuario({
    required String token,
    required String titulo,
    required String cuerpo,
    required String usuarioId,
    String tipo = '',
  }) async {
    try {
      // 💾 Guardar notificación Firestore (solo para el usuario destino)
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
