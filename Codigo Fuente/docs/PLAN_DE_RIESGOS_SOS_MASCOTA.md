# UNIVERSIDAD PRIVADA DE TACNA
## FACULTAD DE INGENIERÍA
### Escuela Profesional de Ingeniería de Sistemas

---

# PLAN DE RIESGOS
## Sistema SOS Mascota — Fase de Construcción

**Proyecto:** *"Aplicación móvil colaborativa para mejorar la efectividad en la asistencia de mascotas perdidas con participación de voluntarios en la ciudad de Tacna, 2026"*
**Nombre del Sistema:** *SOS Mascota* (`sos_mascotas`)

**Curso:** Construcción de Software II
**Docente:** Mag. Ricardo Eduardo Valcárcel Alvarado
**Integrantes:**
- Chite Quispe Brian Danilo (2021070015)
- Anampa Pancca David Jordan (2022074268)

**Tacna – Perú, 2026**

---

## Tabla de Contenido

1. [Introducción](#1-introducción)
2. [Identificación de Riesgos](#2-identificación-de-riesgos)
3. [Riesgos de Seguridad](#3-riesgos-de-seguridad)
4. [Riesgos Operacionales](#4-riesgos-operacionales)
5. [Riesgos Técnicos](#5-riesgos-técnicos)
6. [Riesgos de Integración](#6-riesgos-de-integración)
7. [Riesgos de Negocio](#7-riesgos-de-negocio)
8. [Resumen de Riesgos](#8-resumen-de-riesgos)
9. [Plan de Acción](#9-plan-de-acción)
10. [Seguimiento y Revisión](#10-seguimiento-y-revisión)

---

## 1. Introducción

El presente documento establece el Plan de Riesgos del sistema **SOS Mascota**, una aplicación móvil colaborativa desarrollada en Flutter con backend en Firebase (Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging) e inferencia local de visión artificial mediante TensorFlow Lite, orientada a la localización de mascotas extraviadas en la ciudad de Tacna.

Este plan identifica, analiza y propone estrategias de mitigación para los riesgos asociados al desarrollo, despliegue y operación del sistema durante la fase de construcción del curso de Construcción de Software II. El plan de riesgos permite anticipar problemas potenciales y establecer medidas preventivas y correctivas para minimizar su impacto en el proyecto.

---

## 2. Identificación de Riesgos

Los riesgos del sistema se han categorizado en cinco áreas principales: seguridad, operacionales, técnicos, de integración y de negocio. Cada riesgo ha sido evaluado considerando su probabilidad de ocurrencia y el impacto que tendría en el sistema si se materializa.

### Matriz de Clasificación de Riesgos

| Nivel de Riesgo | Probabilidad | Impacto | Prioridad |
| :--- | :--- | :--- | :--- |
| **Alto** | Alta o Media | Crítico o Alto | Acción Inmediata |
| **Medio** | Media o Baja | Alto o Medio | Monitoreo Activo |
| **Bajo** | Baja | Medio o Bajo | Monitoreo Pasivo |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 3. Riesgos de Seguridad

Los riesgos de seguridad representan amenazas a la confidencialidad, integridad y disponibilidad de los datos del sistema. Estos riesgos pueden resultar en pérdida de información de los voluntarios y dueños de mascotas, acceso no autorizado o interrupción del servicio de rescate comunitario.

---

### Riesgo R-001: Exposición del Token Bearer de la API DNI RENIEC

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Alta — El token se encontraba codificado en texto plano en `app.dart` |
| **Impacto** | Crítico — Consumo no autorizado del servicio de consulta de identidad |
| **Nivel de Riesgo** | Alto |
| **Descripción** | El token Bearer para autenticar peticiones a la API RENIEC (`miapi.cloud`) se encontraba declarado como variable global en texto plano dentro del código fuente. Un actor malicioso con acceso al repositorio podría extraer las credenciales y consumir el servicio de forma fraudulenta, generando costos al equipo y exponiendo datos de ciudadanos. |
| **Mitigación** | El token fue extraído de `app.dart` y encapsulado en la clase `AppConfig`, con soporte para inyección mediante `--dart-define=DNI_BEARER_TOKEN=xxx` en tiempo de compilación. El valor de producción nunca se almacena en el repositorio de código fuente. |
| **Responsable** | Equipo de Desarrollo |
| **Estado** | Resuelto — Auditoria de Código Limpio (Regla 4, R4.1) |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-002: Ausencia de Límite de Intentos de Autenticación

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — Ataques automatizados de fuerza bruta son comunes |
| **Impacto** | Alto — Compromiso de cuentas de voluntarios y dueños de mascotas |
| **Nivel de Riesgo** | Alto |
| **Descripción** | Sin límites de intentos fallidos, un atacante puede intentar múltiples combinaciones de correo electrónico y contraseña para acceder a cuentas de voluntarios. Las cuentas comprometidas podrían publicar reportes falsos de mascotas o suprimir alertas legítimas, afectando directamente la efectividad del sistema comunitario. |
| **Mitigación** | Firebase Authentication implementa un mecanismo nativo de bloqueo temporal tras múltiples intentos fallidos (`too-many-requests`). El `login_vm.dart` captura este código de excepción tipado (`FirebaseAuthException`) y muestra el mensaje informativo: "Demasiados intentos. Espere unos minutos antes de reintentar". |
| **Responsable** | Equipo de Desarrollo |
| **Estado** | En Monitoreo — Firebase gestiona el rate limiting nativo |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-003: Reglas de Seguridad Permisivas en Firestore

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Baja — Requiere configuración incorrecta de reglas |
| **Impacto** | Crítico — Acceso no autorizado a datos de mascotas, usuarios y avistamientos |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Si las reglas de seguridad (`firestore.rules`) no están correctamente configuradas, cualquier usuario autenticado podría leer o modificar reportes de otros usuarios, alterar los contadores de PataCoins fraudulentamente, o acceder al panel administrativo sin privilegios de rol `admin`. |
| **Mitigación** | Las reglas de seguridad en `firestore.rules` restringen el acceso por `uid` autenticado y por campo `rol`. Solo usuarios con `rol == 'admin'` pueden acceder a colecciones administrativas. Las reglas se validan con el emulador local de Firestore antes de publicar cambios. |
| **Responsable** | Administrador de Infraestructura — Equipo de Desarrollo |
| **Estado** | Pendiente de auditoría formal — se recomienda prueba de penetración básica |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-004: Acceso No Autorizado a Cuenta Suspendida

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Baja — Requiere vulnerabilidad en el mecanismo de verificación |
| **Impacto** | Alto — Usuario bloqueado accede y publican reportes fraudulentos |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Si el `auth_wrapper.dart` no evalúa en tiempo real el campo `activo` del documento de usuario en Firestore, un usuario cuya cuenta haya sido suspendida por moderación podría permanecer con sesión activa y continuar interactuando con la comunidad. |
| **Mitigación** | El `AuthWrapper` usa un `StreamBuilder` sobre el documento del usuario en Firestore. Cualquier cambio al campo `activo` se propaga en tiempo real: si el administrador cambia `activo = false`, la stream notifica inmediatamente al cliente y Firebase Auth invoca `signOut()` automáticamente. |
| **Responsable** | Equipo de Desarrollo |
| **Estado** | Resuelto — Implementado en `auth_wrapper.dart` con stream reactivo |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 4. Riesgos Operacionales

Los riesgos operacionales se relacionan con la disponibilidad y funcionamiento continuo del sistema. Incluyen dependencias de servicios externos, problemas de rendimiento y fallos en la infraestructura de Firebase.

---

### Riesgo R-005: Dependencia de Servicios Externos (Firebase, FCM, API DNI)

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — Los servicios en la nube tienen SLAs de 99.9% pero pueden tener interrupciones |
| **Impacto** | Alto — Pérdida de funcionalidad crítica de registro y comunicación |
| **Nivel de Riesgo** | Alto |
| **Descripción** | El sistema depende de Firebase Authentication (autenticación), Cloud Firestore (base de datos), Firebase Cloud Messaging (notificaciones push), Cloud Storage (fotografías) y la API de RENIEC (`miapi.cloud`) para validación de DNI. Si alguno de estos servicios falla, partes críticas del sistema dejan de funcionar, impidiendo reportar mascotas perdidas o recibir alertas de avistamiento. |
| **Mitigación** | Se implementa manejo de excepciones exhaustivo en todas las operaciones de red con mensajes de error informativos. El modo degradado permite visualizar reportes en caché cuando Firestore es inaccesible. Las notificaciones locales (`flutter_local_notifications`) garantizan alertas mínimas sin FCM. La consulta de DNI presenta un aviso claro cuando la API no está disponible. |
| **Responsable** | Equipo de Desarrollo y Operaciones |
| **Estado** | En Mitigación Parcial — Manejo de excepciones implementado |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-006: Costos Imprevistos de Firebase en Plan Blaze

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — Los costos escalan con el número de usuarios y lecturas de Firestore |
| **Impacto** | Medio — Impacto financiero en el proyecto académico |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Firebase Firestore (plan Blaze pay-as-you-go) cobra por operaciones de lectura, escritura y eliminación. Si el número de voluntarios activos en Tacna crece rápidamente, el algoritmo de similitud coseno que descarga y compara fotografías podría generar costos de Storage y Firestore superiores al presupuesto del proyecto. |
| **Mitigación** | Se implementa caché de URLs de imagen con `CachedNetworkImage` para minimizar descargas repetidas. El algoritmo de cotejo descarga temporalmente las fotos en memoria sin persistirlas nuevamente. Se configuran alertas de facturación en la consola de Firebase cuando los costos superen el 80% del presupuesto mensual estimado. |
| **Responsable** | Administrador del Proyecto |
| **Estado** | En Monitoreo — Alertas de facturación configuradas |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-007: Pérdida de Datos por Fallo en Firestore

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Baja — Firebase tiene alta disponibilidad y replicación automática |
| **Impacto** | Crítico — Pérdida permanente de reportes de mascotas y avistamientos históricos |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Aunque improbable, una eliminación accidental o un fallo catastrófico en Firestore podría resultar en la pérdida del historial de reportes, avistamientos y saldos de PataCoins de los voluntarios de Tacna. Estos datos son críticos para la coordinación de rescates en curso. |
| **Mitigación** | Se programan exportaciones periódicas de Firestore hacia Cloud Storage mediante Firebase Admin. Los saldos de PataCoins se mantienen con trazabilidad completa de transacciones. Se recomienda configurar copias de seguridad automatizadas diarias de las colecciones `reportes`, `avistamientos` y `usuarios`. |
| **Responsable** | Administrador de Infraestructura |
| **Estado** | Pendiente — Se debe configurar política de backup automático antes del despliegue en producción |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 5. Riesgos Técnicos

Los riesgos técnicos están relacionados con la calidad del código, la arquitectura del sistema y la capacidad técnica del equipo para mantener y extender el sistema SOS Mascota.

---

### Riesgo R-008: Deuda Técnica por Violación de Reglas de Código Limpio

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Alta — Identificada y documentada mediante auditoría formal |
| **Impacto** | Medio — Dificulta el mantenimiento y la adición de nuevas funcionalidades |
| **Nivel de Riesgo** | Medio |
| **Descripción** | La auditoría de código realizada en el Laboratorio 01 detectó 39 hallazgos críticos distribuidos en 9 áreas de código limpio: duplicación de lógica TFLite y de subida de imágenes, variables globales mutables, ausencia de comentarios DartDoc, valores numéricos mágicos (9.0 km, 0.5 similitud coseno, 224x224 píxeles) y bloques `if` sin llaves en ViewModels. |
| **Mitigación** | Se aplicaron las 9 reglas de código limpio durante la fase de refactorización del Laboratorio 01: extracción de `ImagenUtil`, centralización de `_buildNotifData`, encapsulación en `AppConfig` y `NavigationService`, tipado de excepciones Firebase, y reemplazo de `print()` con `debugPrint()`. La suite de pruebas unitarias pasa al 100%. |
| **Responsable** | Equipo de Desarrollo — Auditor Senior |
| **Estado** | Resuelto — 39 hallazgos corregidos y validados mediante `flutter test` |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-009: Degradación de Rendimiento del Algoritmo de Similitud Coseno

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — El sistema puede crecer con el aumento de reportes activos |
| **Impacto** | Alto — Degradación de la experiencia del voluntario y retraso en notificaciones |
| **Nivel de Riesgo** | Medio |
| **Descripción** | El algoritmo de cotejo biométrico en `avistamiento_vm.dart` descarga temporalmente cada fotografía de reporte activo, extrae sus embeddings con TFLite y calcula la similitud coseno. Si hay más de 100 reportes activos en la ciudad de Tacna, el tiempo de ejecución podría superar los 10 segundos, bloqueando la retroalimentación al voluntario. |
| **Mitigación** | El radio de búsqueda euclidiana de 9.0 km (`AppConfig.radioKm`) pre-filtra los reportes geográficamente, reduciendo el conjunto de comparación. Se recomienda implementar comparación asíncrona en paralelo usando `compute()` de Flutter para aislar la carga del hilo principal de renderizado. |
| **Responsable** | Equipo de Desarrollo — AI / Mobile Engineer |
| **Estado** | En Monitoreo — Implementar `compute()` como mejora futura |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-010: Falta de Cobertura de Pruebas Unitarias

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Alta — La cobertura actual cubre únicamente el módulo de avistamiento |
| **Impacto** | Medio — Bugs en módulos críticos podrían llegar a producción |
| **Nivel de Riesgo** | Medio |
| **Descripción** | La suite de pruebas actual cubre exclusivamente el ViewModel de avistamiento (`avistamiento_vm_test.dart`) con 3 casos de prueba. Los módulos de autenticación, registro con DNI, algoritmo de similitud coseno y administración de usuarios carecen de cobertura de prueba automatizada, aumentando el riesgo de regresiones. |
| **Mitigación** | Se recomienda ampliar la cobertura al mínimo del 70% en los siguientes sprints. Los módulos prioritarios son: `login_vm.dart` (autenticación y roles), `reporte_vm.dart` (guardado de reporte y notificación push), y `servicio_tflite.dart` (clasificación de imágenes y extracción de embeddings). |
| **Responsable** | Equipo de Desarrollo — QA Engineer |
| **Estado** | En Progreso — Objetivo: 70% de cobertura en siguiente iteración |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 6. Riesgos de Integración

Los riesgos de integración se relacionan con la comunicación entre los diferentes componentes del sistema y servicios externos, incluyendo Firebase, API RENIEC y el motor TFLite.

---

### Riesgo R-011: Cambios en la API RENIEC (`miapi.cloud`)

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — APIs de terceros pueden cambiar sin aviso previo |
| **Impacto** | Alto — El registro de nuevos voluntarios quedaría bloqueado |
| **Nivel de Riesgo** | Medio |
| **Descripción** | El módulo de registro (`registro_vm.dart`) depende del endpoint REST de `miapi.cloud` para obtener nombres y apellidos del ciudadano a partir de su DNI. Si la API cambia su contrato (endpoints, formato JSON, política de autenticación Bearer), el registro de nuevos usuarios en SOS Mascota quedaría completamente bloqueado. |
| **Mitigación** | El servicio de consulta de DNI está abstraído en la clase `ApiDniServicio`, que actúa como capa de abstracción. Al cambiar la API, solo se modifica esa clase sin afectar el resto del sistema. Se monitorean los avisos de la plataforma `miapi.cloud` y se tiene preparado un formulario de ingreso manual de nombres como fallback. |
| **Responsable** | Equipo de Desarrollo |
| **Estado** | En Monitoreo — Capa de abstracción `ApiDniServicio` implementada |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-012: Incompatibilidades de TensorFlow Lite con Nuevas Versiones de Flutter

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — El ecosistema Flutter actualiza frecuentemente su SDK |
| **Impacto** | Alto — La validación de imágenes y el cotejo biométrico quedarían inoperativos |
| **Nivel de Riesgo** | Medio |
| **Descripción** | El paquete `tflite_flutter` tiene dependencias nativas específicas para cada plataforma (Android ABI, iOS arm64). Una actualización del Flutter SDK o del compilador Dart puede introducir incompatibilidades binarias que impidan cargar los modelos `.tflite` en el dispositivo, deshabilitando el filtro de imágenes y el algoritmo de similitud. |
| **Mitigación** | Se fija la versión de `tflite_flutter` en `pubspec.yaml` y se evitan actualizaciones automáticas hasta que se valide compatibilidad. Antes de cualquier actualización de SDK, se ejecuta la suite de pruebas en emulador y en dispositivo físico Android 13. Se mantiene un registro de las versiones testeadas. |
| **Responsable** | Equipo de Desarrollo — AI / Mobile Engineer |
| **Estado** | En Monitoreo — Versión fijada en pubspec.yaml |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-013: Fallos en Despacho de Notificaciones FCM

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — Las notificaciones push dependen del estado del token FCM |
| **Impacto** | Medio — El dueño de la mascota no recibe alerta de posible coincidencia |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Si el token FCM del dispositivo del dueño ha caducado, el usuario desinstalò y reinstalò la app, o el dispositivo estuvo apagado por más de un mes, el token almacenado en Firestore puede ser inválido. El sistema intentaría enviar la notificación push de "Posible Coincidencia" sin éxito, sin informar al dueño sobre el avistamiento. |
| **Mitigación** | El token FCM se actualiza automáticamente en Firestore cada vez que el usuario inicia sesión correctamente (`LoginVM.loginYDeterminarRuta()`). El sistema también implementa notificaciones visibles dentro de la app mediante la colección `notificaciones` en Firestore, garantizando que el dueño visualice la alerta al abrir la aplicación aunque no haya recibido el push. |
| **Responsable** | Equipo de Desarrollo — Backend Lead |
| **Estado** | En Mitigación — Token FCM actualizado en cada login |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 7. Riesgos de Negocio

Los riesgos de negocio se relacionan con la aceptación del sistema por parte de la comunidad de voluntarios, el cumplimiento de los objetivos de rescate de mascotas en Tacna y la sostenibilidad del proyecto.

---

### Riesgo R-014: Baja Adopción por Parte de Voluntarios de Tacna

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — Depende de la usabilidad y la difusión del sistema |
| **Impacto** | Alto — El sistema no cumple su propósito social de rescate comunitario |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Si la interfaz del aplicativo resulta difícil de usar para personas sin experiencia técnica, el proceso de registro de avistamiento supera los 30 segundos en situaciones de movilidad, o los voluntarios no comprenden el valor del sistema de PataCoins, pueden rechazar la aplicación y volver a métodos informales de difusión en redes sociales. |
| **Mitigación** | El flujo de avistamiento rápido está optimizado para captura en menos de 15 segundos. El sistema de PataCoins gamifica la participación con recompensas visibles (10 puntos por avistamiento). Se realizan pruebas de usabilidad con usuarios reales de Tacna antes del despliegue. Se ofrecen manuales simplificados en español para usuarios de baja experiencia técnica. |
| **Responsable** | Equipo de Desarrollo y Gestión del Proyecto |
| **Estado** | En Progreso — Pruebas de usabilidad programadas antes del despliegue |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-015: Publicación de Reportes o Avistamientos Fraudulentos

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — El sistema es público y accesible para cualquier ciudadano de Tacna |
| **Impacto** | Alto — Desinformación en la comunidad y pérdida de confianza en el sistema |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Un actor malicioso podría registrar reportes de mascotas inexistentes, publicar avistamientos con coordenadas falsas, o reclamar PataCoins de forma fraudulenta. La comunidad de Tacna perdería confianza en el sistema si sus alertas conducen a búsquedas infructuosas. |
| **Mitigación** | El clasificador de IA (TFLite) bloquea la subida de imágenes que no corresponden a mascotas (confianza < 60%). El sistema de comentarios permite que la comunidad señale reportes sospechosos. El panel administrativo habilita al administrador para suspender cuentas infractoras y eliminar reportes fraudulentos. Se implementa verificación de identidad obligatoria mediante DNI en el registro. |
| **Responsable** | Equipo de Desarrollo — Administrador del Sistema |
| **Estado** | En Mitigación — TFLite activo como primera barrera de validación |

*Fuente: Elaboración propia del equipo de trabajo.*

---

### Riesgo R-016: Falta de Mantenimiento Continuo Post-Entrega Académica

| Atributo | Descripción |
| :--- | :--- |
| **Probabilidad** | Media — El proyecto puede no tener recursos asignados al cierre del curso |
| **Impacto** | Alto — El sistema se vuelve obsoleto o inseguro por dependencias desactualizadas |
| **Nivel de Riesgo** | Medio |
| **Descripción** | Sin mantenimiento continuo después de la entrega académica, el sistema puede acumular bugs, quedar inseguro por dependencias desactualizadas (TFLite, Firebase SDK, Flutter), o dejar de funcionar cuando cambien las APIs externas (RENIEC, FCM HTTP v1). La comunidad de voluntarios de Tacna dependería de una plataforma sin soporte. |
| **Mitigación** | Se documenta el Plan de Mantenimiento (Laboratorio complementario) con actividades correctivas, adaptativas, perfectivas y preventivas. El código fuente en GitHub (`David-Anampa/CONSTRUCCION_SOFTWARE_II_ANAMPA_CHITE`) queda disponible para mantenedores futuros. Las dependencias del proyecto se encuentran fijadas en versiones estables en `pubspec.lock`. |
| **Responsable** | Administración del Proyecto |
| **Estado** | Pendiente — Plan de mantenimiento formal en preparación |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 8. Resumen de Riesgos

A continuación se presenta el resumen consolidado de todos los riesgos identificados para el sistema SOS Mascota, organizados por nivel de prioridad y área afectada.

### Resumen de Riesgos por Prioridad

| ID | Riesgo | Nivel | Area | Estado |
| :--- | :--- | :---: | :--- | :--- |
| **R-001** | Exposición del Token Bearer de API RENIEC | Alto | Seguridad | Resuelto |
| **R-002** | Ausencia de Límite de Intentos de Autenticación | Alto | Seguridad | En Monitoreo |
| **R-005** | Dependencia de Servicios Externos (Firebase, FCM, API DNI) | Alto | Operacional | En Mitigación |
| **R-003** | Reglas de Seguridad Permisivas en Firestore | Medio | Seguridad | Pendiente |
| **R-004** | Acceso No Autorizado a Cuenta Suspendida | Medio | Seguridad | Resuelto |
| **R-006** | Costos Imprevistos de Firebase en Plan Blaze | Medio | Operacional | En Monitoreo |
| **R-007** | Pérdida de Datos por Fallo en Firestore | Medio | Operacional | Pendiente |
| **R-008** | Deuda Técnica por Violación de Código Limpio | Medio | Técnico | Resuelto |
| **R-009** | Degradación de Rendimiento de Similitud Coseno | Medio | Técnico | En Monitoreo |
| **R-010** | Falta de Cobertura de Pruebas Unitarias | Medio | Técnico | En Progreso |
| **R-011** | Cambios en la API RENIEC | Medio | Integración | En Monitoreo |
| **R-012** | Incompatibilidades de TFLite con Flutter SDK | Medio | Integración | En Monitoreo |
| **R-013** | Fallos en Despacho de Notificaciones FCM | Medio | Integración | En Mitigación |
| **R-014** | Baja Adopción por Voluntarios de Tacna | Medio | Negocio | En Progreso |
| **R-015** | Publicación de Reportes Fraudulentos | Medio | Negocio | En Mitigación |
| **R-016** | Falta de Mantenimiento Post-Entrega Académica | Medio | Negocio | Pendiente |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 9. Plan de Acción

El plan de acción establece las actividades prioritarias para mitigar los riesgos identificados. Las acciones se organizan por urgencia y recursos requeridos.

### Acciones Prioritarias Inmediatas (Sprint Actual)

| Acción | Riesgo Relacionado | Responsable | Plazo |
| :--- | :---: | :--- | :---: |
| Configurar reglas de seguridad estrictas en Firestore por colección y rol | R-003 | Administrador de Infraestructura | 3 días |
| Configurar política de backup automático diario de colecciones críticas | R-007 | Administrador de Infraestructura | 1 semana |
| Ampliar suite de pruebas unitarias a módulos `login_vm` y `reporte_vm` | R-010 | Equipo de Desarrollo | 1 semana |
| Implementar `compute()` en Flutter para la similitud coseno asíncrona | R-009 | AI / Mobile Engineer | 2 semanas |

*Fuente: Elaboración propia del equipo de trabajo.*

### Acciones de Monitoreo Continuo

| Acción | Riesgo Relacionado | Frecuencia | Responsable |
| :--- | :---: | :---: | :--- |
| Monitorear costos de Firebase y Cloud Storage | R-006 | Semanal | Administrador del Proyecto |
| Revisar estado de la API RENIEC y cambios de contrato | R-011 | Mensual | Desarrollador Senior |
| Evaluar rendimiento del algoritmo de cotejo con volumen creciente | R-009 | Mensual | AI Engineer |
| Revisar dependencias desactualizadas en `pubspec.yaml` | R-008, R-012 | Trimestral | Equipo de Desarrollo |
| Recopilar feedback de voluntarios sobre usabilidad | R-014 | Mensual | Gestor del Proyecto |

*Fuente: Elaboración propia del equipo de trabajo.*

---

## 10. Seguimiento y Revisión

El plan de riesgos debe revisarse periódicamente para identificar nuevos riesgos, actualizar la evaluación de los riesgos existentes, y verificar la efectividad de las medidas de mitigación implementadas.

Se recomienda realizar una revisión completa del plan al inicio de cada Sprint (cada 7 días durante la fase de construcción), o cuando ocurran cambios significativos en el sistema como actualizaciones del Flutter SDK, cambios en las APIs de Firebase, o incrementos sustanciales en la base de usuarios voluntarios de Tacna.

Durante las revisiones, se debe:
* Actualizar la columna de **Estado** en la matriz de riesgos.
* Evaluar el avance de las acciones de mitigación programadas.
* Documentar nuevos riesgos identificados durante la iteración.
* Ajustar las estrategias según el contexto operativo actual.

Los nuevos riesgos identificados deben documentarse siguiendo el mismo formato de ficha individual establecido en este documento, asignando un identificador secuencial en el rango R-017 en adelante.

---

*Documento elaborado como parte del Laboratorio de Gestión de Riesgos — Curso Construcción de Software II — Universidad Privada de Tacna — 2026.*
