# Requerimiento: Autenticación de Usuario

Este documento resume el requerimiento de autenticación de usuarios, los artefactos existentes en el proyecto y dos modos de funcionamiento: **Firebase (producción)** y **Local (alternativa temporal para desarrollo / pruebas)**.

## Objetivos
- Permitir registro e inicio de sesión de usuarios.
- Diferenciar rutas según rol (`admin`, `colaborador`, `usuario`).
- Bloquear acceso si la cuenta está desactivada (`activo == false`).
- Manejar verificación por correo (solo para usuarios regulares).
- Guardar/actualizar token FCM para notificaciones push.

## Artefactos y archivos relevantes

**Front end**
- `pantalla_login.dart` — UI y validación visual del inicio de sesión. [lib/vista/auth/pantalla_login.dart](lib/vista/auth/pantalla_login.dart)

**Backend / Lógica**
- `auth_servicio.dart` — Interacción con FirebaseAuth (registro, verificación, recarga, login bloqueante). [lib/servicios/auth_servicio.dart](lib/servicios/auth_servicio.dart)
- `login_vm.dart` — Validación de formulario, signIn, carga de perfil en Firestore, verificación de `activo`, verificación de correo según rol, guardado de token FCM y decisión de ruta. [lib/vistamodelo/auth/login_vm.dart](lib/vistamodelo/auth/login_vm.dart)
- `registro_vm.dart` — Registro de usuarios (Auth + Firestore), envío de verificación y token FCM. [lib/vistamodelo/auth/registro_vm.dart](lib/vistamodelo/auth/registro_vm.dart)
- `auth_wrapper.dart` — Wrapper que escucha `authStateChanges()` y el documento Firestore para forzar signOut en condiciones inválidas. [lib/utils/auth_wrapper.dart](lib/utils/auth_wrapper.dart)
- `app.dart` — Rutas centralizadas y wrappers con providers. [lib/app.dart](lib/app.dart)
- `main.dart` — Inicialización de Firebase, notificaciones y tareas dependientes de red (actualización token, suscripción a temas). [lib/main.dart](lib/main.dart)

**Modelo / BD**
- `usuario.dart` — Modelo `Usuario` con campos: `id`, `nombre`, `correo`, `telefono`, `dni`, `rol`, `estadoVerificado`, `estadoRol`, `fotoPerfil`, `fechaRegistro`, `fcmToken`, `activo`, `idColaborador`. [lib/modelo/usuario.dart](lib/modelo/usuario.dart)
- Firestore: colección `usuarios` — documentos por `uid`.

## Flujo principal (Firebase)
1. Registro: `registro_vm` crea cuenta en FirebaseAuth, crea documento `usuarios/{uid}` con `Usuario.toMap()`, guarda token FCM si está disponible y envía correo de verificación.
2. Login: `login_vm` autentica con FirebaseAuth, carga el documento Firestore `usuarios/{uid}`, verifica `activo`, comprueba verificación de correo según rol (los `admin`/`colaborador` no requieren verificación), guarda token FCM en segundo plano, decide la ruta de la app.
3. Protección de rutas: `AuthWrapper` escucha cambios de autenticación y el documento Firestore. Si hay error, documento inexistente o `activo == false`, fuerza `signOut()` y muestra notificación.
4. Notificaciones: `main.dart` configura `FirebaseMessaging` y `flutter_local_notifications`, maneja mensajes en foreground/background y actualiza `token` en `usuarios/{uid}`.

---

## Notas sobre Firebase (producción)
- Requiere credenciales de Firebase en `firebase_options.dart` y la inicialización (`Firebase.initializeApp(...)`) en `main.dart`.
- Uso de seguridad: reglas de Firestore deben impedir lecturas/escrituras no autorizadas y permitir que solo usuarios con sesión modifiquen su propio documento, salvo procesos administrativos.
- Verificación por correo está implementada con `user.sendEmailVerification()` y comprobada en `login_vm` y `auth_servicio`.
- `fechaRegistro` se escribe con `FieldValue.serverTimestamp()` cuando no se especifica una fecha local.
- Tokens FCM: se guarda el token en el campo `token` o `fcmToken` del documento usuario; asegúrate de migrar/normalizar el campo si hay inconsistencias (`login_vm` usa `fcmToken` en el modelo, `registro_vm` actualiza `token`).

