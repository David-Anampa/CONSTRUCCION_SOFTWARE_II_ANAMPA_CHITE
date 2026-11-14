import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// CAMBIO: import original era 'firebase_options.dart' con paquete sos_mascotas
// Se usa la copia local de firebase_options en este proyecto:
import 'firebase_options.dart';
// CAMBIO: import original era parte de la app completa con login.
// En esta demo se entra directamente a la pantalla de comentarios:
import 'vista/pantalla_comentarios.dart';

// ─── NOTA SOBRE ESTA DEMO ────────────────────────────────────────────────────
// En el proyecto principal (SosMascota), antes de llegar a esta pantalla
// el usuario pasa por un flujo de autenticación (login/registro).
// Esta demo omite ese flujo y entra directamente a la pantalla de comentarios.
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

  // 2. Configuración de notificaciones locales (solo móvil)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final messaging = FirebaseMessaging.instance;

    // Solicitar permisos de notificación al usuario
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
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
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Notificaciones Demo Comentarios',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  // 3. Lanza la aplicación demo
  runApp(const DemoComentariosApp());
}

/// Aplicación raíz de la demo de comentarios.
class DemoComentariosApp extends StatelessWidget {
  const DemoComentariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Comentarios — SOS Mascota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // ─── CONFIGURACIÓN DE DEMOSTRACIÓN ───────────────────────────────────
      // Para probar con un reporte real, reemplaza los valores de abajo
      // con un ID de documento que exista en tu colección de Firestore.
      //
      // Ejemplo:
      //   reporteId: 'ABC123xyz'    ← ID real de Firestore
      //   tipo: 'reporte'           ← o 'avistamiento'
      //   tituloReporte: 'Max - Labrador perdido'
      // ─────────────────────────────────────────────────────────────────────
      home: const PantallaComentariosReporte(
        reporteId: 'REEMPLAZA_CON_ID_REAL',
        tipo: 'reporte',
        tituloReporte: 'Demo — Reporte de prueba',
      ),
    );
  }
}
