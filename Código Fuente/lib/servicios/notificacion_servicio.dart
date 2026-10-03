import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sos_mascotas/modelo/notificacion.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacionServicio {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  /// ⚠️ RIESGO DE SEGURIDAD CRÍTICO:
  /// Las credenciales de Service Account NO deben incluirse en el APK/IPA
  /// porque pueden extraerse con herramientas de descompilación (apktool, jadx).
  /// La solución definitiva es mover el envío FCM a una Cloud Function de Firebase
  /// que corra con privilegios de servidor, y llamarla desde el cliente mediante HTTPS.
  /// Referencia: https://firebase.google.com/docs/cloud-messaging/server
  // TODO(security): Migrar enviarPush y enviarPushAUsuario a Cloud Functions.
  static const _jsonKeyPath = 'assets/keys/service_account.json';

  static FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Permite inyectar una instancia de [FirebaseFirestore] para pruebas unitarias.
  @visibleForTesting
  static void setFirestoreInstance(FirebaseFirestore firestore) {
    _db = firestore;
  }

  /// Persiste [notif] en la colección `notificaciones` de Firestore.
  ///
  /// Lanza [FirebaseException] si la escritura falla.
  static Future<void> guardarNotificacion(Notificacion notif) async {
    await _db.collection('notificaciones').add(notif.toMap());
  }

  /// Retorna un stream en tiempo real de notificaciones del usuario [usuarioId],
  /// ordenadas de la más reciente a la más antigua.
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

  /// Crea y retorna un cliente HTTP autenticado vía Service Account para la
  /// API v1 de FCM, junto a la URL del endpoint del proyecto.
  ///
  /// Lee las credenciales desde el asset [_jsonKeyPath].
  /// El caller es responsable de cerrar el cliente después de usarlo.
  static Future<({AutoRefreshingAuthClient client, String url})>
  _obtenerClienteFCM() async {
    final contenido = await rootBundle.loadString(_jsonKeyPath);
    final jsonKey = jsonDecode(contenido);
    final serviceAccount = ServiceAccountCredentials.fromJson(
      jsonEncode(jsonKey),
    );
    final client = await clientViaServiceAccount(serviceAccount, _scopes);
    final projectId = jsonKey['project_id'];
    final url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
    return (client: client, url: url);
  }

  /// 🔔 Enviar notificación global (a todos los usuarios suscritos al tema)
  ///
  /// Construye y envía una notificación FCM al topic `mascotas` y además
  /// guarda un registro en Firestore para cada usuario (excepto el emisor).
  /// No lanza; los errores se loguean internamente para no bloquear el flujo.
  static Future<void> enviarPush({
    required String titulo,
    required String cuerpo,
  }) async {
    try {
      final fcm = await _obtenerClienteFCM();

      final message = {
        "message": {
          "topic": "mascotas",
          "notification": {"title": titulo, "body": cuerpo},
        },
      };

      final response = await fcm.client.post(
        Uri.parse(fcm.url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(message),
      );

      debugPrint('📨 FCM respuesta: ${response.statusCode} → ${response.body}');
      fcm.client.close();

      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final usuariosSnap = await _db
          .collection('usuarios')
          .where(FieldPath.documentId, isNotEqualTo: currentUid)
          .get();

      final batch = _db.batch();

      // Guardar notificación para cada usuario que no sea el emisor.
      for (var usuario in usuariosSnap.docs) {
        batch.set(
          _db.collection('notificaciones').doc(),
          _buildNotifData(
            usuarioId: usuario.id,
            titulo: titulo,
            cuerpo: cuerpo,
          ),
        );
      }

      // Notificación de confirmación solo para el emisor.
      if (currentUid != null) {
        batch.set(
          _db.collection('notificaciones').doc(),
          _buildNotifData(
            usuarioId: currentUid,
            titulo: 'Se generó tu reporte',
            cuerpo: 'Tu reporte fue registrado correctamente 🐾',
          ),
        );
      }

      await batch.commit();
      debugPrint(
        '✅ Notificaciones registradas para ${usuariosSnap.docs.length + 1} usuarios.',
      );
    } catch (e) {
      debugPrint('❌ Error en enviarPush: $e');
    }
  }

  /// Envía una notificación push a un usuario específico por su [token] FCM,
  /// y guarda el registro en Firestore.
  ///
  /// Si [token] está vacío omite el push FCM pero sí persiste en Firestore.
  /// No lanza; los errores se loguean para no interrumpir el flujo del caller.
  static Future<void> enviarPushAUsuario({
    required String token,
    required String titulo,
    required String cuerpo,
    required String usuarioId,
    String tipo = '',
  }) async {
    try {
      // Persiste en Firestore independientemente del estado del token FCM.
      await _db
          .collection('notificaciones')
          .add(
            _buildNotifData(
              usuarioId: usuarioId,
              titulo: titulo,
              cuerpo: cuerpo,
              tipo: tipo,
            ),
          );
      debugPrint(
        '✅ Notificación individual guardada en Firestore para $usuarioId',
      );
    } catch (e) {
      debugPrint('❌ Error guardando notificación en Firestore: $e');
    }

    if (token.isEmpty) {
      debugPrint('ℹ️ Token de FCM vacío; omitiendo envío push.');
      return;
    }

    try {
      final fcm = await _obtenerClienteFCM();

      final message = {
        "message": {
          "token": token,
          "notification": {"title": titulo, "body": cuerpo},
        },
      };

      final response = await fcm.client.post(
        Uri.parse(fcm.url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(message),
      );

      debugPrint(
        '📩 Push individual enviado → ${response.statusCode}: ${response.body}',
      );
      fcm.client.close();
    } catch (e) {
      debugPrint('❌ Error enviando notificación individual FCM push: $e');
    }
  }

  /// Construye el mapa de datos de una notificación para Firestore.
  ///
  /// Fuente única del esquema de datos, usada tanto en [enviarPush]
  /// como en [enviarPushAUsuario] para garantizar consistencia de campos.
  static Map<String, dynamic> _buildNotifData({
    required String usuarioId,
    required String titulo,
    required String cuerpo,
    String tipo = '',
  }) {
    return {
      'usuarioId': usuarioId,
      'titulo': titulo,
      'mensaje': cuerpo,
      if (tipo.isNotEmpty) 'tipo': tipo,
      'fecha': FieldValue.serverTimestamp(),
      'leido': false,
    };
  }
}
