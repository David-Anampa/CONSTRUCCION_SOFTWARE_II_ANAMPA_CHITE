# Progreso de Documentación Técnica — Proyecto SOSMASCOTA

- **Proyecto:** SOSMASCOTA (`sos_mascotas`)
- **Asignatura:** Construcción de Software II
- **Autores:** David Anampa, Danilo Chite
- **Fecha:** 13/11/2026
- **Fase Actual:** FASE 1 y FASE 2 completadas (74 archivos ejecutables + 11 archivos de configuración)

---

## 1. Estado Base (Pre-ejecución)

- **`flutter analyze`:** `158 issues found` (`0 errors`, `22 warnings`, `136 info`).
  - *Nota:* 21 warnings provienen de `entrega/evidencias/git/pubspec.yaml` (copia histórica en carpeta de evidencias) y 1 warning (`unnecessary_cast`) proviene de `lib/vista/usuario/pantalla_inicio.dart`. Ningún error de compilación.
- **`flutter test`:** `106/106` pruebas superadas (`00:06 +106: All tests passed!`).

---

## 2. Resumen de Avance por Módulos (FASE 1)

| Módulo | Nombre | Archivos | Estado | `flutter analyze` | `flutter test` |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Módulo 1** | Núcleo y Punto de Entrada | 2 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 2** | Modelos de Dominio (`lib/modelo/`) | 9 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 3** | Servicios, Utilidades y Widgets Base | 8 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 4** | VistaModelos (`lib/vistamodelo/`) | 13 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 5** | Vistas de Autenticación y Usuario | 10 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 6** | Vistas de Reportes, Mapa y Chat | 12 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 7** | Vistas del Panel Administrativo | 7 | Completado | 158 (igual a base) | 106/106 OK |
| **Módulo 8** | Pruebas Automatizadas y Nativo Android | 13 | Completado | 158 (igual a base) | 106/106 OK |
| **TOTAL FASE 1** | **Código Ejecutable** | **74** | **74 / 74** | **158 (0 nuevos)** | **106/106 OK** |

---

## 3. Detalle de Archivos Documentados y Pendientes

### Módulo 1 — Núcleo y Punto de Entrada (2/2)
- [x] `lib/main.dart`
- [x] `lib/app.dart`

### Módulo 2 — Modelos de Dominio (9/9)
- [x] `lib/modelo/usuario.dart`
- [x] `lib/modelo/reporte_mascota.dart`
- [x] `lib/modelo/avistamiento.dart`
- [x] `lib/modelo/comentario_model.dart`
- [x] `lib/modelo/notificacion.dart`
- [x] `lib/modelo/adminusuario_model.dart`
- [x] `lib/modelo/AdminReporte.dart`
- [x] `lib/modelo/AdminEstadisticas.dart`
- [x] `lib/modelo/AdminNotificacion.dart`

### Módulo 3 — Servicios, Utilidades y Widgets Base (8/8)
- [x] `lib/servicios/auth_servicio.dart`
- [x] `lib/servicios/firestore_servicio.dart`
- [x] `lib/servicios/notificacion_servicio.dart`
- [x] `lib/servicios/servicio_tflite.dart`
- [x] `lib/utils/auth_wrapper.dart`
- [x] `lib/utils/imagen_util.dart`
- [x] `lib/widgets/image_background.dart`
- [x] `lib/widgets/video_background.dart`

### Módulo 4 — VistaModelos (13/13)
- [x] `lib/vistamodelo/auth/login_vm.dart`
- [x] `lib/vistamodelo/auth/registro_vm.dart`
- [x] `lib/vistamodelo/auth/recuperar_vm.dart`
- [x] `lib/vistamodelo/reportes/reporte_vm.dart`
- [x] `lib/vistamodelo/reportes/avistamiento_vm.dart`
- [x] `lib/vistamodelo/usuario/perfil_vm.dart`
- [x] `lib/vistamodelo/comentarios/comentarios_viewmodel.dart`
- [x] `lib/vistamodelo/notificacion/notificacion_vm.dart`
- [x] `lib/vistamodelo/admin/admin_vm.dart`
- [x] `lib/vistamodelo/admin/adminusuario_vm.dart`
- [x] `lib/vistamodelo/admin/AdminReportes_vm.dart`
- [x] `lib/vistamodelo/admin/AdminEstadisticas_vm.dart`
- [x] `lib/vistamodelo/admin/AdminNotificaciones_vm.dart`

