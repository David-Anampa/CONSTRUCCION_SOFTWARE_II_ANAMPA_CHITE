# UNIVERSIDAD PRIVADA DE TACNA
## FACULTAD DE INGENIERÍA
### Escuela Profesional de Ingeniería de Sistemas

---

# PLAN DE DESPLIEGUE
## Sistema SOS Mascota — Versión 1.0

**Proyecto:** *"Aplicación móvil colaborativa para mejorar la efectividad en la asistencia de mascotas perdidas con participación de voluntarios en la ciudad de Tacna, 2026"*
**Nombre del Sistema:** *SOS Mascota* (`sos_mascotas`)

**Curso:** Construcción de Software II
**Docente:** Mag. Ricardo Eduardo Valcárcel Alvarado
**Integrantes:**
- Chite Quispe Brian Danilo (2021070015)
- Anampa Pancca David Jordan (2022074268)

**Versión:** 1.0
**Fecha:** 05/11/2026
**Tacna – Perú, 2026**

---

## Historial de Revisiones

| Fecha | Version | Descripcion | Autor |
| :---: | :---: | :--- | :--- |
| 05/11/2026 | 1.0 | Plan de despliegue inicial — Configuración de Firebase producción, compilación del APK y estrategia de distribución a voluntarios de Tacna | Chite Quispe Brian Danilo / Anampa Pancca David Jordan |
| 12/11/2026 | 1.1 | Actualización con detalles de capacitación y manuales de usuario final | Chite Quispe Brian Danilo / Anampa Pancca David Jordan |

---

## Tabla de Contenido

