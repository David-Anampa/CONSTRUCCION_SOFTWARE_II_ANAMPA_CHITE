import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'servicios/firebase_availability.dart' as fb_avail;
import 'app.dart';

// 🔹 Importa el servicio TFLite
// import 'package:sos_mascotas/servicios/servicio_tflite.dart';

// Inicializa el plugin de notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 📨 Handler para mensajes recibidos en background (solo Android/iOS)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    "📩 Mensaje recibido en background: ${message.notification?.title}",
  );
}

// Nota: la disponibilidad se guarda en `lib/servicios/firebase_availability.dart`.

// =======================================================
// 🟢 FUNCIÓN: OPERACIONES DE RED DEPENDIENTES DE AUTENTICACIÓN
// =======================================================
Future<void> _runNetworkDependentTasks() async {
  // Si Firebase no quedó disponible (por ejemplo web sin config), no
  // ejecutar tareas de red que dependen de Firebase.
  if (!fb_avail.firebaseAvailable) return;

  // 🧩 Obtener el usuario actual
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // 🛑 ESTE BLOQUE SOLO SE EJECUTA SI EL USUARIO ESTÁ AUTENTICADO (LOGUEADO)

    // 1. Suscribirse al tema global "mascotas" (Requiere conexión y autenticación)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic("mascotas");
        debugPrint("✅ Suscrito al tema 'mascotas' (Usuario logueado)");
      } catch (e) {
        debugPrint(
          "⚠️ Error al suscribirse al tema 'mascotas' (Puede ser offline): $e",
        );
      }
    }

    // 2. Actualizar token FCM del usuario autenticado (Requiere conexión y autenticación)
    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({'token': token}, SetOptions(merge: true));
        debugPrint("✅ Token actualizado para ${user.email}");
      }
    } catch (e) {
      // Maneja errores de conexión sin bloquear la aplicación.
      debugPrint(
        "⚠️ Error al actualizar token en Firestore (Puede ser offline): $e",
      );
    }
  }
  // ⚠️ Si el usuario es null (no ha iniciado sesión), el código se salta,
  // previniendo la suscripción anónima.
}
// =======================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ✅ Inicializa Firebase
  // Esta operación es asíncrona pero puede fallar en plataformas que no
  // estén configuradas en `firebase_options.dart` (por ejemplo web/desktop
  // si no se generó la configuración). Capturamos errores y continuamos
  // para permitir ejecutar la app en modo offline/plataforma no soportada.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    fb_avail.firebaseAvailable = true;
  } on UnsupportedError catch (e) {
    // No hay configuración para esta plataforma en firebase_options.dart.
    debugPrint('⚠️ Firebase options unsupported for this platform: $e');
    // No forzamos la inicialización en web sin configuración; marcamos no disponible.
    fb_avail.firebaseAvailable = false;
    debugPrint('Continuando sin Firebase. Algunas funciones pueden no estar disponibles.');
  } catch (e) {
    debugPrint('⚠️ Error inicializando Firebase: $e');
    fb_avail.firebaseAvailable = false;
  }
  print("🚫 Firebase App Check desactivado para entorno de desarrollo.");

  // 2. 🔹 Inicializa modelos TFLite (Operación LOCAL)
  // Servicio local de TFLite no está presente en este workspace,
  // se omite la inicialización para evitar errores en desarrollo.

  // 3. 🔔 Configuración de notificaciones (Configuraciones LOCALES)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final messaging = FirebaseMessaging.instance;

    // Pedir permisos (No depende de la red)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '🔐 Permisos de notificaciones: ${settings.authorizationStatus}',
    );

    // Configuración local
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 🧠 Handler de mensajes
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Mensaje recibido: ${message.notification?.title}');
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Notificaciones SOS Mascota',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  } else {
    debugPrint("🌐 Modo Web: notificaciones locales deshabilitadas.");
  }

  // 4. ✅ Ejecutar la aplicación inmediatamente (Permite inicio OFFLINE)
  runApp(const MyApp());

  // 5. 🚀 Lanzar tareas de red en segundo plano (No bloquea el inicio)
  _runNetworkDependentTasks();
}