### Módulo 5 — Vistas de Autenticación y Usuario (10/10)
- [x] `lib/vista/auth/pantalla_login.dart`
- [x] `lib/vista/auth/pantalla_recuperar.dart`
- [x] `lib/vista/auth/pantalla_registro.dart`
- [x] `lib/vista/auth/pantalla_registro_especial.dart`
- [x] `lib/vista/auth/pantalla_verifica_email.dart`
- [x] `lib/vista/usuario/pantalla_inicio.dart`
- [x] `lib/vista/usuario/pantalla_perfil.dart`
- [x] `lib/vista/usuario/pantalla_comentarios.dart`
- [x] `lib/vista/usuario/pantalla_notificacion.dart`
- [x] `lib/vista/usuario/replies_page.dart`

### Módulo 6 — Vistas de Reportes, Mapa y Chat (12/12)
- [x] `lib/vista/reportes/pantalla_reporte_mascota.dart`
- [x] `lib/vista/reportes/pantalla_avistamiento.dart`
- [x] `lib/vista/reportes/pantalla_ver_reportes.dart`
- [x] `lib/vista/reportes/pantalla_mis_reportes.dart`
- [x] `lib/vista/reportes/pantalla_detalle_completo.dart`
- [x] `lib/vista/reportes/pantalla_detalle_reporte.dart`
- [x] `lib/vista/reportes/pantalla_comentarios_reporte.dart`
- [x] `lib/vista/reportes/pantalla_mapa_osm.dart`
- [x] `lib/vista/reportes/video_recorte_page.dart`
- [x] `lib/vista/mapa/pantalla_mapa_interactivo.dart`
- [x] `lib/vista/chat/pantalla_chat.dart`
- [x] `lib/vista/chat/pantalla_chats_activos.dart`

### Módulo 7 — Vistas del Panel Administrativo (7/7)
- [x] `lib/vista/admin/pantalla_inicio_admin.dart`
- [x] `lib/vista/admin/pantalla_adminusuarios.dart`
- [x] `lib/vista/admin/pantallaAdminReporte.dart`
- [x] `lib/vista/admin/PantallaAdminEstadisticas.dart`
- [x] `lib/vista/admin/pantallaAdminNotificaciones.dart`
- [x] `lib/vista/admin/pantalla_perfil_admin.dart`
- [x] `lib/vista/admin/pantalla_registro_admin.dart`

### Módulo 8 — Pruebas Automatizadas y Entrada Nativa Android (13/13)
- [x] `test/helpers/firebase_fakes.dart`
- [x] `test/req01_autenticacion_prueba_unitaria_test.dart`
- [x] `test/req02_registro_usuario_prueba_unitaria_test.dart`
- [x] `test/req03_recuperar_contrasena_prueba_unitaria_test.dart`
- [x] `test/rf01_login_test.dart`
- [x] `test/rf02_registro_test.dart`
- [x] `test/rf04_reporte_test.dart`
- [x] `test/rf05_avistamiento_test.dart`
- [x] `test/rf12_comentarios_test.dart`
- [x] `test/avistamiento_vm_test.dart`
- [x] `test/validaciones_test.dart`
- [x] `test/ejecutar_pruebas.ps1`
- [x] `android/app/src/main/kotlin/com/example/sos_mascotas/MainActivity.kt`

---

## 4. Registro de `[POR CONFIRMAR]` y `// FUENTE: [por confirmar con el autor]`

### `[POR CONFIRMAR]`
1. `lib/app.dart` (`AppConfig`): clase `abstract final class AppConfig {}` vacía sin constantes ni usos detectados.
2. `lib/widgets/image_background.dart` (`ImageBackground`): componente visual sin referencias activas detectadas en el código actual.
3. `lib/widgets/video_background.dart` (`VideoBackground`): componente visual sin referencias activas detectadas en el código actual.
4. `lib/vista/auth/pantalla_registro_especial.dart` (`PantallaRegistroEspecial`): pantalla informativa "en desarrollo" sin ruta registrada en `app.dart`.
5. `lib/vista/reportes/pantalla_detalle_reporte.dart` (`PantallaDetalleReporte`): visor fotográfico de detalle sin referencias activas detectadas en la navegación actual.

