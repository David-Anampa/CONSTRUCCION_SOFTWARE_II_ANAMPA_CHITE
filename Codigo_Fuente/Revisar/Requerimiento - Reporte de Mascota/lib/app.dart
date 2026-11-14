import 'package:flutter/material.dart';
// import 'package:sos_mascotas/vista/mapa/pantalla_mapa_interactivo.dart';
// import 'package:sos_mascotas/vista/usuario/pantalla_comentarios.dart';
// import 'package:sos_mascotas/vista/usuario/pantalla_notificacion.dart';
// import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';
import 'config/app_config.dart';
// import 'utils/auth_wrapper.dart'; // ❌ NO NECESARIO - Sin autenticación

// ❌ COMENTADO - Rutas de Admin no necesarias
// import 'package:sos_mascotas/vistamodelo/admin/AdminNotificaciones_vm.dart';
// import 'vista/admin/pantalla_adminusuarios.dart';
// import 'vista/admin/pantallaAdminReporte.dart';
// import 'vista/admin/PantallaAdminNotificaciones.dart';

// ⚠️ Auth NO EXISTE en este proyecto
// import 'vista/auth/pantalla_login.dart';
// import 'vista/auth/pantalla_registro.dart';
// import 'vista/auth/pantalla_recuperar.dart';
// import 'vista/auth/pantalla_verifica_email.dart';

// ✅ Core: Inicio y Reporte de Mascota
import 'vista/usuario/pantalla_inicio.dart';
// import 'vista/usuario/pantalla_perfil.dart';

import 'vista/reportes/pantalla_reporte_mascota.dart';

// import 'vista/reportes/pantalla_avistamiento.dart';
// import 'vista/reportes/pantalla_ver_reportes.dart';
// import 'vista/reportes/pantalla_mis_reportes.dart';

// ❌ Admin routes commented
// import 'vista/admin/pantalla_registro_admin.dart';
// import 'vista/admin/pantalla_inicio_admin.dart';

// ⚠️ ViewModels NO DISPONIBLES en este proyecto
// import 'vistamodelo/auth/login_vm.dart';
// import 'vistamodelo/auth/recuperar_vm.dart';
// import 'vistamodelo/auth/registro_vm.dart';
// import 'vistamodelo/admin/admin_vm.dart';
// import 'vistamodelo/usuario/perfil_vm.dart';

// import 'servicios/api_dni_servicio.dart';

/// Nombres de ruta centralizados como constantes.
/// Solo rutas esenciales para Reporte de Mascota
class AppRoutes {
  // ✅ Ruta principal
  static const String reportarMascota = '/reportarMascota';
  static const String inicio = '/inicio';

  // ❌ COMENTADAS - No disponibles en este proyecto
  // static const String login = '/login';
  // static const String registro = '/registro';
  // static const String perfil = '/perfil';

  static Map<String, WidgetBuilder> build() {
    return {
      // ✅ Rutas funcionales
      reportarMascota: (_) => const PantallaReporteMascota(),
      inicio: (_) => const PantallaInicio(),
    };
  }

  /// ❌ COMENTADO - No se usa en este requerimiento
  // /// Envuelve [child] con el `ChangeNotifierProvider` de [create].
  // static Widget _withProvider<T extends ChangeNotifier>(
  //   T Function() create,
  //   Widget child,
  // ) {
  //   return ChangeNotifierProvider<T>(create: (_) => create(), child: child);
  // }
  //     create: (_) => NotificacionVM()..escucharNotificaciones(),
  //     child: child,
  //   );
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
      // ✅ Entrada directa al inicio, con la ruta de reporte disponible
      initialRoute: AppRoutes.inicio,
      routes: AppRoutes.build(),
    );
  }
}
