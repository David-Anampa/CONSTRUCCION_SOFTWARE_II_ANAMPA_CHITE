// /**
//  * Archivo/Clase : app.dart / MyApp, NavigationService, AppConfig
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Configura el widget raíz MaterialApp, el tema visual Material 3,
//  *                 la clave global de navegación y el mapa de rutas nombradas con Provider.
//  * Se vincula con: - USA: LoginVM, RegistroVM, RecuperarVM, PerfilVM, NotificacionVM,
//  *                   AdminVM, AdminNotificacionesVM y las pantallas de vista/auth,
//  *                   vista/usuario, vista/reportes, vista/mapa y vista/admin.
//  *                 - ES USADO POR: main.dart (función runApp) y pantallas que requieren
//  *                   NavigationService.navigatorKey.
//  * Funcionamiento: Instancia MaterialApp con ruta inicial '/login' e inyecta bajo demanda
//  *                 los ChangeNotifierProvider correspondientes a cada ruta de la aplicación.
//  * Requerimiento : RF-01 al RF-17 (Enrutamiento e inyección de estado transversal MVVM)
//  */

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

/// Configuracion centralizada de la aplicacion.
///
/// Clase utilitaria reservada para constantes globales de configuración.
/// [POR CONFIRMAR]: Actualmente se encuentra vacía sin miembros definidos.
abstract final class AppConfig {}

/// Servicio que encapsula la clave global de navegacion.
///
/// Permite realizar transiciones de ruta o mostrar diálogos desde contextos
/// externos al árbol de widgets cuando sea requerido.
abstract final class NavigationService {
  /// Clave global asociada al [NavigatorState] principal de [MaterialApp].
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

/// Widget raíz de la aplicación SOS Mascota.
///
/// Define la apariencia global mediante Material 3 y registra la tabla de
/// rutas nombradas junto con sus respectivos proveedores de estado (`Provider`).
class MyApp extends StatelessWidget {
  /// Crea una instancia constante del widget raíz [MyApp].
  const MyApp({super.key});

  /// Construye el árbol principal [MaterialApp] con su tema y tabla de rutas.
  ///
  /// - Parámetros: [context] contexto de construcción del árbol de Flutter.
  /// - Valor de retorno: Widget [MaterialApp] configurado.
  /// - Efectos secundarios: Al navegar a `/inicio` o `/notificaciones`, dispara
  ///   `escucharNotificaciones()` sobre una nueva instancia de [NotificacionVM].
  @override
  Widget build(BuildContext context) {
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
          child: const PantallaRegistro(),
        ),
        "/registroAdmin": (_) => ChangeNotifierProvider(
          create: (_) => AdminVM(),
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
