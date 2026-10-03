import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/mapa/pantalla_mapa_interactivo.dart';
import 'package:sos_mascotas/vista/usuario/pantalla_comentarios.dart';
import 'package:sos_mascotas/vista/usuario/pantalla_notificacion.dart';
import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';

import 'package:sos_mascotas/vistamodelo/admin/AdminNotificaciones_vm.dart';

import 'vista/admin/pantalla_adminusuarios.dart';
import 'vista/admin/pantallaAdminReporte.dart';
import 'vista/admin/PantallaAdminNotificaciones.dart';

import 'vista/auth/pantalla_registro.dart';
import 'vista/auth/pantalla_login.dart';
import 'vista/auth/pantalla_recuperar.dart';
import 'vista/auth/pantalla_verifica_email.dart';

import 'vista/usuario/pantalla_inicio.dart';
import 'vista/usuario/pantalla_perfil.dart';

import 'vista/reportes/pantalla_reporte_mascota.dart';
import 'vista/reportes/pantalla_avistamiento.dart';
import 'vista/reportes/pantalla_ver_reportes.dart';
import 'vista/reportes/pantalla_mis_reportes.dart';
import 'vista/admin/pantalla_registro_admin.dart';
import 'vista/admin/pantalla_inicio_admin.dart';
import 'vistamodelo/auth/recuperar_vm.dart';
import 'vistamodelo/auth/registro_vm.dart';
import 'vistamodelo/auth/login_vm.dart';
import 'vistamodelo/admin/admin_vm.dart';
import 'vistamodelo/usuario/perfil_vm.dart';
import 'servicios/api_dni_servicio.dart';

/// Configuracion centralizada de la aplicacion.
abstract final class AppConfig {
  /// Token de acceso para el servicio API DNI.
  /// Lee desde variable de entorno si esta presente via --dart-define.
  static const String dniBearerToken = String.fromEnvironment(
    'DNI_TOKEN',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyOTUsImV4cCI6MTc1ODIzOTQxMX0.wX7JTrLUVGXvotDn376U462eIwzlA3PgzcM3sQ-mVX8',
  );
}

/// Servicio que encapsula la clave global de navegacion.
abstract final class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiDniServicio(bearerToken: AppConfig.dniBearerToken);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SOS Mascota',
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4D9EF6)),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      initialRoute: "/login",
      routes: {
        "/login": (_) => ChangeNotifierProvider(
          create: (_) => LoginVM(),
          child: const PantallaLogin(),
        ),
        "/registro": (_) => ChangeNotifierProvider(
          create: (_) => RegistroVM(),
          //create: (_) => RegistroVM(apiDni: api),
          child: const PantallaRegistro(),
        ),
        "/registroAdmin": (_) => ChangeNotifierProvider(
          create: (_) => AdminVM(apiDni: api),
          child: const PantallaRegistroAdmin(),
        ),
        "/recuperar": (_) => ChangeNotifierProvider(
          create: (_) => RecuperarVM(),
          child: const PantallaRecuperar(),
        ),
        "/verificaEmail": (_) => const PantallaVerificaEmail(),
        "/perfil": (_) => ChangeNotifierProvider(
          create: (_) => PerfilVM(),
          child: const PantallaPerfil(),
        ),
        "/inicio": (_) => ChangeNotifierProvider(
          create: (_) => NotificacionVM()..escucharNotificaciones(),
          child: const PantallaInicio(),
        ),

        "/inicioAdmin": (_) => const PantallaInicioAdmin(),
        "/adminUsuarios": (_) => const PantallaAdminUsuarios(),
        "/adminReportes": (_) => const PantallaAdminReporte(),
        "/adminNotificaciones": (_) => ChangeNotifierProvider(
          create: (_) => AdminNotificacionesVM(),
          child: const PantallaAdminNotificaciones(),
        ),
        "/reportarMascota": (_) => const PantallaReporteMascota(),
        "/avistamiento": (_) => const PantallaAvistamiento(),
        "/verReportes": (_) => const PantallaVerReportes(),
        "/misReportes": (_) => const PantallaMisReportes(),
        "/notificaciones": (context) => ChangeNotifierProvider(
          create: (_) => NotificacionVM()..escucharNotificaciones(),
          child: const PantallaNotificaciones(),
        ),
        "/comentarios": (_) => const PantallaComentarios(),
        "/mapa": (context) => const PantallaMapaInteractivo(),
      },
    );
  }
}
