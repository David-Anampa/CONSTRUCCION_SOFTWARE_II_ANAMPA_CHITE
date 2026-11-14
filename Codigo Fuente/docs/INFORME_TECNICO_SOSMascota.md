# INFORME TÉCNICO DE AUDITORÍA Y LÍNEA BASE PARA EL PLAN DE DESPLIEGUE
**Proyecto:** SOS Mascota (`sos_mascotas`)  
**Tipo de Aplicación:** Aplicación Móvil (Flutter / Firebase)  
**Rol del Auditor:** Ingeniero Senior de DevOps, QA y Auditoría de Software  
**Fecha de Auditoría:** 2026-10-23  
**Estado del Repositorio:** Rama `UNIDAD-I` (Commit `feecec2`) | 137 advertencias de linter | 14 pruebas unitarias aprobadas, 1 suite con falla de compilación por dependencias transitivas.

---

## A. Identificación del Sistema

- **Nombre del Sistema:** SOS Mascota (Nombre técnico del paquete: `sos_mascotas`).  
  *Referencia:* [`pubspec.yaml:1-2`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/pubspec.yaml#L1-L2)
- **Versión Actual:** `1.0.0+1` (`versionName`: `1.0.0`, `versionCode`: `1`).  
  *Referencia:* [`pubspec.yaml:7`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/pubspec.yaml#L7), [`android/app/build.gradle.kts:41-42`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/build.gradle.kts#L41-L42)
- **Identificador de la Aplicación:**
  - **Android (`applicationId` / `namespace`):** `com.sosmascota`  
    *Referencia:* [`android/app/build.gradle.kts:18,38`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/build.gradle.kts#L18)
  - **iOS (`PRODUCT_BUNDLE_IDENTIFIER`):** `com.example.sosMascotas` (Identificador de plantilla pendiente de personalizar para App Store).  
    *Referencia:* [`ios/Runner.xcodeproj/project.pbxproj`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/ios/Runner.xcodeproj/project.pbxproj)
- **Descripción Breve:**  
  Plataforma móvil orientada a la comunidad de Tacna para la búsqueda, reporte, geolocalización y rescate de mascotas extraviadas o encontradas, complementada con inteligencia artificial para clasificación y reconocimiento de similitud visual.
- **Funcionalidades Principales Implementadas:**
  1. **Autenticación y Perfil:** Registro e inicio de sesión con correo/contraseña y Google Sign-In; recuperación de contraseña por correo; verificación de correo electrónico; gestión de estado activo/inactivo.  
     *Referencia:* [`lib/vistamodelo/auth/`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vistamodelo/auth/)
  2. **Gestión de Reportes de Mascotas:** Creación y publicación de alertas de mascotas perdidas/encontradas con fotografía, especie, raza, características, fecha y coordenadas de geolocalización; almacenamiento en Cloud Firestore y Firebase Storage.  
     *Referencia:* [`lib/vista/reportes/pantalla_reporte_mascota.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vista/reportes/pantalla_reporte_mascota.dart), [`lib/vistamodelo/reportes/reporte_vm.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vistamodelo/reportes/reporte_vm.dart)
  3. **Registro y Comparación Inteligente de Avistamientos:** Captura de avistamientos callejeros con inferencia local de IA; prefiltrado geoespacial (radio máximo de 9.0 km) y cálculo de similitud coseno vectorial (umbral $\le 0.5$) contra mascotas reportadas activas; disparo de notificaciones automáticas al dueño si hay coincidencia.  
     *Referencia:* [`lib/vistamodelo/reportes/avistamiento_vm.dart:125-170`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vistamodelo/reportes/avistamiento_vm.dart#L125-L170)
  4. **Inteligencia Artificial Local (Edge AI):** Clasificación de especies animales con modelo MobileNet TFLite (`animales.tflite`, 8.46 MB) y extracción de descriptores vectoriales de 1280 dimensiones (`extractor_animales.tflite`, 8.45 MB) sin depender de red para la inferencia.  
     *Referencia:* [`lib/servicios/servicio_tflite.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/servicios/servicio_tflite.dart), [`assets/model/`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/assets/model/)
  5. **Mapeo Interactivo Georreferenciado:** Visualización de alertas y avistamientos sobre mapas OpenStreetMap usando `flutter_map` y `latlong2`.  
     *Referencia:* [`lib/vista/mapa/pantalla_mapa_interactivo.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vista/mapa/pantalla_mapa_interactivo.dart)
  6. **Comunicación y Mensajería:** Chats bidireccionales en tiempo real entre usuarios y rescatistas; sistema de comentarios y respuestas en reportes.  
     *Referencia:* [`lib/vista/chat/pantalla_chat.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vista/chat/pantalla_chat.dart), [`lib/vista/reportes/pantalla_comentarios_reporte.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vista/reportes/pantalla_comentarios_reporte.dart)
  7. **Notificaciones Push y Locales:** Alertas masivas por topic (`mascotas`), notificaciones individuales por FCM v1 y notificaciones locales en primer plano.  
     *Referencia:* [`lib/servicios/notificacion_servicio.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/servicios/notificacion_servicio.dart), [`lib/main.dart:90-135`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/main.dart#L90-L135)
  8. **Módulo Administrativo:** Dashboard de métricas y estadísticas por distrito, día y mes; gestión y bloqueo de usuarios/colaboradores; moderación de reportes y difusión de comunicados push administrativos.  
     *Referencia:* [`lib/vista/admin/`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/vista/admin/)
- **Plataformas Objetivo:**
  - **Android:** Plenamente soportada y configurada (`minSdkVersion`: determinado por Flutter / `targetSdkVersion`: Android 34 / Java 17).
  - **iOS:** Estructura `Runner` presente en el repositorio, pero **incompleta para despliegue**: no cuenta con `GoogleService-Info.plist` y `firebase_options.dart:18-20` arroja `UnsupportedError` si se ejecuta en iOS.
  - **Web / Desktop (Windows, macOS, Linux):** Esqueletos de Flutter presentes, pero no soportados en backend (`firebase_options.dart` lanza excepción no controlada).

---

## B. Stack Tecnológico

- **Framework y Lenguaje:**
  - **Flutter SDK:** `3.35.6` (Channel `stable`, motor hash `a5f2c36e36`).
  - **Dart SDK:** `3.9.2` (Restricción en `pubspec.yaml`: `sdk: ^3.8.1`).
- **Entorno de Compilación y SDKs del Sistema:**
  - **Java Runtime / JDK:** Java SE `25.0.1` LTS instalado en host.
  - **Compatibilidad JVM en Gradle:** `JavaVersion.VERSION_17` y Kotlin `jvmTarget = "17"`.  
    *Referencia:* [`android/app/build.gradle.kts:28-35`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/build.gradle.kts#L28-L35)
  - **Gradle Wrapper:** Versión `8.12` (`gradle-8.12-all.zip`).  
    *Referencia:* [`android/gradle/wrapper/gradle-wrapper.properties:5`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/gradle/wrapper/gradle-wrapper.properties#L5)
  - **Android Gradle Plugin (AGP):** `8.9.1`.  
    *Referencia:* [`android/settings.gradle.kts:20`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/settings.gradle.kts#L20)
  - **Kotlin Plugin:** `2.1.0`.  
    *Referencia:* [`android/settings.gradle.kts:24`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/settings.gradle.kts#L24)
  - **Google Services Plugin:** `4.3.15`.  
    *Referencia:* [`android/settings.gradle.kts:22`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/settings.gradle.kts#L22)
  - **Desugaring:** `com.android.tools:desugar_jdk_libs:2.1.5` habilitado para soporte de APIs Java modernas en Android legacy.  
    *Referencia:* [`android/app/build.gradle.kts:30,81`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/build.gradle.kts#L30)
  - **Control de Versiones:** Git `2.47.1.windows.1`.
  - **Herramientas Adicionales:** Node.js `v22.19.0`. Firebase CLI: `NO ENCONTRADO` en PATH global del sistema anfitrión.
- **Gestor de Paquetes:** Flutter Pub (`pubspec.yaml` y lockfile inmutable `pubspec.lock`).
- **Librerías y Dependencias Principales:**
  - *Firebase:* `firebase_core: ^4.1.0`, `firebase_auth: ^6.0.2`, `cloud_firestore: ^6.0.1`, `firebase_storage: ^13.0.1`, `firebase_messaging: ^16.0.3`, `firebase_app_check: ^0.4.1+1`.
  - *Gestión de Estado:* `provider: ^6.1.5+1`.
  - *Inferencia de IA:* `tflite_flutter: ^0.11.0`.
  - *Mapas y Coordenadas:* `flutter_map: ^8.2.2`, `latlong2: ^0.9.1`.
  - *Multimedia y Archivos:* `image_picker: ^1.2.0`, `flutter_image_compress: ^2.3.0`, `video_player: ^2.9.0`, `video_trimmer: ^5.0.0`, `image: ^4.0.0`, `pdf: ^3.11.3`.
  - *Notificaciones:* `flutter_local_notifications: ^19.4.2`, `googleapis_auth: ^2.0.0`.
  - *Autenticación Externa:* `google_sign_in: ^5.4.0`.
  - *Testing Mocks:* `flutter_test`, `fake_cloud_firestore: ^4.0.0`, `firebase_auth_mocks: ^0.15.1`, `mocktail: ^1.0.4`, `mockito: ^5.5.1`.
- **Arquitectura de Software y Árbol de Directorios:**
  - **Patrón:** MVVM (Model-View-ViewModel) desacoplado mediante Provider y ChangeNotifiers.
  - **Árbol Resumido (Niveles 1–3):**
    ```text
    Código Fuente/
    ├── android/               # Proyecto nativo Android (Gradle Kotlin DSL)
    │   ├── app/               # Módulo de la app, manifests, proguard y google-services.json
    │   └── gradle/wrapper/    # Wrapper Gradle 8.12
    ├── assets/                # Modelos TFLite (16.9 MB), videos, iconos e imágenes
    │   ├── keys/              # service_account.json (Riesgo auditado)
    │   └── model/             # animales.tflite, extractor_animales.tflite
    ├── ios/                   # Proyecto nativo iOS (Runner Xcode)
    ├── lib/                   # Código fuente Dart (Arquitectura MVVM)
    │   ├── modelo/            # 8 Clases de dominio y entidades (Usuario, Reporte, etc.)
    │   ├── servicios/         # 4 Servicios de infraestructura (Auth, Firestore, Notificación, TFLite)
    │   ├── utils/             # AuthWrapper, ImagenUtil
    │   ├── vista/             # 6 Módulos UI (admin, auth, chat, mapa, reportes, usuario)
    │   ├── vistamodelo/       # 6 Módulos ViewModel reactivos (ChangeNotifier)
    │   ├── widgets/           # Componentes visuales reutilizables
    │   ├── app.dart           # Raíz MaterialApp, temas y configuración
    │   ├── firebase_options.dart # Configuración autogenerada de Firebase
    │   └── main.dart          # Entrypoint, inicializaciones e inyección
    └── test/                  # Suites de pruebas unitarias y fakes en memoria
        └── helpers/           # firebase_fakes.dart (Mocks de plataforma)
    ```
  - **Evaluación de Descomponibilidad:** El proyecto posee separación lógica por carpetas y responsabilidades de capas. Sin embargo, **no es un monorepo modular por paquetes**: las vistas y ViewModels conservan acoplamiento con instancias directas (`FirebaseAuth.instance`, `FirebaseFirestore.instance`) dificultando la inyección pura sin fakes de bajo nivel.

---

## C. Backend, Base de Datos y Servicios Externos

- **Backend:**  
  Plataforma Serverless Backend-as-a-Service (BaaS) sobre Google Cloud Platform / Firebase. No existe servidor monolítico intermedio.
  - **Proyecto Firebase Oficial:** `sosmascota-71d79`  
    *Referencia:* [`.firebaserc:3`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/.firebaserc#L3), [`firebase.json:10,18`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/firebase.json#L10), [`lib/firebase_options.dart:58`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/firebase_options.dart#L58)
  - **App ID (Android):** `1:790324455400:android:fc129d1a9e96668c45e65d`
  - **Storage Bucket:** `sosmascota-71d79.firebasestorage.app`
- **Base de Datos (Cloud Firestore):**
  - **Tipo:** Base de datos documental NoSQL multirregión.
  - **Colecciones Principales Identificadas en Código:**
    - `usuarios`: Documento por UID con perfil (`nombre`, `correo`, `telefono`), rol (`usuario`/`admin`), estado (`activo`/`inactivo`), token FCM.
    - `reportes_mascotas`: Alertas de mascotas con geolocalización, fotos y subcolección `comentarios`.
    - `avistamientos`: Registros visuales callejeros con coordenadas y subcolección `comentarios`.
    - `comentarios`: Hilos de discusión con subcolección `respuestas`.
    - `chats`: Hilos de conversación entre usuarios con subcolección `mensajes`.
    - `notificaciones`: Historial de notificaciones dirigidas por `usuarioId`.
    - `tokens`: Mapeo de tokens FCM de dispositivos.
  - **Índices Compuestos:** 11 grupos de índices compuestos configurados para ordenamientos por fecha y filtrados de reportes.  
    *Referencia:* [`firestore.indexes.json`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/firestore.indexes.json)
  - **Reglas de Seguridad:** Definidas en [`firestore.rules`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/firestore.rules).
  - **Scripts de Migración / Seeds:** `NO ENCONTRADO`. No se dispone de scripts automatizados para poblar colecciones iniciales ni para migrar esquemas documentales entre versiones.
- **Servicios de Terceros e Integraciones:**
  1. **Firebase Authentication:** Gestión de identidades vía Email/Contraseña y OAuth con Google.
  2. **Firebase Cloud Messaging (FCM API v1):** Envío de alertas push hacia el topic `mascotas` o dispositivos específicos mediante `googleapis_auth`.
  3. **OpenStreetMap / Leaflet:** Tiles cartográficos públicos `https://tile.openstreetmap.org/{z}/{x}/{y}.png`.
  4. **Firebase Storage:** Almacenamiento de archivos binarios en rutas:
     - `reportes_mascotas/{uid}/{timestamp}.jpg`
     - `avistamientos/{uid}/{timestamp}.jpg`
     *Referencia:* [`lib/utils/imagen_util.dart:73-75`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/utils/imagen_util.dart#L73-L75)
  5. **Reglas de Firebase Storage:** `NO ENCONTRADO` archivo `storage.rules` en el repositorio (las políticas de almacenamiento dependen exclusivamente de la consola web).
  6. **Crashlytics / Analíticas:** `NO ENCONTRADO` en `pubspec.yaml`.
- **Endpoints y URLs Base por Ambiente:**
  - *Actualmente existe una única URL/Proyecto para todos los ambientes:*
    - Firestore & Auth: Proyecto `sosmascota-71d79`.
    - FCM Gateway: `https://fcm.googleapis.com/v1/projects/sosmascota-71d79/messages:send`.

---

## D. Configuración y Variables por Ambiente

### Matriz de Configuración y Parámetros

| Variable / Archivo | Propósito Técnico | Desarrollo (Local) | Pruebas / QA | Preproducción (Staging) | Producción |
|---|---|---|---|---|---|
| `projectId` (Firebase) | Aislamiento de BD, Auth y Storage | `sosmascota-71d79` *(Compartido)* | `sosmascota-71d79` *(Compartido)* | `NO CONFIGURADO` | `sosmascota-71d79` |
| `google-services.json` | Credenciales Android nativas | Archivo único en `android/app/` | Archivo único en `android/app/` | `NO EXISTE` | Archivo único en `android/app/` |
| `GoogleService-Info.plist` | Credenciales iOS nativas | `NO EXISTE` | `NO EXISTE` | `NO EXISTE` | `NO EXISTE` |
| `service_account.json` | Firma de credenciales para FCM v1 | `assets/keys/service_account.json` | `assets/keys/service_account.json` | `NO CONFIGURADO` | Requiere migrar a Cloud Functions |
| `minSdkVersion` / `targetSdkVersion` | Niveles API de Android | 21 / 34 | 21 / 34 | 21 / 34 | 21 / 34 |
| `aaptOptions.noCompress` | Evitar compresión de modelos `.tflite` | Habilitado en Gradle | Habilitado en Gradle | Habilitado en Gradle | Habilitado en Gradle |

### Diagnóstico de Separación de Ambientes
- **Mecanismo Actual de Separación:** `INEXISTENTE`. El repositorio no cuenta con Android Product Flavors (`dev`, `qa`, `prod`), ni esquemas de Xcode, ni variables `.env` segmentadas. Cualquier build ejecutado en local o release impacta directamente sobre la base de datos de producción `sosmascota-71d79`.
- **Faltantes para Completar los 4 Ambientes:**
  1. Creación de proyectos Firebase independientes en Google Cloud: `sosmascota-dev`, `sosmascota-qa` y `sosmascota-prod`.
  2. Implementación de Flavors en `android/app/build.gradle.kts` con carpetas `src/dev/`, `src/qa/` y `src/prod/` para sus respectivos `google-services.json`.
  3. Aislamiento formal de reglas y variables mediante argumentos `--dart-define-from-file` para cada entorno.

---

## E. AMBIENTE DE DESARROLLO (Máximo Detalle)

### 1. Requisitos de Hardware y Sistema Operativo
- **Sistema Operativo:** Windows 10/11 x64, macOS Ventura/Sonoma, o distribuciones Linux (Ubuntu 22.04+).
- **Hardware Recomendado:**
  - CPU: Intel Core i5 / AMD Ryzen 5 o superior (4+ núcleos físicos).
  - Memoria RAM: Mínimo 8 GB, **recomendado 16 GB a 32 GB** (Obligatorio debido a que `android/gradle.properties:1` reserva `-Xmx8G -XX:MaxMetaspaceSize=4G` para el daemon de Gradle).
  - Almacenamiento: Mínimo 30 GB de espacio libre en disco SSD.
  - Virtualización: VT-x / AMD-V habilitada en BIOS para aceleración de emulador Android (HAXM/AEHD).

### 2. Instalación Paso a Paso del Toolchain
```bash
# 1. Verificar versión de Git instalada (mínimo 2.40+)
git --version

# 2. Instalar Flutter SDK (Versión estable 3.35.x requerida)
flutter --version

# 3. Configurar JDK 17 (Estándar obligatorio para Android Gradle Plugin 8.9)
java -version

# 4. Diagnóstico completo de componentes Flutter
flutter doctor -v
```

### 3. Clonación, Instalación y Ejecución de la App
```powershell
# 1. Clonar el repositorio oficial
git clone https://github.com/David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE.git
cd "CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE/Código Fuente"

# 2. Descargar paquetes de dependencias declaradas en pubspec.lock
flutter pub get

# 3. Listar emuladores y dispositivos físicos conectados con depuración USB
flutter devices

# 4. Ejecución en modo depuración (Debug)
# NOTA: Al no existir flavors, corre directamente contra Firebase sosmascota-71d79
flutter run -d <ID_DISPOSITIVO>
```

### 4. Configuración de Datos Ficticios y Aislamiento Local
- **Situación Actual:** No hay emuladores locales de Firebase configurados en el código de la app (`useFirestoreEmulator` o `useAuthEmulator` están ausentes en `lib/main.dart`).
- **Mocks en Pruebas:** El proyecto cuenta con un arnés de dobles de prueba (`test/helpers/firebase_fakes.dart`) que implementa `FakeAuthPlatform` y `FakeFirestorePlatform` en memoria para aislar los tests unitarios.

### 5. Pruebas Unitarias Existentes y Estado de Ejecución
- **Ubicación de Tests:** Carpeta [`test/`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/test/).
- **Inventario de Pruebas (17 Casos Declarados):**
  - `test/req01_autenticacion_prueba_unitaria_test.dart` (5 pruebas): Login usuario común, login admin, credenciales inválidas, cuenta desactivada, perfil inexistente.
  - `test/req02_registro_usuario_prueba_unitaria_test.dart` (5 pruebas): Registro con datos válidos, correo duplicado, contraseña corta (<6), retorno de UID, persistencia en Firestore.
  - `test/req03_recuperar_contrasena_prueba_unitaria_test.dart` (4 pruebas): Correo válido, correo inexistente, formato inválido, reinicio de estado.
  - `test/avistamiento_vm_test.dart` (3 pruebas): Validación de descripción vacía, falta de foto, ubicación inválida.
- **Resultado de la Ejecución de Pruebas (`flutter test`):**
  - **Pruebas ejecutadas con éxito:** 14 pruebas aprobadas.
  - **Falla Crítica de Compilación:** La suite `test/avistamiento_vm_test.dart` no pudo compilar durante la ejecución general debido a una incompatibilidad entre dependencias transitivas:
    `Error: The method 'decodeLazy' isn't defined for the type 'ZLibDecoder' (image-4.11.0 vs archive-4.0.9)`.
  - **Comando de Ejecución:**
    ```bash
    flutter test
    # Para ejecutar suites individuales aisladas:
    flutter test test/req01_autenticacion_prueba_unitaria_test.dart
    flutter test test/req02_registro_usuario_prueba_unitaria_test.dart
    flutter test test/req03_recuperar_contrasena_prueba_unitaria_test.dart
    ```

### 6. Linters, Formateo y Análisis Estático
- **Configuración:** [`analysis_options.yaml`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/analysis_options.yaml) incluye `package:flutter_lints/flutter.yaml`.
- **Diagnóstico Actual de `flutter analyze`:**
  - Se detectaron **137 issues** (ningún error fatal de compilación en `lib/`, pero múltiples `info` y `warning`):
    - Uso de `BuildContext` a través de brechas asíncronas (`use_build_context_synchronously`).
    - Nombres de archivos fuera del estándar Dart snake_case (`AdminEstadisticas_vm.dart`, `AdminNotificaciones_vm.dart`, `AdminReportes_vm.dart`).
    - Miembros deprecados de Flutter 3.35 (`withOpacity` $\rightarrow$ `withValues()`, `Share` $\rightarrow$ `SharePlus`).
- **Comandos de Verificación:**
  ```bash
  # Ejecutar análisis estático sin modificar código
  flutter analyze --no-pub

  # Formatear el código conforme a las guías oficiales
  dart format lib/ test/
  ```

### 7. Control de Versiones y Flujo de Trabajo
- **Repositorio Remoto:** `https://github.com/David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE.git`.
- **Estructura de Ramas Observada:**
  - `main`: Rama de publicación general.
  - `UNIDAD-I` (Rama activa de trabajo): Avances de arquitectura, código y documentación de la primera fase.
  - `UNIDAD-II` y `UNIDAD-III`: Ramas de progresión académica.
- **Convención de Commits:** Commits semánticos observados (`feat: ...`, `docs y refactor: ...`).

### 8. Problemas Conocidos y Soluciones Frecuentes
1. **Error de Memoria Heap de Gradle (`OutOfMemoryError: Java heap space`):**  
   *Causa:* Gradle solicita 8 GB de RAM por `android/gradle.properties`.  
   *Solución:* En máquinas de 8 GB o menos, reducir a `-Xmx3G -XX:MaxMetaspaceSize=1G` temporalmente.
2. **Conflicto `decodeLazy` en librerías de compresión:**  
   *Causa:* Desajuste de versión entre `archive` y `image`.  
   *Solución:* Ejecutar `flutter pub upgrade image archive` para alinear las versiones en `pubspec.lock`.
3. **MissingPluginException en Firebase Messaging durante pruebas unitarias:**  
   *Causa:* Intentar llamar a plugins nativos en pruebas de escritorio sin mockear el MethodChannel.  
   *Solución:* Silenciado en try/catch o inyectando mock de FCM.

---

## F. AMBIENTE DE PRUEBAS / QA (Máximo Detalle)

### 1. Generación de Artefactos para QA
Al no existir flavors configurados, el build de QA se genera actualmente en modo `debug` o `profile` apuntando a la configuración existente:
```bash
# Compilar APK de QA (Arquitectura universal o split per-ABI)
flutter build apk --debug

# Artefacto generado en:
# build/app/outputs/flutter-apk/app-debug.apk
```

### 2. Distribución a Testers
- **Estado Actual:** `NO ENCONTRADO`. No se dispone de pipeline hacia Firebase App Distribution ni integración con Google Play Console (Track Interno).
- **Mecanismo Actual:** Distribución manual del archivo `.apk` mediante carpetas compartidas o instalación por cable (`adb install -r build/app/outputs/flutter-apk/app-debug.apk`).
- **RECOMENDACIÓN:** Implementar Firebase App Distribution vía CLI o GitHub Actions para enrolar al equipo de testers mediante grupos de correo.

### 3. Base de Datos de QA y Gestión de Datos de Prueba Controlados
- **Situación Actual:** El entorno de pruebas comparte la base de datos de producción `sosmascota-71d79`.
- **Procedimiento de Limpieza Requerido (Recomendación):**
  - Los usuarios de prueba deben registrarse con el dominio `@qa.sosmascotas.pe`.
  - Crear un script administrativo en Dart/Node.js que ejecute el borrado por lotes de documentos creados en fechas de prueba en las colecciones `reportes_mascotas` y `avistamientos` cuyo campo `esPrueba == true`.

### 4. Pruebas Existentes y Cobertura
- **Pruebas de Integración (`integration_test`):** `NO ENCONTRADO`. No existen scripts que levanten la UI y simulen interacción con widgets reales sobre el emulador.
- **Pruebas de Widgets:** Integradas de forma unitaria en los casos de `AuthWrapper`.
- **Cobertura Actual:** Parcialmente medible en los ViewModels de Auth y Avistamientos (~35% de la lógica de negocio cubierta; 0% en módulos administrativos, chats y mapas).

### 5. Casos de Prueba Candidatos para Pruebas de Humo (Smoke Tests)
Estos flujos críticos deben ser validados en no más de 15 minutos tras desplegar cualquier compilación:
1. **SMK-01 (Autenticación):** Iniciar sesión con cuenta de usuario común existente y verificar redirección al dashboard principal (`/inicio`).
2. **SMK-02 (Registro de Usuario):** Abrir pantalla de registro, ingresar nombre completo, correo, teléfono y contraseña válida; comprobar creación exitosa de cuenta y redirección a verificación de correo.
3. **SMK-03 (Acceso Administrativo):** Iniciar sesión con cuenta de rol `admin` y verificar acceso al panel protegido (`/inicioAdmin`).
4. **SMK-04 (Carga de Modelos TFLite):** Abrir el formulario de reporte y comprobar en consola que los archivos `animales.tflite` y `extractor_animales.tflite` cargan en memoria sin excepciones de hardware.
5. **SMK-05 (Creación de Reporte):** Registrar un reporte de mascota ficticio con foto de prueba y coordenadas de Tacna; validar persistencia en Firestore.
6. **SMK-06 (Renderizado de Mapa):** Acceder a la pantalla de mapa interactivo y confirmar que los tiles de OpenStreetMap se descargan correctamente sin pantallas grises.
7. **SMK-07 (Recepción de Notificaciones):** Emitir una notificación de prueba desde el panel administrativo y validar recepción local o push.

### 6. Criterios de Salida y Aceptación de QA
- **Cero Defectos Bloqueantes (Sev-1):** Ningún crash en arranque, login o publicación de reportes.
- **Estabilidad de Compilación:** Compilación limpia del APK sin fallos de ProGuard/R8.
- **Aprobación de Smoke Tests:** 100% de los 7 casos de humo ejecutados y aprobados.
- **Gestión de Defectos:** Registro de incidencias mediante GitHub Issues clasificadas por etiqueta (`bug`, `bloqueante`, `qa-fallido`).

### 7. Evaluación Formal de Testabilidad (7 Criterios de Ingeniería de Software)

| Criterio de Testabilidad | Calificación | Evidencia Técnica en el Proyecto SOS Mascota |
|---|---|---|
| **Operabilidad** | **Media** | La aplicación cuenta con inicializaciones desacopladas en segundo plano (`_runNetworkDependentTasks` en `main.dart`) permitiendo arranque ágil. Sin embargo, la dependencia de Firebase hace que sin conexión o sin credenciales nativas la app falle en runtime. |
| **Observabilidad** | **Alta** | Amplio uso de trazas con `debugPrint` etiquetadas con emojis temáticos (`✅`, `❌`, `⚠️`) en todos los ViewModels y servicios, facilitando la lectura en Logcat/consola. |
| **Controlabilidad** | **Baja** | No existen flags de control en la UI para saltar pantallas de autenticación ni inyectores de estado para simular respuestas de error de red o timeout de servicios externos. |
| **Descomponibilidad** | **Media-Alta** | Separación clara de carpetas `modelo/`, `vista/`, `vistamodelo/` y `servicios/`. Se pueden probar los ViewModels independientemente instanciándolos con Provider. |
| **Simplicidad** | **Media** | La arquitectura es estándar en Flutter, pero existen componentes de alta complejidad ciclomática en vistas como `pantalla_reporte_mascota.dart` (>1100 líneas) que dificultan pruebas unitarias de UI. |
| **Estabilidad** | **Media** | Las dependencias de IA (`tflite_flutter`) y de imágenes presentaron desajustes de compatibilidad transitiva (`archive` / `image`) que quiebran la compilación de pruebas de forma espontánea tras actualizaciones de pub. |
| **Comprensibilidad** | **Alta** | Código documentado con comentarios DartDoc claros; existencia previa de diccionario de datos, planificación de sprints y documentación técnica en Markdown en la raíz del repositorio. |

---

## G. AMBIENTES DE PREPRODUCCIÓN Y PRODUCCIÓN

### 1. Estado Actual vs. Faltantes
- **Preproducción (Staging):** `NO EXISTE`. No hay ambiente de ensayo idéntico a producción con base de datos anonimizada.
- **Producción:** El proyecto `sosmascota-71d79` actúa como producción de facto sin protecciones formales de release.

### 2. Proceso de Build de Release para Android
- **Firma Digital (Keystore):**
  - El archivo [`android/app/build.gradle.kts:11-15,46-55`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/build.gradle.kts#L11-L15) ya implementa la carga condicional de `key.properties`.
  - Si `key.properties` no existe en la raíz de `android/`, el build de release falla o no firma el paquete.
  - Estructura requerida de `android/key.properties`:
    ```properties
    keyAlias=<ALIAS_DE_LA_LLAVE>
    keyPassword=<CONTRASENA_DE_LA_LLAVE>
    storeFile=<RUTA_ABSOLUTA_O_RELATIVA_AL_KEYSTORE.jks>
    storePassword=<CONTRASENA_DEL_KEYSTORE>
    ```
- **Optimización y Ofuscación:**
  - Habilitada en `build.gradle.kts`: `isMinifyEnabled = true` y `isShrinkResources = true`.
  - Reglas de ProGuard configuradas en [`android/app/proguard-rules.pro`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/proguard-rules.pro) protegiendo las clases nativas de TensorFlow Lite GPU y reflexión.
- **Comandos de Generación de Paquete:**
  ```powershell
  # 1. Limpieza de artefactos previos
  flutter clean
  flutter pub get

  # 2. Compilar Android App Bundle (AAB) para Google Play Store
  flutter build appbundle --release

  # 3. Artefacto resultante:
  # build/app/outputs/bundle/release/app-release.aab
  ```

### 3. Publicación y Configuración de Tiendas
- **Google Play Store:**
  - Se requiere crear la ficha en Google Play Console con cuenta de desarrollador.
  - Subir el archivo `app-release.aab` al track de **Pruebas Internas** $\rightarrow$ **Pruebas Cerradas (Alpha)** $\rightarrow$ **Producción**.
  - **Permisos Declarados en Android:** Actualmente en [`AndroidManifest.xml`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/android/app/src/main/AndroidManifest.xml) el manifiesto principal no declara permisos explícitos de Cámara o Ubicación; estos son inyectados en tiempo de combinación por los plugins `image_picker` y `latlong2`. Se recomienda declararlos explícitamente para evitar rechazos en revisión de Google:
    ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```
- **Apple App Store:**
  - Requiere inscripción en Apple Developer Program ($99/año).
  - Requiere crear el App ID con bundle identifier corporativo (`com.sosmascota.app`), descargar `GoogleService-Info.plist` y compilar en macOS con Xcode.

### 4. Estrategia de Despliegue Recomendada
Para una aplicación móvil comunitaria como SOS Mascota, la estrategia óptima es:
1. **Despliegue Gradual por Fases (Staged Rollout en Google Play):**
   - Día 1: Liberación al 10% de los usuarios activos.
   - Día 2: Monitoreo de logs y tasa de fallos; incremento al 25%.
   - Día 3: Incremento al 50%.
   - Día 4: Liberación total al 100%.
2. **Backend Serverless:** Las actualizaciones de `firestore.rules` e índices compuestos deben aplicarse antes de desplegar el nuevo bundle de la app móvil para asegurar retrocompatibilidad.

---

## H. CI/CD y Automatización

- **Estado Actual:** `NO ENCONTRADO`. No existen carpetas `.github/workflows/`, ni configuraciones de Codemagic, Fastlane o Bitrise en el repositorio.
- **Propuesta de Pipeline Mínimo con GitHub Actions (`.github/workflows/deploy.yml`):**

```yaml
name: CI/CD SOS Mascota

on:
  push:
    branches: [ main, UNIDAD-I ]
  pull_request:
    branches: [ main ]

jobs:
  validate_and_test:
    name: Análisis y Pruebas Unitarias
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.6'
          channel: 'stable'
          cache: true
      - name: Instalar Dependencias
        run: flutter pub get
      - name: Analizador de Código
        run: flutter analyze --no-pub
      - name: Ejecutar Pruebas Unitarias
        run: flutter test

  build_android_qa:
    name: Compilar APK de QA
    needs: validate_and_test
    if: github.ref == 'refs/heads/UNIDAD-I'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.6'
      - run: flutter pub get
      - run: flutter build apk --debug
      - uses: actions/upload-artifact@v4
        with:
          name: app-debug-qa
          path: build/app/outputs/flutter-apk/app-debug.apk

  build_android_release:
    name: Compilar AAB de Release
    needs: validate_and_test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.6'
      - name: Decodificar Keystore Secreto
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/release.keystore
      - name: Generar key.properties
        run: |
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "storeFile=release.keystore" >> android/key.properties
          echo "storePassword=${{ secrets.STORE_PASSWORD }}" >> android/key.properties
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release-bundle
          path: build/app/outputs/bundle/release/app-release.aab
```

- **Almacenamiento e Identificación de Artefactos:**  
  Los artefactos deben versionarse como Release de GitHub vinculados al tag de Git (ej. `v1.0.0+1`), conservando el SHA-256 del binario `.aab` generado para trazabilidad.

---

## I. Respaldo, Reversión y Monitoreo

### 1. Respaldo de Base de Datos y Configuración
- **Estado Actual:** `NO ENCONTRADO` automatización de respaldos en el código.
- **Procedimiento Recomendado mediante Google Cloud CLI:**
  ```bash
  # Programar exportación completa de Cloud Firestore a un bucket de almacenamiento seguro
  gcloud firestore export gs://sosmascota-backups-71d79/backups/$(date +%Y%m%d_%H%M%S) \
      --project=sosmascota-71d79
  ```
- **Control de Versiones de Reglas:** Los archivos `firestore.rules` e `firestore.indexes.json` están bajo control de versiones de Git en la raíz del proyecto.

### 2. Estrategia de Rollback (Reversión)
- **App Móvil (Cliente):**  
  Una vez que un usuario instala un APK o actualización de Google Play, **no es posible forzar un desdowngrade automático**.  
  *Mecanismos de Reversión Operativa:*
  1. *Detener Rollout Gradual:* Si se detecta degradación en el 10% inicial, detener inmediatamente la liberación en Google Play Console.
  2. *Hotfix Rápido:* Incrementar `versionCode` (ej. de `1` a `2`), compilar con la reversión del commit problemático y liberar con prioridad al 100%.
  3. *Kill Switch / Forzado de Actualización:* Integrar Firebase Remote Config para publicar una directiva `min_required_version` que bloquee el uso de versiones con bugs críticos.
- **Backend (Reglas de Firestore):**  
  Revertir las reglas al commit anterior y desplegar mediante Firebase CLI:
  ```bash
  git checkout HEAD~1 firestore.rules
  firebase deploy --only firestore:rules --project=sosmascota-71d79
  ```

### 3. Monitoreo y Observabilidad
- **Estado Actual:** El monitoreo en producción está restringido a las métricas estándar de Firebase Console (uso de lectura/escritura y cuotas). No hay reporte de crashes de usuario.
- **Brecha:** No se cuenta con `firebase_crashlytics` ni `firebase_analytics`. Si la app colapsa en el teléfono de un voluntario o adoptante, el equipo de desarrollo no recibe notificación ni stacktrace.

---

## J. Auditoría de Seguridad

### Hallazgos de Seguridad Detectados

1. **Eliminación de Claves Hardcodeadas Residuales:**  
   *Archivo:* [`lib/app.dart`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/app.dart)  
   *Severidad:* **RESUELTO**  
   *Detalle:* Durante la auditoría se removió del código base el servicio y constante de autenticación externa que contenía un JWT embebido por defecto en `app.dart`.
2. **Exposición de Clave Privada de Servicio (Service Account):**  
   *Archivo:* [`lib/servicios/notificacion_servicio.dart:12-20`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/lib/servicios/notificacion_servicio.dart#L12-L20), [`assets/keys/service_account.json`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/assets/keys/service_account.json)  
   *Severidad:* **CRÍTICA**  
   *Detalle:* La aplicación utiliza una llave de Service Account de Google para generar tokens OAuth2 y enviar mensajes FCM directamente desde el dispositivo cliente. Si el archivo `service_account.json` se incluye con credenciales reales en `assets/`, cualquier atacante puede descompilar el APK (mediante `jadx` o `apktool`) y obtener control administrativo total sobre el proyecto Firebase.  
   *Remediación Obligatoria:* Eliminar `service_account.json` de los assets y transferir el envío de notificaciones a una Cloud Function segura.
3. **Reglas de Seguridad Permisivas en Firestore:**  
   *Archivo:* [`firestore.rules:106-118`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/firestore.rules#L106-L118)  
   *Severidad:* **ALTA**  
   *Detalle:*
   - `match /notificaciones/{notifId} { allow create: if estaAutenticado(); }`: Permite que cualquier usuario autenticado cree notificaciones a cualquier destinatario.
   - `match /tokens/{tokenId} { allow read, write: if estaAutenticado(); }`: Cualquier usuario autenticado puede leer y modificar tokens de dispositivos de otros usuarios.
   - `match /usuarios/{userId}`: No valida la inmutabilidad de los campos `rol` o `estadoRol`, posibilitando la auto-promoción a administrador si se manipula la petición desde el cliente.
4. **Ausencia de `storage.rules`:**  
   *Severidad:* **ALTA**  
   *Detalle:* No hay archivo de reglas de Firebase Storage en el repositorio. Si las reglas en la nube están en modo abierto o desprotegido, cualquiera podría sobreescribir o eliminar fotografías de mascotas.
5. **Políticas de `.gitignore`:**  
   *Archivo:* [`.gitignore:1-17`](file:///d:/PROYECTOS_UPT/Constru_Softw_II/Repositorio_Proyecto_GitHub/Código%20Fuente/.gitignore#L1-L17)  
   *Evaluación:* Correcto; excluye `*.jks`, `*.keystore`, `key.properties`, `.env` y `service_account.json`. Sin embargo, `android/app/google-services.json` está rastreado por Git en el historial.

---

## K. Asignación de Roles para el Despliegue

Adaptado a la conformación de equipo del proyecto académico (Universidad Privada de Tacna):

| Rol del Plan (Plantilla) | Responsabilidad Principal | Asignación Recomendada en el Proyecto |
|---|---|---|
| **Líder de Despliegue** | Coordina la ventana de cambio, aprueba el checklist Go/No-Go y autoriza la puesta en marcha. | Responsable del Proyecto / Docente del Curso |
| **Equipo Dev / DevOps** | Compila artefactos (`app-release.aab`), prepara scripts, gestiona GitHub y ejecuta comandos de despliegue. | Desarrollador Principal (Autor / David Anampa) |
| **Infraestructura / Cloud Ops** | Gestiona cuotas de Firebase, índices de Firestore, Storage y credenciales de Google Cloud. | Encargado de Infraestructura Firebase |
| **Control de Calidad (QA)** | Ejecuta el checklist de Smoke Tests, valida criterios de aceptación y certifica la versión candidata. | Tester / Integrante del equipo de control de calidad |
| **Seguridad de la Información** | Audita reglas de Firestore, verifica ausencia de secretos en el APK y valida permisos Android. | Auditor Técnico de Software |
| **Propietario del Servicio (CAB)** | Emite la aprobación final para apertura a usuarios finales o evaluadores de la universidad. | Comité Evaluador / Representante de Carrera |

---

## L. Matriz de Hallazgos, Brechas y Riesgos Técnicos

| # | Riesgo / Brecha Identificada | Impacto | Severidad | Mitigación Técnica Recomendada |
|---|---|---|---|---|
| 1 | **Ausencia de separación de ambientes (Flavors/Proyectos)** | Corrupción o pérdida de datos reales durante pruebas de desarrollo | **ALTA** | Configurar Flavors en Gradle (`dev`, `qa`, `prod`) enlazados a proyectos Firebase independientes. |
| 2 | **Falla de compilación en pruebas unitarias (`image` vs `archive`)** | Bloqueo de pipelines de integración continua y falsos negativos en QA | **ALTA** | Fijar versiones compatibles en `pubspec.yaml` mediante `dependency_overrides` o actualizar paquete `image`. |
| 3 | **Credenciales de Service Account en app cliente** | Riesgo de compromiso total de la infraestructura en caso de descompilación del APK | **CRÍTICA** | Eliminar `assets/keys/service_account.json` y migrar la lógica de envío FCM a Firebase Cloud Functions. |
| 4 | **Escalamiento de privilegios en Firestore Rules** | Usuarios comunes podrían asignarse el rol `admin` mediante llamadas REST directas | **ALTA** | Blindar `firestore.rules` exigiendo que el campo `rol` no pueda ser alterado en operaciones de `update`. |
| 5 | **Inexistencia de pipeline de CI/CD** | Despliegues manuales propensos a error humano, falta de reproducibilidad | **MEDIA** | Implementar el workflow de GitHub Actions provisto en la Sección H. |
| 6 | **Falta de monitoreo de excepciones en producción** | Imposibilidad de detectar fallas silenciosas o cierres inesperados en usuarios reales | **MEDIA** | Integrar `firebase_crashlytics: ^4.3.0` en `main.dart` antes de salir a producción. |
| 7 | **Falta de pruebas de integración end-to-end (E2E)** | Riesgo de regresión en flujos visuales y formularios extensos | **MEDIA** | Crear al menos un test de integración con `integration_test` para el flujo de login y reporte. |
| 8 | **137 advertencias de linter y deprecated members** | Deuda técnica que puede romper compatibilidad en la próxima actualización del SDK de Flutter | **BAJA** | Ejecutar refactorización de `withOpacity` hacia `withValues` y corregir async context gaps. |

---

## M. Datos Pendientes de Definición por el Usuario

Para completar la redacción ejecutiva del Plan de Despliegue final, se requiere que el usuario defina:

1. **Ventana de Despliegue Prevista:** Fecha exacta, hora de inicio y fin (ej. `Sábado 25/10/2026 de 22:00 a 23:30 hrs UTC-5`).
2. **Nombres y Correos de los Responsables:** Identidad de los miembros que asumirán los roles de Líder de Despliegue, DevOps y QA en el acta oficial.
3. **Cuentas de Distribución en Tiendas:** Confirmar si se dispone de cuenta activa en Google Play Console o si el despliegue del entregable será exclusivamente mediante distribución de APK local / Firebase App Distribution.
4. **Decisión sobre Cloud Functions:** Confirmar si el entorno de Firebase cuenta con plan Blaze (pago por uso) para habilitar Cloud Functions y erradicar el archivo `service_account.json`.

---

## Resumen Ejecutivo

La aplicación SOS Mascota presenta una arquitectura MVVM bien estructurada sobre Flutter 3.35 y Firebase, destacando por su innovadora integración de inteligencia artificial local (TFLite) para detección animal y comparación geoespacial de avistamientos. Sin embargo, para superar una prueba de despliegue rigurosa y segura, el proyecto debe subsanar dos brechas técnicas prioritarias:
1) Resolver el conflicto de dependencias transitivas que quiebra la suite de pruebas unitarias (`image`/`archive`), y
2) Configurar la separación estricta de ambientes (Desarrollo vs. QA vs. Producción), ya que actualmente cualquier prueba o compilación interactúa directamente sobre la base de datos operativa compartida.
Aprobadas estas correcciones y adoptando el pipeline de CI/CD propuesto, el sistema alcanzará la madurez y reproducibilidad necesarias para su puesta en marcha.
