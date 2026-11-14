# CRONOGRAMA DEL PROYECTO — SOS MASCOTA

**Curso:** Construcción de Software II — UPT
**Proyecto:** Aplicación móvil colaborativa para mejorar la asistencia de mascotas perdidas en Tacna (Flutter + Firebase + TensorFlow Lite)
**Integrantes:**
- **Brian** — Chite Quispe Brian Danilo
- **David** — Anampa Pancca David Jordan

**Estructura:** 14 semanas (S1–S14) · 3 iteraciones · Ubicación: **LAB F** (laboratorio)
**Formato:** ¿QUÉ? · ¿POR QUÉ? · ¿CUÁNDO? · ¿DÓNDE? · ¿QUIÉN? · ¿CÓMO?

> **Leyenda:** 🟨 Iteración 01 · 🟩 Iteración 02 · 🟫 Iteración 03 · 🟪 Documentos transversales · ⬜ sin actividad

## Requerimientos por iteración

| Iteración | Semanas | Requerimientos funcionales |
| :---: | :---: | :--- |
| **U1** | S1–S5 | RF-001 Autenticación · RF-002 Registro con DNI · RF-003 Recuperar contraseña · RF-004 Verificación de correo · RF-005 Reporte de mascota · RF-006 Validación de imagen con IA |
| **U2** | S6–S10 | RF-007 Feed y filtros · RF-008 Avistamiento GPS · RF-009 Coincidencia coseno · RF-010 Mapa interactivo · RF-014 Cartel PDF · RF-015 Perfil y PataCoins |
| **U3** | S11–S14 | RF-011 Notificaciones push · RF-012 Comentarios · RF-013 Chat · RF-016 Panel admin · RF-017 Dashboard estadístico |

---

## ITERACIÓN 01 (S1–S5) — Seguridad, cuenta y reportes

| ¿QUÉ? | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | S11 | S12 | S13 | S14 | ¿DÓNDE? | ¿QUIÉN? |
| :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Revisión de código (U1)** | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian |
| **Especificaciones funcionales (U1)** | ⬜ | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | David |
| **Pruebas de software (U1)** | ⬜ | ⬜ | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian |
| **Plan de iteración U1** | ⬜ | ⬜ | ⬜ | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | David |
| **Implementación de Iteración 01** | 🟨 | 🟨 | 🟨 | 🟨 | 🟨 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian y David |

### Detalle U1

| ¿QUÉ? | ¿POR QUÉ? | ¿CÓMO? |
| :--- | :--- | :--- |
| **Revisión de código (U1)**<br>`auth_servicio.dart`, `login_vm.dart`, `registro_vm.dart`, `recuperar_vm.dart`, `reporte_vm.dart`, `usuario.dart`, `reporte_mascota.dart`, `servicio_tflite.dart`, `imagen_util.dart`, `pantalla_login.dart`, `pantalla_registro.dart`, `pantalla_reporte_mascota.dart` | Se requiere comparar la versión producida en Construcción de Software I con la actual. | Se compara el código fuente de la versión anterior con la actual y se registran las modificaciones: mejoras de código, comentarios y funcionalidad. |
| **Especificaciones funcionales (U1)**<br>RF-001 a RF-006 | Se requiere detallar las especificaciones en lenguaje natural. | Se redactan las especificaciones de los requerimientos funcionales tratados en la iteración 01. |
| **Pruebas de software (U1)**<br>RF-001 a RF-006 | Se requiere realizar las pruebas funcionales. | Se ejecutan las pruebas funcionales de todos los casos de uso de los requerimientos implementados en la iteración 01. |
| **Plan de iteración U1**<br>RF-001 a RF-006 | Se requiere realizar un plan para la iteración. | Se elabora el plan de la iteración 01 con los requerimientos funcionales RF-001 a RF-006. |

---

## ITERACIÓN 02 (S6–S10) — Avistamientos, mapa e inteligencia artificial

