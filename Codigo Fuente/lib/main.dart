// /**
//  * Archivo/Clase : main.dart / LocalNotificationService
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Punto de entrada principal de la aplicación móvil SOS Mascota.
//  *                 Inicializa Firebase, modelos de visión artificial TFLite y notificaciones.
//  * Se vincula con: - USA: DefaultFirebaseOptions (firebase_options.dart), MyApp (app.dart),
//  *                   ServicioTFLite (lib/servicios/servicio_tflite.dart), FirebaseAuth,
//  *                   FirebaseFirestore (colección 'usuarios'), FirebaseMessaging y
//  *                   FlutterLocalNotificationsPlugin.
//  *                 - ES USADO POR: Motor de arranque de Flutter en Android, iOS y Web.
//  * Funcionamiento: Asegura la inicialización del binding de Flutter y Firebase Core, carga
//  *                 los modelos locales de TensorFlow Lite, solicita permisos de mensajería
//  *                 push, monta el widget raíz MyApp y ejecuta tareas de red en segundo plano.
//  * Requerimiento : RF-01 (Autenticación), RF-04 (IA TFLite), RF-07 (Notificaciones Push)
//  */

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'app.dart';

// 🔹 Importa el servicio TFLite
import 'package:sos_mascotas/servicios/servicio_tflite.dart';

/// Servicio encapsulado para la gestion de notificaciones locales.
///
/// Provee acceso estático centralizado a la instancia única de
/// [FlutterLocalNotificationsPlugin] para mostrar alertas en primer plano.
abstract final class LocalNotificationService {
  /// Instancia compartida del plugin de notificaciones locales del dispositivo.
  static final FlutterLocalNotificationsPlugin instance =
      FlutterLocalNotificationsPlugin();
}

/// 📨 Handler para mensajes recibidos en background (solo Android/iOS)
///
/// Procesa notificaciones push entrantes cuando la aplicación está en segundo
/// plano o terminada.
/// - Parámetros: [message] contiene la carga útil enviada por Firebase Cloud Messaging.
/// - Precondiciones: Debe ser una función de nivel superior (top-level) invocable en un Isolate.
/// - Valor de retorno: [Future<void>] que completa al inicializar Firebase y registrar el evento.
/// - Errores: Puede lanzar [FirebaseException] si falla la inicialización del SDK.
/// - Efectos secundarios: Inicializa una instancia secundaria de Firebase en el Isolate de fondo.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    "📩 Mensaje recibido en background: ${message.notification?.title}",
  );
}

// =======================================================
// 🟢 FUNCIÓN: OPERACIONES DE RED DEPENDIENTES DE AUTENTICACIÓN
// =======================================================
/// Ejecuta las operaciones de red que requieren una sesión de usuario activa.
///
/// Suscribe el dispositivo móvil al tópico global `mascotas` en FCM y actualiza
/// el token de dispositivo en el documento del usuario dentro de Firestore.
/// - Parámetros: Ninguno (consulta `FirebaseAuth.instance.currentUser`).
/// - Precondiciones: Firebase Core debe estar inicializado previamente.
/// - Valor de retorno: [Future<void>] asíncrono no bloqueante.
/// - Errores: Captura internamente cualquier excepción de red o de Firebase sin propagarla.
/// - Efectos secundarios: Suscribe al tópico FCM `mascotas` y realiza una escritura merge
///   en `usuarios/{uid}` en Cloud Firestore.
Future<void> _runNetworkDependentTasks() async {
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

/// Función principal de arranque de la aplicación SOS Mascota.
///
/// Inicializa los bindings nativos de Flutter, configura Firebase Core, precarga
/// los intérpretes locales de TensorFlow Lite, registra los canales de
/// notificaciones push/locales, monta la interfaz [MyApp] y dispara las tareas
/// de sincronización de red en segundo plano.
/// - Parámetros: Ninguno.
/// - Precondiciones: Archivos de configuración de Firebase y assets TFLite disponibles.
/// - Valor de retorno: [Future<void>].
/// - Errores: Propaga errores críticos si `Firebase.initializeApp` falla; captura
///   errores de carga de TFLite para permitir el arranque degradado.
/// - Efectos secundarios: Inicializa SDKs globales, solicita permisos del sistema
///   operativo y monta el árbol de widgets en pantalla.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ✅ Inicializa Firebase
  // Esta operación es asíncrona pero es necesaria para inicializar el SDK.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. 🔹 Inicializa modelos TFLite (Operación LOCAL)
  try {
    await ServicioTFLite.inicializarModelos();
    debugPrint("✅ Modelos TFLite inicializados correctamente");
  } catch (e) {
    // Es crucial que esto no bloquee la app si falla la carga local del archivo.
    debugPrint("⚠️ Error al inicializar modelos TFLite: $e");
  }

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

    await LocalNotificationService.instance.initialize(initializationSettings);

    // 🧠 Handler de mensajes
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Mensaje recibido: ${message.notification?.title}');
      if (message.notification != null) {
        LocalNotificationService.instance.show(
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
