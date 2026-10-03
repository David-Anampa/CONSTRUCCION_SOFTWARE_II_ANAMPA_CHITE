# UNIVERSIDAD PRIVADA DE TACNA
## FACULTAD DE INGENIERÍA
### Escuela Profesional de Ingeniería de Sistemas

---

# PLAN DE PRUEBAS DE SOFTWARE
## Sistema SOS Mascota — Versión 4.0

**Proyecto:** *"Aplicación móvil colaborativa para mejorar la efectividad en la asistencia de mascotas perdidas con participación de voluntarios en la ciudad de Tacna, 2026"*
**Nombre del Sistema:** *SOS Mascota* (`sos_mascotas`)

**Curso:** Construcción de Software II
**Docente:** Mag. Ricardo Eduardo Valcárcel Alvarado
**Integrantes:**
- Chite Quispe Brian Danilo (2021070015)
- Anampa Pancca David Jordan (2022074268)

**Fecha de Preparacion:** 30/10/2026
**Tacna – Perú, 2026**

---

## Historial de Versiones

| Fecha | Version | Autor | Descripcion |
| :---: | :---: | :--- | :--- |
| 13/10/2026 | V1 | Anampa Pancca / Chite Quispe | Plan inicial — Módulos de autenticación y registro de mascotas |
| 23/10/2026 | V2 | Anampa Pancca / Chite Quispe | Ampliación con pruebas de avistamientos y algoritmo TFLite |
| 30/10/2026 | V3 | Anampa Pancca / Chite Quispe | Mejoras en pruebas de notificaciones FCM y módulo administrativo |
| 06/11/2026 | V4 | Anampa Pancca / Chite Quispe | Version final con pruebas de aceptacion, métricas y cierre |

---

## Información del Proyecto

| Campo | Detalle |
| :--- | :--- |
| **Empresa / Organizacion** | Universidad Privada de Tacna — Escuela Profesional de Ingeniería de Sistemas |
| **Proyecto** | SOS Mascota — Aplicacion movil colaborativa para localización de mascotas en Tacna |
| **Fecha de Preparacion** | 30/10/2026 |
| **Cliente** | Comunidad de voluntarios y dueños de mascotas de la ciudad de Tacna |
| **Lider de Proyecto** | Anampa Pancca David Jordan |
| **Lider de Pruebas** | Chite Quispe Brian Danilo / Anampa Pancca David Jordan |
| **Repositorio** | `https://github.com/David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE` |

---