| ¿QUÉ? | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | S11 | S12 | S13 | S14 | ¿DÓNDE? | ¿QUIÉN? |
| :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Revisión de código (U2)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟩 | 🟩 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | David |
| **Especificaciones funcionales (U2)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟩 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian |
| **Pruebas de software (U2)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟩 | 🟩 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | David |
| **Plan de iteración U2** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟩 | 🟩 | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian |
| **Implementación de Iteración 02** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian y David |

### Detalle U2

| ¿QUÉ? | ¿POR QUÉ? | ¿CÓMO? |
| :--- | :--- | :--- |
| **Revisión de código (U2)**<br>`avistamiento_vm.dart`, `avistamiento.dart`, `pantalla_avistamiento.dart`, `pantalla_ver_reportes.dart`, `pantalla_mapa_interactivo.dart`, `pantalla_mapa_osm.dart`, `pantalla_mis_reportes.dart`, `pantalla_detalle_completo.dart`, `perfil_vm.dart`, `pantalla_perfil.dart` | Se requiere comparar la versión producida en Construcción de Software I con la actual. | Se compara el código fuente de la versión anterior con la actual y se registran las modificaciones. |
| **Especificaciones funcionales (U2)**<br>RF-007 a RF-010, RF-014, RF-015 | Se requiere detallar las especificaciones en lenguaje natural. | Se redactan las especificaciones de los requerimientos funcionales tratados en la iteración 02. |
| **Pruebas de software (U2)**<br>RF-007 a RF-010, RF-014, RF-015 | Se requiere realizar las pruebas funcionales. | Se ejecutan las pruebas funcionales de los casos de uso implementados en la iteración 02. |
| **Plan de iteración U2**<br>RF-007 a RF-010, RF-014, RF-015 | Se requiere realizar un plan para la iteración. | Se elabora el plan de la iteración 02 con los requerimientos funcionales de la iteración. |

---

## DOCUMENTOS TRANSVERSALES

| ¿QUÉ? | ¿POR QUÉ? | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | S11 | S12 | S13 | S14 | ¿DÓNDE? | ¿QUIÉN? | ¿CÓMO? |
| :--- | :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :--- |
| **Calendarización del proyecto** | Se requiere hacer el cronograma de todas las actividades relacionadas con el proyecto en el marco de Construcción de Software II. | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟪 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | Brian | Se describen las actividades del proyecto con el método 5W2H (QUÉ, POR QUÉ, CUÁNDO, DÓNDE, QUIÉN y CÓMO). En "CUÁNDO" se toma la duración en semanas establecida en el anexo del calendario. |
| **Catálogo de Casos de Prueba** | Se requiere realizar el catálogo de casos de prueba para establecer las pruebas que se realizarán en el transcurso del proyecto. | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟪 | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | LAB F | David | Se detallan los casos de prueba asignados por requerimiento (RF-001 a RF-017). |
| **Plan de Despliegue** | Se requiere un plan de despliegue que proporcione los recursos necesarios para el propio despliegue del proyecto. | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟪 | 🟪 | 🟪 | ⬜ | ⬜ | LAB F | Brian | Se detallan las actividades, recursos, cronograma y procedimientos para la implementación en un entorno real (Firebase Hosting/Firestore y APK Android). |
| **Plan de Configuración de Software** | Se requiere mantener el orden y la trazabilidad del código, permitiendo que el equipo colabore de manera eficiente y sin sobrescribir trabajo. | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟪 | 🟪 | ⬜ | ⬜ | LAB F | David | Se implementan herramientas de control de versiones (Git/GitHub), una estrategia de ramas, la estructura del proyecto y convenciones para commits y documentación. |

---

## ITERACIÓN 03 (S11–S14) — Comunidad, administración y mantenimiento

