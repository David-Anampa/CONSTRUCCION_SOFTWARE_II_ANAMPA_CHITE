import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sos_mascotas/vista/mapa/pantalla_mapa_interactivo.dart';
// import 'package:sos_mascotas/vista/usuario/pantalla_comentarios.dart';
// import 'package:sos_mascotas/vista/usuario/pantalla_notificacion.dart';
// import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';
import 'config/app_config.dart';
import 'utils/auth_wrapper.dart';
import 'servicios/firebase_availability.dart' as fb_avail;

// import 'package:sos_mascotas/vistamodelo/admin/AdminNotificaciones_vm.dart';

import 'vista/admin/pantalla_adminusuarios.dart';
// import 'vista/admin/pantallaAdminReporte.dart';
// import 'vista/admin/PantallaAdminNotificaciones.dart';

// import 'vista/auth/pantalla_registro.dart';
import 'vista/auth/pantalla_login.dart';

// import 'vista/auth/pantalla_recuperar.dart';
// import 'vista/auth/pantalla_verifica_email.dart';

import 'vista/usuario/pantalla_inicio.dart';

// import 'vista/usuario/pantalla_perfil.dart';

// import 'vista/reportes/pantalla_reporte_mascota.dart';
// import 'vista/reportes/pantalla_avistamiento.dart';
// import 'vista/reportes/pantalla_ver_reportes.dart';
// import 'vista/reportes/pantalla_mis_reportes.dart';

// import 'vista/admin/pantalla_registro_admin.dart';
import 'vista/admin/pantalla_inicio_admin.dart';

// import 'vistamodelo/auth/recuperar_vm.dart';
// import 'vistamodelo/auth/registro_vm.dart';
import 'vistamodelo/auth/login_vm.dart';
// import 'vistamodelo/admin/admin_vm.dart';
// import 'vistamodelo/usuario/perfil_vm.dart';

// import 'servicios/api_dni_servicio.dart';

/// Nombres de ruta centralizados como constantes.
/// Evita escribir el mismo string ("/login", "/perfil", etc.) suelto
/// en distintas partes del proyecto (strings "mágicos").
class AppRoutes {
  static const String login = '/login';
  static const String registro = '/registro';
  static const String registroAdmin = '/registroAdmin';
  static const String recuperar = '/recuperar';
  static const String verificaEmail = '/verificaEmail';
  static const String perfil = '/perfil';
  static const String inicio = '/inicio';
  static const String inicioAdmin = '/inicioAdmin';
  static const String inicioColaborador = '/inicioColaborador';
  static const String adminUsuarios = '/adminUsuarios';
  static const String adminReportes = '/adminReportes';
  static const String adminNotificaciones = '/adminNotificaciones';
  static const String reportarMascota = '/reportarMascota';
  static const String avistamiento = '/avistamiento';
  static const String verReportes = '/verReportes';
  static const String misReportes = '/misReportes';
  static const String notificaciones = '/notificaciones';
  static const String comentarios = '/comentarios';
  static const String mapa = '/mapa';

  static Map<String, WidgetBuilder> build() {
    return {
      login: (_) => _withProvider(LoginVM.new, const PantallaLogin()),
      // registro: (_) => _withProvider(RegistroVM.new, const PantallaRegistro()),
      // registroAdmin: (_) =>
      //     _withProvider(() => AdminVM(apiDni: api), const PantallaRegistroAdmin()),
      // recuperar: (_) => _withProvider(RecuperarVM.new, const PantallaRecuperar()),
      // verificaEmail: (_) => const PantallaVerificaEmail(),
      // perfil: (_) => _withProvider(PerfilVM.new, const PantallaPerfil()),

      inicio: (_) => fb_avail.firebaseAvailable
          ? AuthWrapper(
              loginScreen: _withProvider(LoginVM.new, const PantallaLogin()),
              homeScreenBuilder: (uid, userData) {
                // Si no es usuario normal, redirigir a login
                final rol = userData['rol'] ?? 'usuario';
                if (rol == 'admin' || rol == 'colaborador') {
                  return _withProvider(LoginVM.new, const PantallaLogin());
                }
                return const PantallaInicio();
              },
            )
          : const PantallaInicio(),

      inicioAdmin: (_) => fb_avail.firebaseAvailable
          ? AuthWrapper(
              loginScreen: _withProvider(LoginVM.new, const PantallaLogin()),
              homeScreenBuilder: (uid, userData) {
                // Verificar que sea admin
                final rol = userData['rol'] ?? 'usuario';
                if (rol != 'admin') {
                  return _withProvider(LoginVM.new, const PantallaLogin());
                }
                return const PantallaInicioAdmin();
              },
            )
          : const PantallaInicioAdmin(),
      inicioColaborador: (_) => fb_avail.firebaseAvailable
          ? AuthWrapper(
              loginScreen: _withProvider(LoginVM.new, const PantallaLogin()),
              homeScreenBuilder: (uid, userData) {
                final rol = userData['rol'] ?? 'usuario';
                if (rol != 'colaborador') {
                  return _withProvider(LoginVM.new, const PantallaLogin());
                }
                return const PantallaInicio();
              },
            )
          : const PantallaInicio(),
      adminUsuarios: (_) => const PantallaAdminUsuarios(),
      // adminReportes: (_) => const PantallaAdminReporte(),
      // adminNotificaciones: (_) => _withProvider(
      //   AdminNotificacionesVM.new,
      //   const PantallaAdminNotificaciones(),
      // ),

      // reportarMascota: (_) => const PantallaReporteMascota(),
      // avistamiento: (_) => const PantallaAvistamiento(),
      // verReportes: (_) => const PantallaVerReportes(),
      // misReportes: (_) => const PantallaMisReportes(),

      // notificaciones: (_) => _withNotificaciones(const PantallaNotificaciones()),
      // comentarios: (_) => const PantallaComentarios(),
      // mapa: (_) => const PantallaMapaInteractivo(),
    };
  }

  /// Envuelve [child] con el `ChangeNotifierProvider` de [create].
  /// Reemplaza el bloque `ChangeNotifierProvider(create: ..., child: ...)`
  /// que antes se repetía manualmente para cada pantalla con ViewModel.
  static Widget _withProvider<T extends ChangeNotifier>(
    T Function() create,
    Widget child,
  ) {
    return ChangeNotifierProvider<T>(create: (_) => create(), child: child);
  }

  /// `NotificacionVM` se inicializaba igual en "/inicio" y "/notificaciones".
  /// Se centraliza aquí para no repetir la misma lógica dos veces.
  // static Widget _withNotificaciones(Widget child) {
  //   // NotificacionVM no está disponible en este workspace; devolver child directo.
  //   return child;
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor),
        scaffoldBackgroundColor: AppConfig.scaffoldBackground,
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.build(),
    );
  }
}