## Tabla de Contenido

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Alcance de las Pruebas](#2-alcance-de-las-pruebas)
3. [Enfoque de Pruebas (Estrategia)](#3-enfoque-de-pruebas-estrategia)
4. [Criterios de Aceptacion y Rechazo](#4-criterios-de-aceptacion-y-rechazo)
5. [Criterios de Suspension y Reanudacion](#5-criterios-de-suspension-y-reanudacion)
6. [Recursos](#6-recursos)
7. [Cronograma de Pruebas](#7-cronograma-de-pruebas)
8. [Pruebas Unitarias](#8-pruebas-unitarias)
9. [Pruebas de Integracion](#9-pruebas-de-integracion)
10. [Pruebas Funcionales y de Aceptacion](#10-pruebas-funcionales-y-de-aceptacion)
11. [Pruebas de Rendimiento y No Funcionales](#11-pruebas-de-rendimiento-y-no-funcionales)
12. [Reporte de Defectos y Metricas](#12-reporte-de-defectos-y-metricas)
13. [Entregables](#13-entregables)

---

## 1. Resumen Ejecutivo

El presente Plan de Pruebas define la estrategia de validación integral del sistema **SOS Mascota** en cuatro capas de prueba (unitarias, integración, funcionales y aceptación), cubriendo los 17 requerimientos funcionales del sistema distribuidos en los siguientes módulos:

* **Módulo de Seguridad y Cuenta:** Autenticación Firebase, registro con validación RENIEC, verificación de correo electrónico, recuperación de contraseña y cierre de sesión seguro.
* **Módulo de Reportes:** Formulario wizard de 3 pasos, clasificación de imágenes con TFLite MobileNet, gestión de reportes propios.
* **Módulo de Avistamientos:** Registro geolocali­zado, algoritmo de similitud coseno de embeddings, acreditación automática de PataCoins.
* **Módulo de Visualización:** Feed reactivo con filtros, mapa interactivo OpenStreetMap, generación de cartel PDF de búsqueda.
* **Módulo de Comunicación:** Notificaciones push FCM HTTP v1, chat en tiempo real, comentarios comunitarios.
* **Módulo Administrativo:** Panel de moderación, gestión de usuarios y roles, dashboard estadístico.

Las pruebas validan tanto los requerimientos funcionales (RF-001 a RF-017) como los requerimientos no funcionales (RNF-001 a RNF-005) de rendimiento, disponibilidad, usabilidad, seguridad y escalabilidad.

**Resultado de la Auditoria de Codigo (Laboratorio 01):** `flutter test` — 3/3 casos de prueba aprobados (100%). 0 regresiones tras la refactorización de las 9 reglas de código limpio.

---

## 2. Alcance de las Pruebas

### 2.1 Funcionalidades a Probar

| Funcionalidad | Requerimiento | Prioridad |
| :--- | :---: | :---: |
| Autenticacion con Firebase Auth (login / registro / verificacion de email) | RF-001, RF-002, RF-004 | Alta |
| Recuperacion de contraseña por correo electronico | RF-003 | Media |
| Registro de reporte de mascota perdida (Wizard 3 pasos) | RF-005 | Alta |
| Clasificacion de imagen con TFLite MobileNet (confianza >= 60%) | RF-006 | Alta |
| Visualizacion del feed de reportes con filtros por especie y distrito | RF-007 | Alta |
| Registro de avistamiento geolocali­zado con GPS | RF-008 | Alta |
| Algoritmo de cotejo biometrico — similitud coseno de embeddings | RF-009 | Alta |
| Visualizacion de mascotas en mapa interactivo (FlutterMap / OpenStreetMap) | RF-010 | Alta |
| Despacho de notificaciones push mediante FCM HTTP v1 | RF-011 | Alta |
| Comentarios comunitarios con reacciones y respuestas en hilo | RF-012 | Media |
| Chat en tiempo real entre voluntario y dueno de mascota | RF-013 | Alta |
| Generacion y exportacion de cartel PDF de busqueda | RF-014 | Media |
| Gestion de perfil y monedero de PataCoins | RF-015 | Media |
| Panel administrativo — moderacion de usuarios y reportes | RF-016 | Alta |
| Dashboard estadístico con graficos para administrador | RF-017 | Media |

### 2.2 Funcionalidades Excluidas del Plan de Pruebas

| Funcionalidad Excluida | Motivo de la Exclusion | Riesgo Asociado |
| :--- | :--- | :---: |
| Pruebas de Estres a Gran Escala (> 10,000 usuarios concurrentes) | Requiere herramientas especializadas (JMeter, Locust) no contempladas en el plan | Bajo |
| Pruebas de Intrusion (Pentesting de seguridad avanzada) | Requiere perfil especializado de ciberseguridad; el plan cubre seguridad funcional | Medio |
| Compatibilidad con dispositivos iOS | El proyecto esta orientado exclusivamente a Android para Tacna | Bajo |
| Integraciones externas no especificadas en el SRS | El plan cubre solo Firebase, API RENIEC y TFLite | Bajo |

---

## 3. Enfoque de Pruebas (Estrategia)

### Tabla: Tipos de Prueba y Objetivo Principal

| Tipo de Prueba | Objetivo y Enfoque Principal | Herramienta |
| :--- | :--- | :--- |
| **Pruebas Unitarias** | Validar las reglas de negocio, funciones y validaciones directamente en ViewModels y Servicios de forma aislada mediante mocks. | `flutter test`, paquete `mockito` |
| **Pruebas de Integracion** | Asegurar la correcta comunicación con Firebase Firestore, Firebase Authentication, Firebase Storage y la API RENIEC en un entorno controlado. | Emulador de Firebase Firestore, `firebase_auth_mocks` |
| **Pruebas Funcionales y de Aceptacion** | Verificar los flujos de usuario completos de principio a fin a través de la interfaz (UI), garantizando que cada RF se cumpla en dispositivo Android físico. | Manual — Dispositivo Android 13 físico |
| **Pruebas de Rendimiento** | Medir tiempos de respuesta de operaciones criticas (Firestore queries, inferencia TFLite, despacho FCM). | Cronometro manual, Firebase Performance |
| **Pruebas de Regresion** | Garantizar que la refactorizacion de codigo limpio (Laboratorio 01) no introdujo regresiones en funcionalidades existentes. | `flutter test` (suite automatizada) |

---

## 4. Criterios de Aceptacion y Rechazo

### Criterios de Aceptacion

El ciclo de pruebas se considerara exitoso (APROBADO) si se cumplen TODAS las condiciones siguientes:
* El 100% de los casos de prueba de prioridad Alta se ejecutan sin fallos.
* No existen defectos de severidad Critica o Alta sin resolver al cierre del ciclo.
* La suite de pruebas unitarias (`flutter test`) reporta 0 fallos y 0 errores.
* Se adjunta evidencia (captura de pantalla / log) para cada caso de prueba ejecutado.
* Los tiempos de respuesta de operaciones criticas cumplen con RNF-001 (< 2 segundos).

### Criterios de Rechazo

El ciclo de pruebas se considerara fallido (RECHAZADO) si se presenta al menos UNA de las condiciones siguientes:
* Uno o mas casos de prueba de prioridad Alta fallan y el defecto no es resuelto en la misma iteracion.
* Se reportan defectos criticos o de alta severidad que permanecen abiertos al finalizar el ciclo.
* El algoritmo de similitud coseno genera mas de un 10% de falsos positivos en el conjunto de datos de prueba.
* El APK de produccion no puede instalarse en el dispositivo Android de prueba.

---

## 5. Criterios de Suspension y Reanudacion

### Criterios de Suspension

| Condicion | Descripcion |
| :--- | :--- |
| **Fallo de Servicios Externos** | La ejecucion de pruebas se detendra si Firebase Firestore, Firebase Authentication o la API RENIEC presentan una caida o indisponibilidad por mas de 2 horas consecutivas. |
| **Errores de Compilacion** | Se pausaran las pruebas si una nueva version del APK presenta errores que impiden su compilacion, instalacion o inicio en el dispositivo Android de prueba. |
| **Fallo del Modelo TFLite** | Se suspenden las pruebas si los modelos `assets/models/` no cargan correctamente en el dispositivo de prueba, bloqueando todos los casos de prueba dependientes. |

### Criterios de Reanudacion

| Condicion | Descripcion |
| :--- | :--- |
| **Restablecimiento de Servicios** | Los servicios externos deben estar nuevamente operativos y se debe haber verificado que los datos de prueba en Firestore no fueron corrompidos. |
| **Verificacion del Build** | Se debe disponer de una nueva version del APK que supere una prueba de humo (smoke test) confirmando que los errores bloqueadores fueron resueltos. |

---

## 6. Recursos

### Requerimientos de Hardware

| Equipo | Especificaciones Minimas |
| :--- | :--- |
| **Dispositivo Android de Prueba** | Android 10 (API 29) o superior, RAM 4 GB, camara 12 MP con autofoco, GPS A-GPS, almacenamiento libre 500 MB |
| **Estacion de Trabajo (QA / Dev)** | CPU octa-core 3.5 GHz, RAM 16 GB DDR4, 512 GB SSD NVMe, Windows 10/11 x64 |
| **Dispositivo Android Adicional** | Android 6.0 (API 23) minimo para verificar compatibilidad con el requisito minimo del sistema |

### Requerimientos de Software

| Componente | Detalle |
| :--- | :--- |
| **Flutter SDK** | Version 3.29 o superior (canal stable) |
| **Dart SDK** | Version 3.8.1 o compatible |
| **Firebase Emulator Suite** | Para pruebas de Firestore, Auth y Storage sin afectar produccion |
| **Android Studio / VS Code** | IDE con extensiones Flutter/Dart para ejecucion de `flutter test` |
| **firebase-tools CLI** | Para inicializar y controlar el emulador local de Firebase |

### Herramientas de Prueba

| Herramienta | Proposito en las Pruebas |
| :--- | :--- |
| `flutter test` | Ejecucion de la suite de pruebas unitarias automatizadas |
| `flutter test --coverage` | Generacion del reporte de cobertura de codigo |
| Emulador Firebase Firestore | Pruebas de integracion con Firestore sin afectar datos de produccion |
| Postman | Pruebas de la API RENIEC (`miapi.cloud`) y FCM HTTP v1 |
| Android Studio Profiler | Medicion de consumo de CPU y memoria durante inferencia TFLite |
| Capturas de Pantalla | Evidencia para cada caso de prueba ejecutado |

### Personal

| Rol | Responsabilidad | Disponibilidad |
| :--- | :--- | :--- |
| **Lider de Pruebas (QA)** | Diseno de casos de prueba, ejecucion, registro de defectos, elaboracion de metricas | 100% durante la fase de pruebas |
| **Desarrollador Full Stack** | Soporte tecnico, correcion de defectos encontrados, interpretacion de logs | 50% durante la fase de pruebas |
| **Product Owner** | Aceptacion final de los casos de prueba de aceptacion | Según cronograma |

---

## 7. Cronograma de Pruebas

| Fase | Actividades | Inicio | Fin | Responsables |
| :--- | :--- | :---: | :---: | :--- |
| **Preparacion** | Revision de RF, diseno de casos de prueba, configuracion de datos de prueba en Firebase Emulator | 01/07/2026 | 03/07/2026 | QA + Lider Tecnico |
| **Pruebas Unitarias** | Ejecucion de suite `flutter test` sobre ViewModels y Servicios | 04/07/2026 | 08/07/2026 | QA + Dev |
| **Pruebas de Integracion** | Pruebas contra Firebase Emulator (Firestore, Auth, Storage) y API RENIEC | 09/07/2026 | 11/07/2026 | QA + Dev |
| **Pruebas Funcionales** | Ejecucion de flujos UI completos por cada RF en dispositivo fisico Android 13 | 12/07/2026 | 15/07/2026 | QA |
| **Pruebas de Aceptacion** | Pruebas end-to-end con datos reales de Tacna. Evaluacion de criterios de aceptacion | 16/07/2026 | 17/07/2026 | PO + QA |
| **Cierre** | Elaboracion del Reporte de Cierre de Pruebas, entrega de metricas finales | 18/07/2026 | 18/07/2026 | QA |

---

## 8. Pruebas Unitarias

### 8.1 Comandos de Ejecucion

```powershell
# Ejecutar toda la suite de pruebas unitarias
flutter test

# Ejecutar pruebas con reporte de cobertura de codigo
flutter test --coverage

# Ejecutar pruebas y guardar resultados en JSON para reporte
flutter test --machine | Out-File -FilePath build/test_results.json -Encoding utf8
```

### 8.2 Casos de Prueba Unitaria por Modulo

---

#### RF-001 / RF-002 / RF-004: Autenticacion y Registro

**Modulo:** `LoginVM`, `RegistroVM`, `AuthServicio`
**Estado:** APROBADO — 8/8 casos exitosos

| ID Caso | Version | Descripcion del Caso | Precondiciones | Resultado Esperado | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: |
| PU-001-01 | 4.0 | `loginConEmailYPassword` retorna `UserCredential` para credenciales validas | Firebase Emulator inicializado con usuario de prueba | Login exitoso y UID no nulo | EXITOSO |
| PU-001-02 | 4.0 | `loginConEmailYPassword` lanza `FirebaseAuthException('wrong-password')` para contraseña incorrecta | Firebase Emulator con usuario existente | Excepcion tipada capturada, mensaje de error mostrado al usuario | EXITOSO |
| PU-001-03 | 4.0 | `loginConEmailYPassword` lanza `FirebaseAuthException('user-not-found')` para email no registrado | Firebase Emulator sin ese email | Excepcion tipada capturada correctamente | EXITOSO |
| PU-001-04 | 4.0 | Login redirige a `PantallaInicioAdmin` cuando el campo `rol == "admin"` en Firestore | Usuario con `rol = "admin"` en Firestore | Navegacion al panel administrativo | EXITOSO |
| PU-001-05 | 4.0 | Login redirige a `PantallaInicio` cuando el campo `rol == "usuario"` | Usuario con `rol = "usuario"` en Firestore | Navegacion al feed principal | EXITOSO |
| PU-001-06 | 4.0 | Token FCM se actualiza en Firestore al iniciar sesion exitosamente | `tokenFCM` previo en Firestore | Campo `tokenFCM` actualizado con el nuevo token del dispositivo | EXITOSO |
| PU-002-01 | 4.0 | `crearUsuarioConPassword` crea documento en Firestore con campos correctos | Firebase Emulator inicializado | Documento en coleccion `usuarios` con `rol = "usuario"` y `activo = true` | EXITOSO |
| PU-002-02 | 4.0 | Registro lanza excepcion cuando el email ya esta registrado | Email existente en Firebase Auth Emulator | `FirebaseAuthException('email-already-in-use')` capturada tipada | EXITOSO |

---

#### RF-005 / RF-006: Registro de Reporte y Clasificacion TFLite

**Modulo:** `ReporteMascotaVM`, `ServicioTFLite`, `ImagenUtil`
**Estado:** APROBADO — 7/7 casos exitosos

| ID Caso | Version | Descripcion del Caso | Precondiciones | Resultado Esperado | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: |
| PU-005-01 | 4.0 | `publicarReporte` guarda correctamente el documento en Firestore con todos los campos obligatorios | Emulador Firestore activo, `ServicioTFLite` con modelos cargados | Documento en coleccion `reportes` con `estado = "activo"` y `embeddings` de 1280 dimensiones | EXITOSO |
| PU-005-02 | 4.0 | `publicarReporte` acredita notificacion push a la comunidad tras guardar | Mock de `NotificacionServicio` | Metodo `enviarNotificacion` invocado exactamente una vez | EXITOSO |
| PU-006-01 | 4.0 | `clasificarImagen` retorna `{"perro": 0.87}` para imagen valida de perro | Modelo MobileNet cargado en `ServicioTFLite` | Mapa con clave de especie y confianza >= 60% | EXITOSO |
| PU-006-02 | 4.0 | `clasificarImagen` retorna confianza < 60% para imagen que no es una mascota | Modelo MobileNet cargado | Confianza del objeto mas probable < 0.60 — imagen rechazada | EXITOSO |
| PU-006-03 | 4.0 | `extraerEmbeddings` retorna lista de 1280 dimensiones para imagen valida | Modelo MobileNet EfficientNet cargado | `List<double>` con exactamente 1280 elementos | EXITOSO |
| PU-006-04 | 4.0 | `ImagenUtil.validarYSubirFoto` lanza excepcion cuando la imagen no pasa la clasificacion TFLite | Mock de TFLite con confianza 0.30 | `Exception("Imagen no valida: no se detecta una mascota")` lanzada | EXITOSO |
| PU-006-05 | 4.0 | `ImagenUtil.validarYSubirFoto` retorna URL de Storage cuando la imagen pasa la clasificacion | Confianza TFLite >= 60%, Storage Emulator activo | URL `https://storage.googleapis.com/...` retornada sin error | EXITOSO |

---

#### RF-008 / RF-009: Registro de Avistamiento y Algoritmo de Cotejo

**Modulo:** `AvistamientoVM`, `ServicioTFLite`
**Estado:** APROBADO — 5/5 casos exitosos

| ID Caso | Version | Descripcion del Caso | Precondiciones | Resultado Esperado | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: |
| PU-008-01 | 4.0 | `registrarAvistamiento` guarda el documento en Firestore y acredita 10 PataCoins al voluntario atomicamente | Emulador Firestore con voluntario de prueba | Documento en `avistamientos` creado + campo `pataCoins` incrementado en 10 | EXITOSO |
| PU-009-01 | 4.0 | El calculo de similitud coseno retorna valor entre 0.0 y 1.0 para dos vectores validos de 1280 dims | Dos arrays de 1280 doubles generados aleatoriamente | Valor de similitud en rango [0.0, 1.0] | EXITOSO |
| PU-009-02 | 4.0 | El algoritmo detecta coincidencia (similitud >= 0.50) entre embeddings del mismo animal | Embeddings extraidos de dos fotos del mismo perro | Similitud >= 0.50 y `reporteCoincidencia` != null | EXITOSO |
| PU-009-03 | 4.0 | El algoritmo NO detecta coincidencia (similitud < 0.50) entre embeddings de animales diferentes | Embeddings de un perro y un gato | Similitud < 0.50 y `reporteCoincidencia == null` | EXITOSO |
| PU-009-04 | 4.0 | El pre-filtro geografico de 9.0 km excluye reportes fuera del radio del voluntario | Reporte con coordenadas fuera del radio de 9 km | Reporte excluido de la lista de comparacion coseno | EXITOSO |

---

#### RF-011: Notificaciones FCM

**Modulo:** `NotificacionServicio`
**Estado:** APROBADO — 4/4 casos exitosos

| ID Caso | Version | Descripcion del Caso | Precondiciones | Resultado Esperado | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: |
| PU-011-01 | 4.0 | `_buildNotifData` construye el payload FCM HTTP v1 correctamente con los campos obligatorios | Token FCM de prueba disponible | Payload con `to`, `notification.title`, `notification.body` correctamente formados | EXITOSO |
| PU-011-02 | 4.0 | `enviarNotificacion` crea el documento en la coleccion `notificaciones` de Firestore con `leido: false` | Emulador Firestore activo | Documento en `notificaciones` con `leido = false` y `fecha` != null | EXITOSO |
| PU-011-03 | 4.0 | Token FCM invalido no produce crash — se maneja la excepcion de red | Mock HTTP con respuesta 400 | Excepcion capturada, `debugPrint` del error, sin crash de la aplicacion | EXITOSO |
| PU-011-04 | 4.0 | `marcarNotificacionLeida` actualiza el campo `leido` a `true` en Firestore | Notificacion con `leido = false` en Emulador | Campo `leido = true` en el documento de Firestore | EXITOSO |

---

#### RF-016: Panel Administrativo

**Modulo:** `AdminUsuarioVM`, `AdminReporteVM`
**Estado:** APROBADO — 4/4 casos exitosos

| ID Caso | Version | Descripcion del Caso | Precondiciones | Resultado Esperado | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: |
| PU-016-01 | 4.0 | `cambiarEstadoUsuario(activo: false)` actualiza el campo `activo` en Firestore a `false` | Usuario activo en Emulador Firestore | Campo `activo = false` en el documento del usuario | EXITOSO |
| PU-016-02 | 4.0 | `cambiarRol(nuevoRol: "admin")` actualiza el campo `rol` en Firestore correctamente | Usuario con `rol = "usuario"` en Emulador | Campo `rol = "admin"` en el documento del usuario | EXITOSO |
| PU-016-03 | 4.0 | `otorgarPataCoins` incrementa el saldo del usuario mediante `FieldValue.increment()` | Usuario con `pataCoins = 50` en Emulador | Campo `pataCoins = 150` tras otorgar 100 PataCoins | EXITOSO |
| PU-016-04 | 4.0 | Solo usuarios con `rol == "admin"` pueden acceder al panel de administracion | Mock de AuthWrapper con usuario rol "usuario" | Redireccion al feed principal — acceso denegado al panel admin | EXITOSO |

---

### 8.3 Resultado Global de Pruebas Unitarias

| Modulo | Total Casos | Exitosos | Fallidos | Estado |
| :--- | :---: | :---: | :---: | :---: |
| Autenticacion y Registro (RF-001, RF-002, RF-004) | 8 | 8 | 0 | APROBADO |
| Reportes y Clasificacion TFLite (RF-005, RF-006) | 7 | 7 | 0 | APROBADO |
| Avistamiento y Algoritmo Coseno (RF-008, RF-009) | 5 | 5 | 0 | APROBADO |
| Notificaciones FCM (RF-011) | 4 | 4 | 0 | APROBADO |
| Panel Administrativo (RF-016) | 4 | 4 | 0 | APROBADO |
| **TOTAL** | **28** | **28** | **0** | **APROBADO** |

**Comando de ejecucion:** `flutter test` — Resultado: 28/28 PASSED (0 failed, 0 errors).

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 9. Pruebas de Integracion

Las pruebas de integración verifican la correcta comunicación entre los módulos de la aplicación y los servicios externos (Firebase Firestore, Firebase Authentication, Firebase Storage, API RENIEC).

| ID Caso | Descripcion | Servicio Externo | Resultado Esperado | Estado |
| :--- | :--- | :--- | :--- | :---: |
| PI-001-01 | `AuthServicio.loginConEmailYPassword` retorna usuario autenticado en Firebase Auth real | Firebase Auth Emulator | `UserCredential.user.uid` no nulo | EXITOSO |
| PI-002-01 | `ApiDniServicio.consultarDni("12345678")` retorna nombre y apellidos desde API RENIEC | API RENIEC `miapi.cloud` (token de testing) | JSON con campos `nombre` y `apellidoPaterno` no nulos | EXITOSO |
| PI-003-01 | `ReporteMascotaVM.publicarReporte` persiste el documento en Firestore Emulator con todos los campos | Firebase Firestore Emulator | Documento recuperable con `id`, `fotoUrl`, `embeddings` y `estado = "activo"` | EXITOSO |
| PI-004-01 | `ImagenUtil.validarYSubirFoto` sube la imagen a Firebase Storage Emulator y retorna URL publica | Firebase Storage Emulator | URL en formato `https://storage.googleapis.com/...` | EXITOSO |
| PI-005-01 | `NotificacionServicio.enviarNotificacion` realiza peticion HTTP POST exitosa al endpoint FCM v1 | FCM HTTP v1 API (entorno de staging) | Respuesta HTTP 200 con `message_id` | EXITOSO |
| PI-006-01 | El stream reactivo de `AuthWrapper` expulsa al usuario cuando `activo` cambia a `false` en Firestore | Firebase Firestore Emulator (stream activo) | Navegacion automatica a `PantallaLogin` en menos de 2 segundos | EXITOSO |
| PI-007-01 | Consulta de feed con filtro `estado = "activo"` devuelve solo reportes activos ordenados por fecha | Firebase Firestore Emulator | Lista de reportes unicamente con `estado = "activo"`, ordenada por `fechaPublicacion` DESC | EXITOSO |
| PI-008-01 | El chat en tiempo real recibe mensajes nuevos mediante stream Firestore sin recargar la pantalla | Firebase Firestore Emulator (stream activo) | Nuevo mensaje visible en la UI en menos de 1 segundo tras ser insertado en Firestore | EXITOSO |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 10. Pruebas Funcionales y de Aceptacion

Las pruebas funcionales verifican los flujos de usuario completos de principio a fin en dispositivo Android físico. Se ejecutan manualmente por el QA Engineer.

---

### RF-001 / RF-002: Flujo de Registro y Login

| ID | Descripcion del Flujo | Pasos | Resultado Esperado | Evidencia |
| :--- | :--- | :--- | :--- | :---: |
| PF-001 | Registro exitoso de nuevo voluntario con DNI valido | 1. Abrir app → 2. Tocar "Registrarse" → 3. Ingresar DNI 12345678 → 4. Verificar que nombre/apellidos se auto-completan desde RENIEC → 5. Ingresar email y contraseña → 6. Tocar "Registrarse" | Snackbar "Registro exitoso. Verifica tu correo." y navegacion al Login | Captura de pantalla |
| PF-002 | Login exitoso con rol "usuario" | 1. Ingresar email y contraseña correctos → 2. Tocar "Iniciar Sesion" | Navegacion al Feed Principal (`PantallaVerReportes`) | Captura de pantalla |
| PF-003 | Login exitoso con rol "admin" | 1. Ingresar credenciales de admin → 2. Tocar "Iniciar Sesion" | Navegacion al Panel Administrativo (`PantallaInicioAdmin`) | Captura de pantalla |
| PF-004 | Error visible para contraseña incorrecta | 1. Ingresar email valido con contraseña incorrecta → 2. Tocar "Iniciar Sesion" | Mensaje de error: "Contraseña incorrecta" — sin crash | Captura de pantalla |
| PF-005 | Cuenta suspendida es expulsada de la sesion | 1. Admin cambia `activo = false` del usuario A → 2. Observar dispositivo del usuario A | Redireccion automatica a Login en menos de 2 segundos — sin intervencion manual | Grabacion de pantalla |

---

### RF-005 / RF-006: Registro de Reporte y Validacion TFLite

| ID | Descripcion del Flujo | Pasos | Resultado Esperado | Evidencia |
| :--- | :--- | :--- | :--- | :---: |
| PF-006 | Publicacion exitosa de reporte de mascota perdida | 1. Tocar "+" → 2. Completar Paso 1 (nombre, especie, descripcion) → 3. Tomar foto del perro con camara → 4. Completar Paso 2 (ubicacion GPS) → 5. Completar Paso 3 (recompensa) → 6. Tocar "Publicar" | Reporte visible en el Feed Principal con marcador rojo en el mapa de Tacna | Captura de pantalla |
| PF-007 | Imagen rechazada que no es una mascota | 1. Abrir formulario de reporte → 2. Seleccionar foto de paisaje (sin mascota) → 3. Intentar continuar al Paso 2 | Mensaje: "La imagen no corresponde a una mascota. Por favor use una foto clara del animal." — sin avanzar | Captura de pantalla |
| PF-008 | Imagen aceptada con confianza TFLite >= 60% | 1. Seleccionar foto nítida de un gato → 2. Observar estado del boton | Boton "Siguiente" habilitado — imagen aceptada sin mensaje de error | Captura de pantalla |

---

### RF-008 / RF-009: Avistamiento y Cotejo Biometrico

| ID | Descripcion del Flujo | Pasos | Resultado Esperado | Evidencia |
| :--- | :--- | :--- | :--- | :---: |
| PF-009 | Registro de avistamiento rapido con GPS | 1. Tocar "Reportar Avistamiento" → 2. Capturar foto del animal avistado → 3. GPS captura automaticamente las coordenadas → 4. Agregar descripcion (opcional) → 5. Tocar "Enviar" | Avistamiento guardado en Firestore. Snackbar "+10 PataCoins acreditados." | Captura de pantalla |
| PF-010 | Notificacion push al dueno cuando hay coincidencia biometrica | 1. Voluntario sube avistamiento de "Max" (similitud > 0.50 con reporte activo) | Notificacion push recibida en el dispositivo del dueno: "Posible coincidencia para tu mascota Max." | Captura de pantalla del dispositivo del dueno |
| PF-011 | Sin notificacion cuando la similitud es menor a 0.50 | 1. Voluntario sube avistamiento de un animal diferente | Sin notificacion push al dueno. Avistamiento guardado con `reporteCoincidencia = null` | Log de Firestore |

---

### RF-014: Generacion de Cartel PDF

| ID | Descripcion del Flujo | Pasos | Resultado Esperado | Evidencia |
| :--- | :--- | :--- | :--- | :---: |
| PF-012 | Generacion y descarga exitosa del cartel PDF | 1. Abrir detalle del reporte propio → 2. Tocar "Generar Cartel PDF" | PDF descargado con foto, nombre, descripcion, contacto y mapa de referencia. Sin errores de generacion. | Archivo PDF adjunto |

---

### RF-016: Panel Administrativo

| ID | Descripcion del Flujo | Pasos | Resultado Esperado | Evidencia |
| :--- | :--- | :--- | :--- | :---: |
| PF-013 | Suspension de cuenta de usuario infractor | 1. Admin va a "Gestionar Usuarios" → 2. Busca usuario infractor → 3. Desactiva la cuenta | Campo `activo = false` en Firestore. Usuario expulsado de su sesion activa en tiempo real. | Captura de pantalla |
| PF-014 | Cambio de rol de "usuario" a "admin" | 1. Admin busca al usuario objetivo → 2. Cambia `rol` a "admin" | Campo `rol = "admin"` actualizado en Firestore. Usuario accede al panel administrativo en su proximo login. | Captura de pantalla |

---

## 11. Pruebas de Rendimiento y No Funcionales

### RNF-001: Rendimiento (Tiempo de Respuesta < 2 segundos)

| Operacion | Dispositivo de Prueba | Tiempo Medido | Resultado |
| :--- | :--- | :---: | :---: |
| Login con Firebase Auth | Redmi Note 11 (Android 12) | 1.2 s | APROBADO |
| Carga inicial del Feed de reportes activos (20 reportes) | Redmi Note 11 (Android 12) | 1.8 s | APROBADO |
| Clasificacion TFLite de imagen (224x224 px) | Redmi Note 11 (Android 12) | 0.6 s | APROBADO |
| Extraccion de embeddings MobileNet (1280 dims) | Redmi Note 11 (Android 12) | 0.9 s | APROBADO |
| Algoritmo de cotejo coseno (20 reportes en radio 9 km) | Redmi Note 11 (Android 12) | 2.1 s | REVISION (supera limite con > 20 reportes) |
| Publicacion de reporte en Firestore | Redmi Note 11 (Android 12) | 1.4 s | APROBADO |
| Generacion de cartel PDF | Redmi Note 11 (Android 12) | 1.9 s | APROBADO |

### RNF-003: Usabilidad (Flujo de Avistamiento en < 15 segundos)

| Prueba | Participante | Tiempo de Completitud | Resultado |
| :--- | :--- | :---: | :---: |
| Registro de avistamiento desde apertura de app hasta confirmacion | Voluntario sin experiencia previa (1) | 12 s | APROBADO |
| Registro de avistamiento desde apertura de app hasta confirmacion | Voluntario sin experiencia previa (2) | 14 s | APROBADO |
| Registro de avistamiento desde apertura de app hasta confirmacion | Usuario con experiencia (3) | 8 s | APROBADO |

---

## 12. Reporte de Defectos y Metricas

### Defectos Encontrados y Resueltos

| ID Defecto | Severidad | Modulo | Descripcion | Estado |
| :--- | :---: | :--- | :--- | :---: |
| DEF-001 | Alta | `avistamiento_vm.dart` | El algoritmo de similitud coseno tardaba > 5 s con mas de 50 reportes en el radio geografico | Resuelto — Pre-filtro por bounding box geografico implementado |
| DEF-002 | Media | `notificacion_servicio.dart` | Token FCM invalido causaba un `Unhandled Exception` que crashaba la app | Resuelto — Excepcion capturada con `try/catch` y `debugPrint()` |
| DEF-003 | Media | `auth_wrapper.dart` | Cuenta suspendida no era expulsada en tiempo real si el stream tardaba en refrescarse | Resuelto — `StreamBuilder` verifica el campo `activo` en cada emision del snapshot |
| DEF-004 | Baja | `AdminEstadisticas_vm.dart` | Bloques `if/else if` sin llaves causaban comportamiento ambiguo en condiciones de borde | Resuelto — Auditoria de Codigo Limpio (Regla 8 — Espacios y Formato) |
| DEF-005 | Baja | `app.dart` | Token Bearer de API RENIEC expuesto en texto plano en el repositorio | Resuelto — Encapsulado en `AppConfig` con soporte `--dart-define` |

### Metricas de Calidad Final

| Metrica | Valor Obtenido | Objetivo | Resultado |
| :--- | :---: | :---: | :---: |
| Casos de prueba unitaria aprobados | 28/28 (100%) | 100% | APROBADO |
| Casos de prueba funcional aprobados | 14/15 (93.3%) | >= 90% | APROBADO |
| Defectos criticos abiertos al cierre | 0 | 0 | APROBADO |
| Defectos de alta severidad abiertos | 0 | 0 | APROBADO |
| Cobertura de codigo con `flutter test --coverage` | 67% | >= 70% (objetivo siguiente iteracion) | EN PROGRESO |
| Tiempo de avistamiento promedio | 11.3 s | < 15 s | APROBADO |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 13. Entregables

| Entregable | Descripcion | Estado |
| :--- | :--- | :---: |
| **Plan de Pruebas de Software** (este documento) | Guia maestra con estrategia, casos, criterios y metricas | Completo |
| **Suite de Pruebas Unitarias** | Archivos `test/*.dart` ejecutables con `flutter test` | Completo |
| **Reporte de Defectos** | Lista consolidada de 5 defectos encontrados y resueltos | Completo |
| **Evidencias de Pruebas Funcionales** | Carpeta `evidencias/` con 15 capturas de pantalla organizadas por RF | Completo |
| **Informe de Cierre de Pruebas** | Resumen final con metricas, criterios de aceptacion y recomendacion | En preparacion |

---

*Documento elaborado como parte del Plan de Pruebas de Software — Curso Construccion de Software II — Universidad Privada de Tacna — 2026.*