| ¿QUÉ? | S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | S11 | S12 | S13 | S14 | ¿DÓNDE? | ¿QUIÉN? |
| :--- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| **Revisión de código (U3)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | ⬜ | ⬜ | ⬜ | LAB F | Brian |
| **Especificaciones funcionales (U3)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | ⬜ | ⬜ | LAB F | David |
| **Pruebas de software (U3)** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | ⬜ | LAB F | Brian |
| **Plan de iteración U3** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | LAB F | David |
| **Plan de Prueba** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | 🟫 | LAB F | Brian |
| **Plan de Mantenimiento** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | 🟫 | LAB F | David |
| **Implementación de Iteración 03** | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🟫 | 🟫 | 🟫 | 🟫 | LAB F | Brian y David |

### Detalle U3

| ¿QUÉ? | ¿POR QUÉ? | ¿CÓMO? |
| :--- | :--- | :--- |
| **Revisión de código (U3)**<br>`notificacion_servicio.dart`, `notificacion_vm.dart`, `pantalla_chat.dart`, `pantalla_chats_activos.dart`, `pantalla_comentarios.dart`, `replies_page.dart`, `admin_vm.dart`, `adminusuario_vm.dart`, `AdminReportes_vm.dart`, `AdminEstadisticas_vm.dart`, `pantalla_inicio_admin.dart` | Se requiere comparar la versión producida en Construcción de Software I con la actual. | Se compara el código fuente de la versión anterior con la actual y se registran las modificaciones. |
| **Especificaciones funcionales (U3)**<br>RF-011, RF-012, RF-013, RF-016, RF-017 | Se requiere detallar las especificaciones en lenguaje natural. | Se redactan las especificaciones de los requerimientos funcionales tratados en la iteración 03. |
| **Pruebas de software (U3)**<br>RF-011, RF-012, RF-013, RF-016, RF-017 | Se requiere realizar las pruebas funcionales. | Se ejecutan las pruebas funcionales de los casos de uso implementados en la iteración 03. |
| **Plan de iteración U3**<br>RF-011, RF-012, RF-013, RF-016, RF-017 | Se requiere realizar un plan para la iteración. | Se elabora el plan de la iteración 03 con los requerimientos funcionales de la iteración. |
| **Plan de Prueba** | Se requiere asegurar que la aplicación funcione correctamente y cumpla los requisitos, detectando errores a tiempo y garantizando calidad, usabilidad y confiabilidad. | Mediante el diseño y ejecución de casos de prueba unitarios, de integración, de sistema y de usabilidad, de forma manual y automatizada, para validar la funcionalidad y la experiencia completa del usuario. |
| **Plan de Mantenimiento** | Se requiere corregir fallos no detectados y adaptar el software a cambios del entorno y nuevas funcionalidades solicitadas, asegurando su utilidad continua. | Se establece un protocolo para recibir y priorizar reportes de errores, planificando ciclos de actualización de librerías y desarrollo de parches y versiones menores basados en el feedback de la comunidad estudiantil. |

---

## Carga de trabajo por integrante

| Integrante | U1 | U2 | U3 | Transversales |
| :--- | :--- | :--- | :--- | :--- |
| **Brian** | Revisión de código, Pruebas | Especificaciones, Plan de iteración | Revisión de código, Pruebas, Plan de Prueba | Calendarización, Plan de Despliegue |
| **David** | Especificaciones, Plan de iteración | Revisión de código, Pruebas | Especificaciones, Plan de iteración, Plan de Mantenimiento | Catálogo de Casos de Prueba, Plan de Configuración |
| **Ambos** | Implementación 01 | Implementación 02 | Implementación 03 | — |

> **Notas:**
> - El cronograma original usaba 4–5 responsables. Aquí las tareas se reparten de forma alterna entre Brian y David.
> - Los nombres de archivos y los requerimientos (RF-001 a RF-017) salen del código de `lib/` y de `PLANIFICACION_SPRINTS_SOS_MASCOTA.md`.
> - Si tu docente fijó otra distribución de semanas o iteraciones, solo hay que mover las marcas 🟨🟩🟫🟪.