### `// FUENTE: [por confirmar con el autor]`
1. `lib/servicios/servicio_tflite.dart` (`compararImagenesInstancia`): cálculo de similitud coseno sobre embeddings L2.

---

## 5. Riesgos y Problemas de Calidad Detectados (SIN modificar)

1. **Riesgo de seguridad crítico:** `assets/keys/service_account.json` está empaquetado como asset de la aplicación y es leído en tiempo de ejecución por `lib/servicios/notificacion_servicio.dart` (`_jsonKeyPath`, línea 39; `_obtenerClienteFCM`, línea 78).
2. **Código duplicado:**
   - Algoritmo Haversine en `lib/vistamodelo/reportes/avistamiento_vm.dart` (`_calcularDistancia`) y `test/rf05_avistamiento_test.dart` (`calcularDistanciaKm`).
   - Lógica de consulta y enriquecimiento de usuario en `lib/vistamodelo/admin/AdminReportes_vm.dart` (`cargarReportes` y `cargarAvistamientos`).
   - Uso de `print()` en producción en `lib/utils/auth_wrapper.dart` (8 ocurrencias) y `lib/vista/reportes/pantalla_mis_reportes.dart` (4 ocurrencias).
3. **Convención de nombres y estilo:**
   - Archivos en `UpperCamelCase` en lugar de `lower_case_with_underscores`: `AdminEstadisticas.dart`, `AdminNotificacion.dart`, `AdminReporte.dart`, `PantallaAdminEstadisticas.dart`, `pantallaAdminNotificaciones.dart`, `pantallaAdminReporte.dart`, `AdminEstadisticas_vm.dart`, `AdminNotificaciones_vm.dart`, `AdminReportes_vm.dart`.
4. **APIs obsoletas / advertencias estáticas:**
   - Uso extendido de `.withOpacity()` (deprecado en favor de `.withValues()`), `Share` / `share` / `shareXFiles` (deprecado en favor de `SharePlus`), `await` innecesario sobre `Reference` en `lib/vista/usuario/pantalla_comentarios.dart:106` y uso de `BuildContext` tras brechas asíncronas (`use_build_context_synchronously`).
5. **Falta de validación / acoplamiento:**
   - `PerfilVM` (`lib/vistamodelo/usuario/perfil_vm.dart`) usa `FirebaseAuth.instance.currentUser!.uid` sin verificación previa de nulidad en `cargarPerfil()`, `guardar()`, `cambiarFoto()` y `eliminarCuenta()`.
   - `PantallaPerfil` (`lib/vista/usuario/pantalla_perfil.dart`) accede directo a Firestore en lugar de usar el `PerfilVM` inyectado por `app.dart`.

---

## 6. FASE 2 — Archivos de Configuración (11/11)

- [x] `pubspec.yaml` (`#`)
- [x] `analysis_options.yaml` (`#`)
- [x] `firestore.rules` (`//`)
- [x] `android/build.gradle.kts` (`//`)
- [x] `android/settings.gradle.kts` (`//`)
- [x] `android/app/build.gradle.kts` (`//`)
- [x] `android/gradle.properties` (`#`)
- [x] `android/app/proguard-rules.pro` (`#`)
- [x] `android/app/src/main/AndroidManifest.xml` (`<!-- -->`)
- [x] `android/app/src/debug/AndroidManifest.xml` (`<!-- -->`)
- [x] `android/app/src/profile/AndroidManifest.xml` (`<!-- -->`)

### Verificación Final (FASE 2)
- **`flutter analyze`:** `158 issues found` (idéntico al estado base; `0` errores nuevos).
- **`flutter test --no-pub`:** `106/106` pruebas superadas (`00:04 +106: All tests passed!`).
- **`flutter build apk --debug`:** Gradle configuró y procesó los manifiestos/scripts sin errores de sintaxis, pero la tarea `:app:compileFlutterBuildDebug` falló con `ShaderCompilerException` (`impellerc`: `Could not write file to ...\Código Fuente\build\app\intermediates\flutter\debug\flutter_assets\shaders/ink_sparkle.frag`), incidente del compilador de shaders por ruta con carácter no-ASCII (`ó` en `Código Fuente`), ajeno a los encabezados comentados.