1. [Introducción](#1-introducción)
2. [Referencias](#2-referencias)
3. [Planificación del Despliegue](#3-planificación-del-despliegue)
4. [Recursos](#4-recursos)
5. [Capacitación](#5-capacitación)

---

## 1. Introducción

El presente Plan de Despliegue tiene como finalidad establecer la estrategia, los procedimientos y los recursos necesarios para la correcta implementación del sistema **SOS Mascota**, aplicación móvil colaborativa para mejorar la efectividad en la asistencia de mascotas perdidas con participación de voluntarios en la ciudad de Tacna.

El sistema ha sido desarrollado en **Flutter** (Dart SDK 3.8.1) con backend en **Firebase** (Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging) e inferencia local de visión artificial mediante **TensorFlow Lite** (modelos MobileNet de clasificación y extracción de embeddings). La aplicación está diseñada para desplegarse en plataformas Android (APK / AAB) con distribución mediante Google Play Store (internal testing) y Firebase App Distribution para la fase piloto con voluntarios de Tacna.

El despliegue contempla tanto la configuración de los servicios en la nube (proyecto Firebase de producción), la compilación y firma del APK de producción, la puesta en marcha de las reglas de seguridad de Firestore, como las actividades de capacitación a los voluntarios y al administrador del sistema. Se incluyen estrategias de mitigación de riesgos para asegurar la continuidad del servicio de rescate de mascotas a largo plazo.

Con este plan, se busca garantizar una implementación ordenada y controlada del sistema SOS Mascota en el ecosistema operativo de la comunidad de voluntarios de Tacna.

---

### 1.1 Objetivo

El objetivo del presente Plan de Despliegue es establecer las directrices, procedimientos y recursos necesarios para la implementación efectiva del sistema SOS Mascota, asegurando que la aplicación sea instalada, configurada, probada y puesta en funcionamiento de manera controlada y segura.

Este plan garantiza que el sistema desarrollado sea:
* Accesible para todos los voluntarios y dueños de mascotas en la ciudad de Tacna mediante dispositivos Android.
* Seguro en el manejo de datos personales validados por RENIEC y coordenadas GPS de los usuarios.
* Estable y con alta disponibilidad para responder a situaciones urgentes de rescate.
* Compatible con el flujo de trabajo reactivo de la comunidad de rescate animal de Tacna.

### 1.2 Alcance

El despliegue comprende:
* La configuración del proyecto Firebase de producción (`sos-mascota-prod`) con todas las reglas de seguridad de Firestore y Storage.
* La compilación y firma del APK de producción para distribución en Android 6.0 o superior.
* La configuración de Firebase Cloud Messaging (FCM HTTP v1) para el despacho de notificaciones push.
* La distribución de la aplicación a la comunidad piloto de voluntarios de Tacna mediante Firebase App Distribution.
* La capacitación del administrador del sistema y de los usuarios voluntarios.
* El soporte post-despliegue durante las primeras 6 semanas de operación.

Los destinatarios del sistema son:
* **Voluntarios y dueños de mascotas** de la ciudad de Tacna que usan la app en sus dispositivos Android.
* **Administrador del sistema** responsable de la moderación de usuarios, reportes y estadísticas.
* **Equipo de desarrollo** que brinda soporte técnico y aplica actualizaciones.
* **Docente evaluador** de la Universidad Privada de Tacna que supervisa la implementación.

### 1.3 Definiciones, Acrónimos y Abreviaturas

| Acrónimo | Definición |
| :--- | :--- |
| **APK** | Android Package — Archivo de instalación del aplicativo para dispositivos Android |
| **AAB** | Android App Bundle — Formato optimizado de distribución en Google Play Store |
| **FCM** | Firebase Cloud Messaging — Servicio de notificaciones push de Google |
| **Firestore** | Cloud Firestore — Base de datos NoSQL distribuida de Google Firebase |
| **TFLite** | TensorFlow Lite — Motor de inferencia de modelos de IA en dispositivos móviles |
| **RENIEC** | Registro Nacional de Identificación y Estado Civil — Entidad peruana de identidad |
| **DNI** | Documento Nacional de Identidad peruano de 8 dígitos |
| **SLA** | Service Level Agreement — Acuerdo de nivel de servicio de disponibilidad |
| **MVVM** | Model-View-ViewModel — Patrón arquitectónico del sistema |
| **GPS** | Global Positioning System — Sistema de geolocalización satelital |

---

## 2. Referencias

Los documentos institucionales y técnicos utilizados en la elaboración del presente Plan de Despliegue son:

* `PLAN_DE_ITERACION_SOS_MASCOTA.md` — Plan de Iteración con los 17 requerimientos funcionales del sistema.
* `INFORME_LABORATORIO_01_REVISION_CODIGO.md` — Informe de auditoría y refactorización de código limpio.
* `PLAN_DE_RIESGOS_SOS_MASCOTA.md` — Plan de gestión de riesgos operacionales y técnicos.
* `PLAN_DE_MANTENIMIENTO_SOS_MASCOTA.md` — Plan de mantenimiento conforme a ISO/IEC 14764:2006.
* Documentación oficial de Firebase: `https://firebase.google.com/docs`
* Documentación oficial de Flutter: `https://docs.flutter.dev`
* Repositorio del proyecto: `https://github.com/David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE`

---

## 3. Planificación del Despliegue

La planificación del despliegue comprende un conjunto de actividades técnicas, logísticas y operativas destinadas a garantizar la correcta configuración y puesta en funcionamiento del sistema SOS Mascota. Estas acciones se organizan en fases secuenciales con el cronograma detallado a continuación.

### 3.1 Fases del Despliegue

#### Fase 1: Pre-Producción — Preparación Técnica

Durante esta etapa se definen los objetivos específicos de la implementación, los recursos humanos y materiales necesarios, así como los procedimientos de instalación y validación. Se elabora el cronograma de actividades, el plan de pruebas de aceptación y la asignación de responsabilidades para cada integrante del equipo.

**Actividades:**
* Creación y configuración del proyecto Firebase de producción (`sos-mascota-prod`).
* Configuración de reglas de seguridad en Firestore (`firestore.rules`) que restringen el acceso por `uid` y `rol`.
* Configuración de Firebase Authentication con los usuarios iniciales del administrador.
* Compilación del APK de producción con todas las claves de producción y el token Bearer de RENIEC inyectado mediante `--dart-define`.
* Configuración de Firebase Cloud Messaging (FCM) con las claves del servidor HTTP v1.
* Validación de los modelos TFLite (`assets/models/`) cargados correctamente en el APK de producción.

#### Fase 2: Pre-Producción — Validación y Pruebas Beta

Se realizan pruebas funcionales y de rendimiento del aplicativo móvil en un entorno controlado con datos de prueba de Tacna. Estas pruebas verifican:
* La correcta autenticación con Firebase Auth y verificación de rol en Firestore.
* El registro de reportes de mascotas con clasificación TFLite y almacenamiento en Storage.
* El despacho de notificaciones FCM a dispositivos Android físicos.
* El funcionamiento del algoritmo de similitud coseno con coordenadas reales de Tacna.
* La visualización del mapa interactivo con marcadores sobre el mapa de Tacna.

Los resultados obtenidos sirven para ajustar parámetros de configuración, latencia de consultas Firestore y estabilidad del proceso de inferencia TFLite.

#### Fase 3: Go-Live — Despliegue a Producción

El día de Go-Live se ejecutan en el siguiente orden:

| Horario | Actividad | Responsable |
| :---: | :--- | :--- |
| 06:00 - 07:00 | Backup completo del proyecto Firebase (export de todas las colecciones) | DevOps Engineer |
| 07:00 - 08:00 | Publicación del APK en Firebase App Distribution (internal testing) | Release Manager |
| 08:00 - 09:00 | Verificación de reglas de seguridad de Firestore en producción | Líder Técnico |
| 09:00 - 10:00 | Activación del servicio de notificaciones FCM en producción | Backend Lead |
| 10:00 - 11:00 | Monitoreo de los primeros reportes de mascotas en producción | QA Engineer |
| 11:00 - 12:00 | Distribución del APK de instalación a voluntarios piloto de Tacna | Project Manager |
| 13:00 - 16:00 | Soporte en vivo para las primeras instalaciones en dispositivos Android | Desarrollador Full Stack |
| 16:00 - 17:00 | Monitoreo de métricas y logs de Firebase | DevOps Engineer |
| 17:00 - 18:00 | Reunión de cierre del día — estado e incidencias detectadas | Todos |

#### Fase 4: Post-Despliegue — Estabilización y Soporte (Semanas 4-6)

| Semana | Actividades |
| :---: | :--- |
| **Semana 4** | Soporte activo 8:00-18:00. Monitoreo de métricas de rendimiento. Resolución de incidencias. Recopilación de feedback de voluntarios de Tacna. Ajustes de configuración. Reunión diaria de estado (30 min). |
| **Semana 5** | Soporte estándar 9:00-17:00. Análisis de datos de uso. Optimización de parámetros del algoritmo TFLite. Sesiones de refuerzo de capacitación. Preparación de documentación mejorada. |
| **Semana 6** | Transición a soporte normal. Evaluación de éxito del despliegue. Documentación final. Entrega formal al equipo de soporte a largo plazo. Cierre del proyecto de despliegue. |

---

### 3.2 Responsabilidades

La ejecución del despliegue involucra la participación coordinada del equipo de desarrollo y de los voluntarios de la comunidad de Tacna.

#### Equipo de Desarrollo

| Responsabilidad | Detalle |
| :--- | :--- |
| **Planificación e instalación** | Preparar el entorno técnico de Firebase producción, las claves de compilación y la infraestructura de FCM. |
| **Configuración y pruebas** | Configurar Firestore, Storage y Authentication. Realizar pruebas funcionales de todos los módulos. |
| **Documentación técnica** | Elaborar manuales de instalación, guías de usuario y procedimientos de mantenimiento preventivo. |
| **Capacitación** | Brindar instrucción al administrador y a los voluntarios piloto sobre el uso del aplicativo. |
| **Soporte post-despliegue** | Atender incidencias, aplicar actualizaciones y supervisar el rendimiento durante el período inicial. |

#### Gestión de Discrepancias

En caso de presentarse inconsistencias durante las pruebas de aceptación, se documenta el incidente en el sistema de Issues de GitHub con el formato `MANT-YYYYMMDD-XXX`. El equipo de desarrollo analiza la causa, propone la corrección y notifica a los afectados una vez implementada la solución. Las pruebas se repiten hasta obtener conformidad total.

---

### 3.3 Cronograma General

| Semana | Fase | Actividades Principales |
| :---: | :--- | :--- |
| **Semana 1** | Pre-Producción — Preparación | Configuración de Firebase producción. Compilación de APK con claves de producción. Configuración de reglas de Firestore. |
| **Semana 2** | Pre-Producción — Validación | Pruebas funcionales end-to-end. Simulacro de despliegue. Go/No-Go meeting con stakeholders. |
| **Semana 3** | Despliegue a Producción | Go-Live. Distribución a voluntarios piloto. Capacitación de administrador y usuarios. |
| **Semanas 4-6** | Post-Despliegue — Estabilización | Soporte activo. Corrección de bugs. Ajustes de configuración. Evaluación de éxito. |

---

## 4. Recursos

### 4.1 Infraestructura Cloud — Firebase

| Servicio Firebase | Configuracion | Uso en SOS Mascota |
| :--- | :--- | :--- |
| **Firebase Authentication** | Habilitado con Email/Password | Autenticación de voluntarios y administradores |
| **Cloud Firestore** | Plan Blaze (pay-as-you-go), región us-central1 | Almacenamiento de reportes, avistamientos, usuarios, notificaciones, chats |
| **Firebase Storage** | Plan Blaze, bucket `sos-mascota-prod.appspot.com` | Fotografías de mascotas reportadas y avistadas |
| **Firebase Cloud Messaging** | FCM HTTP v1 | Notificaciones push de coincidencia y alertas comunitarias |
| **Firebase App Distribution** | Canal interno (internal testing) | Distribución del APK a voluntarios piloto de Tacna |

**Estimación de costos mensuales (Plan Blaze):**
* Cloud Firestore: Estimado S/. 15-50 PEN según volumen de operaciones (reportes, avistamientos, lecturas de chat).
* Firebase Storage: Estimado S/. 5-20 PEN según volumen de fotografías almacenadas.
* FCM: Sin costo (incluido en Firebase).

### 4.2 Hardware — Dispositivos de Usuario

**Dispositivos Móviles (Voluntarios y Dueños de Mascotas):**

| Parametro | Requisito Minimo | Recomendado |
| :--- | :--- | :--- |
| Sistema Operativo Android | Android 6.0 (API 23) | Android 10 o superior |
| RAM | 2 GB | 4 GB |
| Almacenamiento libre | 150 MB (APK + modelos TFLite) | 500 MB |
| Camara | 8 MP con autofoco | 12 MP o superior |
| GPS | GPS satelital basico | A-GPS + GLONASS |
| Conectividad | 3G / Wi-Fi | 4G LTE / Wi-Fi |

**Estacion de Desarrollo (Equipo):**

| Componente | Especificacion |
| :--- | :--- |
| Procesador | Intel Core i7 / AMD Ryzen 7 (3.5 GHz octa-core) |
| Memoria RAM | 16 GB DDR4/DDR5 |
| Almacenamiento | 512 GB SSD NVMe M.2 |
| Sistema Operativo | Windows 10/11 x64 |
| IDE | Visual Studio Code + extensiones Flutter/Dart |
| Flutter SDK | 3.29 o superior |

### 4.3 Software de Soporte

**Lenguajes y Frameworks:**
* Flutter SDK: 3.29+
* Dart SDK: 3.8.1
* Gradle: 8.0+ (Android build)
* Android SDK: API 34

**Herramientas de Build y Distribucion:**
* Firebase CLI 12.0+ — Despliegue de Firestore rules, Storage rules y App Distribution.
* GitHub Actions — Automatización de builds en la rama `UNIDAD-I`.
* `keytool` + keystore firmado — Firma del APK de producción.

**Monitoreo y Logging:**
* Firebase Crashlytics — Reporte automático de crashes en producción.
* Firebase Performance Monitoring — Métricas de latencia y rendimiento del APK.

### 4.4 Documentacion de Soporte

| Documento | Descripcion | Archivo |
| :--- | :--- | :--- |
| Manual de Instalacion Técnica | Configuración de Firebase, compilación y despliegue | `README.md` |
| Guia de Arquitectura | Patrón MVVM, flujo de datos, estructura de Firestore | `INFORME_LABORATORIO_01_REVISION_CODIGO.md` |
| Diccionario de Datos | Colecciones y esquema de Firestore | `DICCIONARIO_DE_DATOS_SOS_MASCOTA.md` |
| Plan de Riesgos | Riesgos identificados y estrategias de mitigacion | `PLAN_DE_RIESGOS_SOS_MASCOTA.md` |
| Plan de Mantenimiento | Proceso de modificacion conforme ISO/IEC 14764 | `PLAN_DE_MANTENIMIENTO_SOS_MASCOTA.md` |
| Manual de Usuario | Guia de uso para voluntarios y administradores | En preparación — Sprint 8 |

---

## 5. Capacitacion

### 5.1 Estrategia de Capacitacion

La capacitación se diseñó bajo el modelo de aprendizaje por roles, reconociendo que el administrador del sistema, los voluntarios de Tacna y los dueños de mascotas tienen necesidades y objetivos diferentes. El enfoque es **70% práctico y 30% teórico**, priorizando el aprendizaje mediante práctica supervisada.

**Objetivos Generales:**
* Capacitar al 100% de los usuarios antes del Go-Live.
* Asegurar competencia básica en las tareas críticas de rescate (registrar reporte, registrar avistamiento).
* Minimizar la curva de aprendizaje post-despliegue.
* Crear usuarios "campeones" en la comunidad de Tacna que puedan ayudar a nuevos voluntarios.

### 5.2 Programa de Capacitacion por Rol

#### Capacitacion para el Administrador del Sistema

**Participantes:** 1-2 personas
**Duracion total:** 8 horas (2 sesiones de 4 horas)
**Modalidad:** Presencial con acceso al sistema de producción

**Sesion 1 — Gestion de Usuarios y Moderacion (4 horas):**

| Horario | Tema |
| :---: | :--- |
| 09:00 - 09:30 | Introduccion al panel administrativo. Arquitectura MVVM y roles del sistema. |
| 09:30 - 10:30 | Gestion de usuarios — Creacion, modificacion de roles (`usuario` / `admin`), activacion y suspension de cuentas. |
| 10:45 - 12:00 | Moderacion de reportes — Revision de reportes de mascotas fraudulentos, eliminacion y bloqueo de publicaciones. |
| 13:00 - 14:00 | Gestion de notificaciones manuales desde el panel de administracion. |

**Sesion 2 — Estadisticas, Dashboard y Operaciones Avanzadas (4 horas):**

| Horario | Tema |
| :---: | :--- |
| 09:00 - 10:30 | Consulta del Dashboard estadistico — Metricas por especie, distrito y tasa de exito de rescates. |
| 10:45 - 12:00 | Administracion de Firestore — Exportaciones, backup y recuperacion de datos. |
| 13:00 - 14:00 | Escenarios practicos y resolucion de incidencias comunes. Evaluacion de conocimientos. |

**Material Entregado:**
* Manual del Administrador (impreso y digital en PDF).
* Guia de referencia rapida para resolución de incidencias comunes.
* Credenciales de acceso con rol `admin` al proyecto Firebase de produccion.

---

#### Capacitacion para Voluntarios y Duenos de Mascotas

**Participantes:** Grupos de 10-15 personas de la comunidad de Tacna
**Duracion total:** 2 horas por sesion
**Modalidad:** Presencial con dispositivos Android propios

**Agenda de Sesion de Capacitacion:**

| Tiempo | Tema |
| :---: | :--- |
| 0:00 - 0:15 | Introduccion a SOS Mascota — Objetivo del sistema y el sistema de PataCoins. |
| 0:15 - 0:30 | Registro de cuenta con DNI y verificacion de correo electronico. |
| 0:30 - 0:50 | Registro de una mascota perdida — Wizard de 3 pasos con toma de fotografia. |
| 0:50 - 1:10 | Registro de un avistamiento rapido con camara y GPS en campo. |
| 1:10 - 1:30 | Visualizacion del mapa interactivo, feed de reportes y uso de filtros. |
| 1:30 - 1:50 | Uso del chat privado, comentarios comunitarios y generacion del cartel PDF. |
| 1:50 - 2:00 | Sesion de preguntas y respuestas. Entrega de material de apoyo. |

**Material Entregado:**
* Guia rapida de uso (version impresa en una sola pagina A4).
* Codigo QR para descarga del APK desde Firebase App Distribution.
* Numero de contacto del equipo de soporte tecnico para incidencias.

### 5.3 Materiales de Capacitacion

| Material | Formato | Audiencia |
| :--- | :--- | :--- |
| Manual del Administrador | PDF + Impreso | Administrador del sistema |
| Guia rapida del Voluntario | PDF A4 impreso + QR | Voluntarios y duenos de mascotas |
| Video Tutorial — Registro de Reporte | MP4 (3 min) | Todos los usuarios |
| Video Tutorial — Registro de Avistamiento | MP4 (2 min) | Voluntarios |
| Video Tutorial — Uso del Panel Admin | MP4 (5 min) | Administrador |
| FAQ — Preguntas Frecuentes | PDF | Todos los usuarios |

---

## Anexo A: Checklist de Go-Live

La siguiente lista de verificacion debe completarse el dia del Go-Live antes de distribuir la aplicacion a los voluntarios de Tacna:

| N° | Verificacion | Estado |
| :---: | :--- | :---: |
| 1 | Proyecto Firebase de produccion (`sos-mascota-prod`) creado y configurado | [ ] |
| 2 | Reglas de seguridad de Firestore verificadas y desplegadas | [ ] |
| 3 | APK firmado con keystore de produccion compilado sin errores | [ ] |
| 4 | Modelos TFLite embebidos correctamente en el APK (`assets/models/`) | [ ] |
| 5 | Token Bearer de API RENIEC inyectado mediante `--dart-define` (no en codigo fuente) | [ ] |
| 6 | Servicio FCM configurado con claves HTTP v1 validas | [ ] |
| 7 | Backup completo de Firestore realizado antes del despliegue | [ ] |
| 8 | Suite de pruebas unitarias pasa al 100% (`flutter test` — 0 fallos) | [ ] |
| 9 | Cuenta de administrador creada con rol `admin` en Firestore | [ ] |
| 10 | APK disponible en Firebase App Distribution para descarga | [ ] |
| 11 | Material de capacitacion impreso y disponible para voluntarios | [ ] |
| 12 | Contactos de emergencia del equipo de desarrollo disponibles | [ ] |

---

*Documento elaborado como parte del Plan de Despliegue — Curso Construccion de Software II — Universidad Privada de Tacna — 2026.*
