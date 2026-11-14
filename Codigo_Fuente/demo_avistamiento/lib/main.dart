import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// CAMBIO: import original era 'firebase_options.dart' con paquete sos_mascotas
// Se usa la copia local de firebase_options en este proyecto:
import 'firebase_options.dart';
// CAMBIO: import original era parte de la app completa con login y navegación.
// En esta demo se entra directamente a la pantalla de avistamiento:
import 'vista/pantalla_avistamiento.dart';
// CAMBIO: import original inicializaba TFLite desde main.dart con un import
// 'package:sos_mascotas/servicios/servicio_tflite.dart'
// Se actualiza al nuevo nombre de paquete demo_avistamiento:
import 'servicios/servicio_tflite.dart';

// ─── NOTA SOBRE ESTA DEMO ────────────────────────────────────────────────────
// En el proyecto principal (SosMascota), antes de llegar a esta pantalla
// el usuario pasa por un flujo de autenticación (login/registro).
// Esta demo omite ese flujo y entra directamente al formulario de avistamiento.
// Para que funcione correctamente, el usuario debe estar previamente
// autenticado en Firebase (el SDK recuerda la sesión entre ejecuciones).
// ─────────────────────────────────────────────────────────────────────────────

/// Plugin de notificaciones locales (mismo que el proyecto principal).
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Handler para mensajes FCM recibidos en background.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    "📩 Mensaje recibido en background: ${message.notification?.title}",
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa Firebase con las mismas credenciales del proyecto principal
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inicializa modelos TFLite (operación LOCAL sobre assets)
  // Es crítico que no bloquee la app si falla la carga del archivo.
  try {
    await ServicioTFLite.inicializarModelos();
    debugPrint("✅ Modelos TFLite inicializados correctamente");
  } catch (e) {
    debugPrint("⚠️ Error al inicializar modelos TFLite: $e");
  }

  // 3. Configuración de notificaciones locales (solo móvil)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final messaging = FirebaseMessaging.instance;

    // Solicitar permisos de notificación al usuario
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '🔐 Permisos de notificaciones: ${settings.authorizationStatus}',
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Registrar handler de mensajes en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Mostrar notificación local cuando la app está en primer plano
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
              'Notificaciones Demo Avistamiento',
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

  // 4. Lanza la aplicación demo directamente en el formulario de avistamiento
  runApp(const DemoAvistamientoApp());
}

/// Aplicación raíz de la demo de avistamiento.
class DemoAvistamientoApp extends StatelessWidget {
  const DemoAvistamientoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Avistamiento — SOS Mascota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // La pantalla principal es directamente el formulario de avistamiento
      home: const PantallaAvistamiento(),
    );
  }
}