### Comentarios de implementación (Firebase)
- `auth_servicio` contiene utilidades básicas: registro, envío/reenvío de verificación, recarga del usuario y login que puede bloquear por correo no verificado.
- `login_vm` y `registro_vm` usan `FirebaseAuth.instance` y `FirebaseFirestore.instance` directamente; si quieres intercambiar implementaciones (p. ej. para testing), introduce una capa de abstracción (interfaces) para `IAuthService` y `IUsuarioRepo`.

---

## Alternativa Local (temporal) — Uso para desarrollo sin Firebase
Si necesitas trabajar offline o sin credenciales Firebase mientras desarrollas la UI, sigue esta alternativa mínima.

Objetivo: permitir desarrollar y probar flujos de UI y navegación sin depender de la nube.

Opciones recomendadas:
- Usar `fake_cloud_firestore` + `firebase_auth_mocks` (ambas ya en `dev_dependencies`) para pruebas unitarias o integración local.
- Implementar una versión `LocalAuthService` y `LocalUsuarioRepo` que respeten la misma interfaz que las clases reales (métodos: `createUserWithEmailAndPassword`, `signInWithEmailAndPassword`, `sendEmailVerification`, `currentUser`, `signOut`, y operaciones Firestore como `get`, `set`, `update`).

Ejemplo de comportamiento local (sugerido):
- `LocalAuthService` mantiene un mapa en memoria de usuarios {email -> {password, uid, emailVerified}}.
- `LocalUsuarioRepo` mantiene un mapa de documentos `usuarios/{uid}` con la misma estructura que `Usuario.toMap()`.
- `sendEmailVerification()` simplemente marca `emailVerified = true` automáticamente o tras un delay simulado.
- `FirebaseMessaging` y FCM: sustituir por un stub que devuelve un token fijo (`local-fcm-token`) y no realiza suscripciones reales.
- `main.dart` puede detectar una variable de entorno o flag (p. ej. `USE_LOCAL_AUTH=true`) para inyectar los servicios locales en lugar de los reales.

Beneficios:
- Permite trabajar en UI y rutas sin credenciales.
- Pruebas deterministas y más rápidas.

Limitaciones:
- No replica reglas de seguridad de Firestore ni comportamiento exacto de latencia/errores.
- No entrega notificaciones reales.

### Cómo integrar rápido (pasos sugeridos)
1. Crear interfaces `IAuthService` y `IUsuarioRepo` (simple archivo en `lib/servicios/`) con los métodos usados por `login_vm` y `registro_vm`.
2. Implementar `FirebaseAuthService` y `FirestoreUsuarioRepo` que deleguen a Firebase (mover la lógica actual ahí).
3. Implementar `LocalAuthService` y `LocalUsuarioRepo` para desarrollo local.
4. En `main.dart` o en un simple `service_locator.dart`, elegir la implementación según flag/env.

Si quieres, puedo:
- Escribir las interfaces y una implementación `LocalAuthService` y `LocalUsuarioRepo` básica en el proyecto ahora.
- O bien, sólo añadir un archivo `docs/README_LOCAL_AUTH.md` con el ejemplo y snippets.

---

## Consideraciones operativas y pasos siguientes
- Normalizar el campo del token FCM (`token` vs `fcmToken`) en Firestore y en `Usuario`.
- Considerar usar una capa de repositorio/servicio para facilitar testing y la alternativa local.
- Añadir tests unitarios para `login_vm` y `registro_vm` usando `firebase_auth_mocks` y `fake_cloud_firestore`.

¿Deseas que implemente la alternativa local (creando interfaces y clases `LocalAuthService` y `LocalUsuarioRepo`) ahora en el repo? Si sí, los pasos que ejecutaré son:

1. Añadir `lib/servicios/i_auth_service.dart` y `lib/servicios/i_usuario_repo.dart`.
2. Refactorizar levemente `auth_servicio.dart` para implementar `IAuthService` (no cambiaré comportamiento actual por ahora, solo añadiré la interfaz y un adaptador si procede).
3. Crear `lib/servicios/local_auth_service.dart` y `lib/servicios/local_usuario_repo.dart` con comportamiento en memoria para desarrollo.
4. Añadir instrucciones rápidas en `REQUERIMIENTO_AUTENTICACION_USUARIO.md` y en `README.md` para usar `USE_LOCAL_AUTH=true`.

Si confirmas, procedo con la implementación automática.
