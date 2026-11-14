# SOS Mascota — Base para el Documento de Configuración de Ambientes y Procedimiento de Despliegue

> **Cómo usar este archivo:** pásaselo completo a Antigravity, abierto sobre la carpeta del proyecto SOS Mascota. La **Parte 3** contiene las instrucciones que debe ejecutar. Su resultado será un informe `.md` más una carpeta de evidencias. Ese material se me devuelve para que yo redacte los entregables finales del trabajo (documento de configuración, procedimiento de despliegue, informe de investigación, anexos y presentación).

---

## PARTE 0 — Contexto del encargo

- **Proyecto:** SOS Mascota (`sos_mascotas`), aplicación móvil Flutter + Firebase para reportar, buscar y rescatar mascotas extraviadas en Tacna.
- **Asignatura:** Construcción de Software II — Universidad Privada de Tacna.
- **Trabajo:** *Diseño y Elaboración del Documento de Configuración de Ambientes y Procedimiento de Despliegue para una Solución de Software utilizando prácticas de CI, CD y DevOps.* Modalidad grupal.
- **Lo que se necesita de Antigravity:** todos los datos reales del proyecto que exige el PDF de la Parte 1, **sin omitir ningún apartado** (Partes I a IV y los 10 entregables).
- **Antecedentes ya existentes (para mantener coherencia):**
  - Ya existe un informe técnico previo (`INFORME_TECNICO_SOSMascota.md`, auditoría del 23/10/2026, rama `UNIDAD-I`, commit `feecec2`) y un Plan de Despliegue en Word basado en él. Si ese informe está en el repositorio, úsalo como línea base, pero **vuelve a verificar todo contra el código actual**, porque pudo haber cambiado.
  - **Cambio confirmado por el usuario:** la validación por DNI **ya no existe** en la app. No debe aparecer en ningún dato nuevo (ni la API `miapi.cloud`, ni `DNI_TOKEN`, ni la pantalla de validación). Verifica en el código si quedan restos y repórtalos.
- **Diferencia importante con el trabajo anterior:** la plantilla del docente está pensada para sistemas web (API REST, MySQL/PostgreSQL, Docker, AWS/Azure, Jenkins). SOS Mascota es **móvil y serverless (Firebase)**. Donde un elemento no aplique, no lo inventes: indica `NO APLICA` con una breve justificación y propón el equivalente real (por ejemplo, "Hosting AWS/Azure" → Firebase / Google Cloud).

---

## PARTE 1 — PDF del docente: `Trabajo_encargado_en_clase_CSW-2_Documento_de_Configuracion.pdf` (contenido íntegro)

### Configuración de Ambientes y Procedimiento de Despliegue para el Proyecto de Construcción de Software II

- **Asignatura:** Construcción de Software II
- **Unidad de Competencia:** Integración, despliegue, pruebas y gestión de la configuración de soluciones de software
- **Tipo de Actividad:** Trabajo de Investigación Aplicada y Documentación Técnica
- **Modalidad:** Grupal (Equipo de Proyecto)

### TÍTULO DEL TRABAJO
Diseño y Elaboración del Documento de Configuración de Ambientes y Procedimiento de Despliegue para una Solución de Software utilizando prácticas de Integración Continua (CI), Entrega Continua (CD) y DevOps

### CONTEXTUALIZACIÓN
En el curso de Construcción de Software II, los estudiantes desarrollan una solución de software funcional que integra los componentes construidos previamente en Construcción de Software I y los prepara para su despliegue en ambientes controlados y productivos.

Actualmente, las organizaciones demandan que los desarrolladores no solo construyan software, sino que también sean capaces de gestionar ambientes, automatizar despliegues, controlar versiones y garantizar la calidad del producto antes de su liberación.

Por ello, en esta actividad académica los estudiantes deberán investigar los conceptos relacionados con la gestión de ambientes y despliegue de software, para posteriormente diseñar y elaborar un Documento de Configuración de Ambientes y un Procedimiento de Despliegue, aplicados directamente al proyecto desarrollado durante el curso.

### COMPETENCIA DEL CURSO
Implementa, integra y despliega soluciones de software aplicando estándares de calidad, automatización, gestión de configuración y buenas prácticas DevOps para garantizar su correcta operación en diversos ambientes tecnológicos.

### RESULTADO DE APRENDIZAJE
Al finalizar la actividad, el estudiante será capaz de:
- Configurar ambientes de desarrollo, pruebas y producción.
- Gestionar versiones mediante herramientas de control de código fuente.
- Diseñar procedimientos de despliegue seguros y repetibles.
- Aplicar principios de DevOps e Integración Continua.
- Elaborar documentación técnica asociada al despliegue de aplicaciones.
- Gestionar riesgos relacionados con la liberación de software.

### OBJETIVO GENERAL
Elaborar el Documento de Configuración de Ambientes y el Procedimiento de Despliegue aplicados al proyecto de software desarrollado en Construcción de Software II, incorporando prácticas de integración continua, calidad y gestión de configuración.

### OBJETIVOS ESPECÍFICOS
1. Investigar los conceptos relacionados con la gestión de ambientes y despliegue de software.
2. Analizar la arquitectura tecnológica del proyecto desarrollado.
3. Definir la configuración técnica de los ambientes utilizados.
4. Diseñar un procedimiento formal de despliegue.
5. Implementar controles de calidad y seguridad durante la liberación de versiones.
6. Elaborar mecanismos de rollback y recuperación ante fallos.
7. Aplicar conceptos básicos de DevOps y automatización.

### CASO DE ESTUDIO
Cada equipo deberá utilizar la solución de software desarrollada durante las sesiones de clases del curso (proyecto implementado en clase y creado en Construcción de Software I).

Ejemplos del docente: Sistema Web de Gestión Académica; Sistema de Gestión Hospitalaria; Sistema de Ventas y Facturación; Plataforma E-Commerce; Sistema de Gestión de Biblioteca; Sistema de Inventario; Sistema de Reservas Online; **Aplicación Móvil de Delivery**; Sistema de Atención al Cliente.
*(Nuestro caso de estudio: Aplicación Móvil SOS Mascota.)*

---

### DESARROLLO DEL TRABAJO

#### PARTE I. INVESTIGACIÓN TEÓRICA

**Tema 1. Despliegue de Software.** Investigar:
- Concepto de despliegue.
- Importancia dentro del ciclo de vida del software.
- Estrategias de despliegue.
- Beneficios y riesgos.
- Despliegue manual y automatizado.

**Tema 2. Ambientes de Software**
- **Ambiente de Desarrollo (DEV):** definición; objetivos; herramientas utilizadas; configuración recomendada.
- **Ambiente de Integración (INT):** propósito; validación de integración; gestión de versiones.
- **Ambiente de Calidad (QA):** pruebas funcionales; pruebas de integración; pruebas de aceptación.
- **Ambiente de Preproducción (STAGING):** simulación de producción; pruebas finales.
- **Ambiente de Producción (PROD):** operación real; seguridad; monitoreo.

**Tema 3. Gestión de Configuración.** Investigar:
- Gestión de versiones.
- Control de cambios.
- Baselines.
- Trazabilidad.
- Gestión de artefactos.

**Tema 4. DevOps e Integración Continua.** Investigar:
- DevOps.
- Continuous Integration (CI).
- Continuous Delivery (CD).
- Continuous Deployment.
- Pipeline de despliegue.
- Automatización.

**Tema 5. Herramientas Modernas de Despliegue.** Analizar las funcionalidades de: Git, GitHub, GitLab, Azure DevOps, Jenkins, Docker, Kubernetes, SonarQube, Postman.

---

#### PARTE II. DOCUMENTO DE CONFIGURACIÓN DE AMBIENTES

**1. Información General**

| Campo | Descripción |
|---|---|
| Proyecto | Nombre de la solución |
| Curso | Construcción de Software II |
| Versión | 1.0 |
| Fecha | DD/MM/AAAA |
| Integrantes | Equipo del proyecto |
| Docente | Nombre del docente |

**2. Descripción del Proyecto.** Describir:
- Problema a resolver.
- Objetivo del sistema.
- Alcance.
- Usuarios involucrados.
- Tecnologías utilizadas.

**3. Arquitectura de la Solución.** Presentar:
- Diagrama de arquitectura.
- Componentes del sistema.
- Integraciones externas.
- Servicios utilizados.

Ejemplo del docente:
```text
Usuario
   │
   ▼
Frontend Web / Aplicación Móvil
   │
   ▼
API REST
   │
   ▼
Base de Datos
   │
   ▼
Servicios Externos
```

**4. Configuración de Ambientes**

*Ambiente DEV*

| Recurso | Configuración |
|---|---|
| Sistema Operativo | Windows / Linux |
| IDE | VS Code |
| Framework | Según proyecto |
| Base de Datos | MySQL / PostgreSQL |
| Contenedores | Docker |

*Ambiente QA*

| Recurso | Configuración |
|---|---|
| Servidor | Linux |
| Herramientas QA | Postman |
| Automatización | Jenkins |
| Base de Datos | Réplica QA |

*Ambiente STAGING* (en el PDF original el texto de la tabla aparece pegado: "Infraestructura CloudSSL Habilitado")

| Recurso | Configuración |
|---|---|
| Infraestructura | Cloud |
| SSL | Habilitado |
| Monitoreo | Implementado |

*Ambiente PROD*

| Recurso | Configuración |
|---|---|
| Hosting | AWS / Azure |
| Escalabilidad | Configurada |
| Backups | Programados |
| Seguridad | Hardening aplicado |

**5. Gestión de Versiones.** Definir:
- Modelo de ramas.
- Convenciones de commits.
- Versionado semántico.
- Flujo de aprobación.

Ejemplo del docente:
```text
main
├── develop
│
├── feature/login
├── feature/reportes
│
└── release/v1.0
```

**6. Seguridad de Ambientes.** Controles mínimos:
- MFA.
- Gestión de accesos.
- Firewall.
- Roles y permisos.
- Cifrado TLS.
- Respaldo de información.
- Gestión de vulnerabilidades.

---

#### PARTE III. PROCEDIMIENTO DE DESPLIEGUE

**Objetivo:** Establecer los pasos necesarios para desplegar la solución de software de forma segura y controlada.

**Alcance:** Aplica a DEV, QA, STAGING y PROD.

**Roles y Responsabilidades**

| Rol | Responsabilidad |
|---|---|
| Scrum Master / Líder | Autorizar despliegues |
| Desarrollador | Preparar versión |
| Tester | Validar calidad |
| DevOps | Ejecutar despliegue |
| DBA | Gestión de base de datos |
| Cliente | Aceptación final |

**Procedimiento General**
- **Fase 1: Preparación** — Consolidar cambios. Generar versión. Actualizar documentación.
- **Fase 2: Pruebas** — Ejecutar pruebas unitarias. Ejecutar pruebas funcionales. Resolver observaciones.
- **Fase 3: Aprobación** — Revisión técnica. Evaluación de riesgos. Aprobación formal.
- **Fase 4: Despliegue** — Publicación de artefactos. Configuración de servicios. Migración de datos.
- **Fase 5: Validación** — Smoke Test. Verificación funcional. Revisión de logs.
- **Fase 6: Cierre** — Actualización documental. Registro de evidencias. Lecciones aprendidas.

---

#### PARTE IV. ANEXOS OBLIGATORIOS

**Anexo A. Matriz RACI**

| Actividad | Desarrollador | QA | DevOps | Líder |
|---|---|---|---|---|
| Configuración | R | C | A | I |
| Pruebas | C | R | I | A |
| Despliegue | C | I | R | A |
| Validación | C | R | I | A |

**Anexo B. Checklist de Despliegue**
- *Pre-Despliegue:* ☐ Código aprobado. ☐ Pruebas completadas. ☐ Backups realizados. ☐ Documentación actualizada. ☐ Riesgos identificados.
- *Post-Despliegue:* ☐ Aplicación disponible. ☐ Servicios operativos. ☐ Base de datos validada. ☐ Usuario conforme.

**Anexo C. Plan de Rollback.** Debe incluir:
- Escenarios de falla.
- Responsables.
- Procedimiento de reversión.
- Tiempo objetivo de recuperación.
- Validación posterior.

**Anexo D. Pipeline CI/CD.** Diseñar un flujo similar al siguiente:
```text
Git Commit
   │
   ▼
Build
   │
   ▼
Pruebas Automáticas
   │
   ▼
Análisis de Calidad
   │
   ▼
Deploy QA
   │
   ▼
Deploy STAGING
   │
   ▼
Deploy PROD
```

---

### ENTREGABLES FINALES
1. Informe de investigación (10 a 15 páginas).
2. Documento de Configuración de Ambientes.
3. Procedimiento de Despliegue.
4. Diagrama de Arquitectura.
5. Pipeline CI/CD.
6. Matriz RACI.
7. Plan de Rollback.
8. Evidencias del repositorio Git.
9. Evidencias de pruebas.
10. Presentación de sustentación (15 minutos).

---

## PARTE 2 — Mapa de cobertura (qué entregable cubre cada parte y quién lo produce)

| # | Entregable del PDF | Qué aporta Antigravity (datos reales) | Quién redacta el entregable final |
|---|---|---|---|
| 1 | Informe de investigación (10–15 págs.) | Estado real del proyecto frente a cada tema de la Parte I (qué se aplica y qué no) | Claude (la teoría y su vínculo con SOS Mascota) |
| 2 | Documento de Configuración de Ambientes | Secciones 1 a 6 de la Parte II con datos reales | Claude |
| 3 | Procedimiento de Despliegue | Comandos y pasos por fase y por ambiente, verificados | Claude |
| 4 | Diagrama de Arquitectura | Componentes, flujos e integraciones reales + borrador en Mermaid | Claude (versión final) |
| 5 | Pipeline CI/CD | Estado actual y borrador de `deploy.yml` | Claude (versión final) |
| 6 | Matriz RACI | Equipo real y autores del repositorio | Claude |
| 7 | Plan de Rollback | Escenarios y comandos de reversión verificados | Claude |
| 8 | Evidencias del repositorio Git | Salidas de comandos Git guardadas en archivos | Antigravity (genera) + usuario (capturas) |
| 9 | Evidencias de pruebas | Salidas de `flutter test`, `flutter analyze`, etc. | Antigravity (genera) + usuario (capturas) |
| 10 | Presentación de sustentación (15 min) | Resumen de hallazgos | Claude (al final, sobre el material anterior) |

---

## PARTE 3 — INSTRUCCIONES PARA ANTIGRAVITY

> **Rol:** eres un ingeniero DevOps/QA que analiza el repositorio de **SOS Mascota** para recolectar, **sin omitir nada**, la información que pide el PDF de la Parte 1. Tu salida alimentará el Documento de Configuración de Ambientes y el Procedimiento de Despliegue del curso Construcción de Software II.

### Reglas obligatorias
1. **No inventes datos.** Si algo no existe, escribe `NO ENCONTRADO`; si no aplica a una app móvil serverless, escribe `NO APLICA` con una línea de justificación y el equivalente real; si es una sugerencia tuya, márcala como `RECOMENDACIÓN`.
2. Indica la **ruta del archivo** (y línea si es posible) de donde sacas cada dato.
3. **Nunca incluyas secretos** (claves, tokens, contraseñas, keystores, contenido de `service_account.json`, `.env`). Solo nombres de variables y su propósito. Si ves una credencial real en el código, repórtala como hallazgo **sin copiarla**.
4. **Solo lectura sobre el código fuente.** No modifiques `lib/`, `android/`, `ios/`, `test/` ni configuraciones. Todo lo que generes va en una carpeta nueva `entrega/` en la raíz del repositorio (ver estructura abajo).
5. **Vuelve a verificar el estado actual** (puede haber cambiado desde la auditoría anterior): flavors, proyectos Firebase, `service_account.json`, reglas de Firestore/Storage, Crashlytics, CI/CD, pruebas.
6. **DNI:** la validación por DNI ya no existe. Confirma en el código si quedan referencias (`dni`, `miapi.cloud`, `DNI_TOKEN`) y repórtalas en la sección N; no las incluyas como funcionalidad.
7. Responde **en español**.

### Estructura de salida

Crea esta estructura:
```text
entrega/
├── INFORME_CONFIGURACION_SOSMascota.md      (informe principal, secciones A–O)
├── arquitectura.mmd                         (diagrama Mermaid de la arquitectura)
├── pipeline_propuesto.yml                   (borrador de GitHub Actions)
└── evidencias/
    ├── git/        (salidas de comandos Git, ver sección L)
    ├── pruebas/    (salidas de pruebas y análisis, ver sección M)
    └── LEEME_capturas_pendientes.md         (lista de capturas que debe tomar el usuario)
```

### Contenido obligatorio de `INFORME_CONFIGURACION_SOSMascota.md`

Usa **exactamente** estas secciones y, dentro de cada una, responde todos los puntos.

**A. Información general** *(PDF Parte II, §1)*
- Nombre del proyecto, curso (Construcción de Software II), versión del documento (1.0), fecha de hoy.
- **Integrantes:** obtenlos de `git shortlog -sne --all` y de la documentación del repo (README, créditos). Indica nombres y cantidad de commits por autor.
- Docente: `PENDIENTE DE COMPLETAR POR EL USUARIO` (si no aparece en el repo).

**B. Descripción del proyecto** *(§2)*
- Problema que resuelve, objetivo del sistema, alcance (funcionalidades **realmente implementadas hoy**, verificadas en `lib/`), usuarios involucrados (usuario común, administrador, colaboradores/rescatistas, etc.; confírmalo con los roles del código y de Firestore) y tecnologías utilizadas con versiones exactas (Flutter, Dart, JDK, Gradle, AGP, Kotlin, dependencias clave de `pubspec.yaml`).

**C. Arquitectura de la solución** *(§3 + Entregable 4)*
- **Diagrama de arquitectura** en Mermaid, guardado en `entrega/arquitectura.mmd` y pegado también en el informe. Debe seguir la idea del ejemplo del docente adaptada a la realidad: Usuario → App móvil Flutter (capas MVVM) → servicios Firebase (Auth, Firestore, Storage, FCM) → servicios externos (OpenStreetMap, Google Sign-In, etc.). Incluye el modelo de IA local (TFLite) dentro de la app.
- **Componentes del sistema** (tabla: componente, ruta en el repo, responsabilidad).
- **Integraciones externas** y **servicios utilizados** (tabla: servicio, para qué se usa, dónde se configura, si es de pago/plan gratuito).
- Aclara qué parte de la plantilla (API REST, base relacional) **no aplica** y por qué (arquitectura serverless / BaaS).

**D. Configuración de ambientes** *(§4)*
Para **cada ambiente** completa las tablas con la estructura del PDF y añade dos columnas: *Estado actual* (`EXISTE` / `NO EXISTE` / `PARCIAL`) y *Evidencia/ruta*.
- **DEV:** Sistema operativo, IDE (verifica `.vscode/`, `.idea/`, README), Framework, Base de datos, Contenedores (¿hay `Dockerfile`/`docker-compose`? si no, `NO APLICA` + justificación).
- **INT (Integración):** el PDF lo pide en la Parte I (Tema 2) aunque no en la Parte II. Indica si existe o cómo se cubre hoy (por ejemplo, la rama `develop` o un workflow de CI) y qué se recomienda.
- **QA:** Servidor, Herramientas QA (¿Postman, colecciones, otra? busca `*.postman_collection.json`), Automatización (¿Jenkins/GitHub Actions? hoy), Base de datos de QA (¿réplica o proyecto Firebase separado?).
- **STAGING:** Infraestructura, SSL/TLS, Monitoreo (qué hay y qué falta).
- **PROD:** Hosting (Firebase/Google Cloud, plan Spark o Blaze si se puede determinar), Escalabilidad, Backups (programados o no), Seguridad (hardening aplicado: reglas, App Check, ProGuard/R8, etc.).
- Matriz resumen por ambiente: proyecto Firebase, `google-services.json`, flavors, applicationId, variables y cómo se inyectan, canal de distribución. Verifica si **ya existen** flavors `dev/qa/prod` o proyectos Firebase separados.

**E. Gestión de versiones** *(§5)*
- **Modelo de ramas actual:** salida de `git branch -a`; describe el uso real de `main`, `UNIDAD-I/II/III` y cualquier `develop`/`feature/*`/`release/*`.
- **Propuesta** alineada al ejemplo del docente (`main`, `develop`, `feature/*`, `release/v1.0`) y su equivalencia con las ramas actuales.
- **Convención de commits:** analiza `git log` y resume el formato usado (ej. `feat:`, `fix:`, `docs:`), con 5 ejemplos reales (sin datos sensibles).
- **Versionado semántico:** versión actual en `pubspec.yaml` (`1.0.0+1`) y cómo se aplicaría MAJOR.MINOR.PATCH+build; tags existentes (`git tag`).
- **Flujo de aprobación:** pull requests, revisores, protección de ramas (si no se puede verificar desde el repo, anótalo como pregunta al usuario) y propuesta de flujo.

**F. Seguridad de ambientes** *(§6)*
Tabla con los 7 controles mínimos del PDF: **MFA, Gestión de accesos, Firewall, Roles y permisos, Cifrado TLS, Respaldo de información, Gestión de vulnerabilidades.** Para cada uno: *Estado actual*, *Evidencia (ruta)* y *Acción recomendada*, interpretados para Firebase/Google Cloud y GitHub (por ejemplo: MFA en cuentas de GitHub y Google Cloud; IAM del proyecto Firebase; reglas de Firestore/Storage y App Check como equivalentes de firewall; HTTPS obligatorio; exportaciones de Firestore; `flutter pub outdated` y revisión de dependencias). Incluye los hallazgos vigentes: `service_account.json` en `assets/`, reglas permisivas, `storage.rules` ausente, `google-services.json` rastreado, `.gitignore`, permisos del `AndroidManifest.xml`.

**G. Gestión de configuración** *(Parte I, Tema 3 aplicada al proyecto)*
Describe cómo se manejan hoy en SOS Mascota: **gestión de versiones, control de cambios** (issues/PR), **baselines** (tags, commits de referencia; propón una baseline para v1.0.0), **trazabilidad** (commit ↔ issue ↔ versión; ¿existe `CHANGELOG`, documentación de requisitos?) y **gestión de artefactos** (dónde viven APK/AAB, `pubspec.lock`, releases de GitHub).

**H. DevOps, CI/CD y automatización** *(Parte I, Tema 4 + Anexo D + Entregable 5)*
- Estado actual: `NO ENCONTRADO` o descripción de `.github/workflows/*`, Fastlane, Codemagic, etc.
- **Pipeline propuesto** que respete el flujo del Anexo D: *Git Commit → Build → Pruebas Automáticas → Análisis de Calidad → Deploy QA → Deploy STAGING → Deploy PROD*. Para cada etapa indica: herramienta/comando real (`flutter pub get`, `flutter build apk/appbundle`, `flutter test`, `flutter analyze`, análisis de calidad con SonarQube u otra opción viable, `firebase appdistribution:distribute`, Play Console/tracks, etc.), condición de disparo, ambiente destino, secretos necesarios (solo nombres) y puerta de aprobación manual antes de PROD.
- Guarda el borrador ejecutable en `entrega/pipeline_propuesto.yml` y márcalo como `PROPUESTA` (no lo actives en `.github/workflows`).
- Explica qué significa en este proyecto Continuous Integration, Continuous Delivery y Continuous Deployment (cuál sí se aplicaría y cuál no, y por qué en una app de tienda).

**I. Herramientas de despliegue** *(Parte I, Tema 5)*
Tabla para **Git, GitHub, GitLab, Azure DevOps, Jenkins, Docker, Kubernetes, SonarQube y Postman** con columnas: *¿Se usa hoy?* · *Evidencia en el repo* · *¿Aplica a SOS Mascota?* · *Uso recomendado / justificación de por qué no aplica*.

**J. Procedimiento de despliegue** *(Parte III)*
- **Objetivo y alcance** (DEV, QA, STAGING, PROD) adaptados al proyecto.
- **Roles y responsabilidades** (Scrum Master/Líder, Desarrollador, Tester, DevOps, DBA, Cliente) asignados a los integrantes reales del equipo; el rol DBA se interpreta como administración de Firestore/Firebase; "Cliente" como docente/comité o usuario final. Si no se conocen nombres: `PENDIENTE DE COMPLETAR POR EL USUARIO`.
- **Las 6 fases del PDF**, cada una con acciones concretas, comandos exactos verificados y evidencia que deja, y **diferenciando por ambiente (DEV, QA, STAGING, PROD)** cuando cambie algo:
  1. Preparación (consolidar cambios, generar versión, actualizar documentación)
  2. Pruebas (unitarias, funcionales, resolver observaciones)
  3. Aprobación (revisión técnica, evaluación de riesgos, aprobación formal)
  4. Despliegue (publicación de artefactos, configuración de servicios, **migración de datos** — indica si aplica; Firestore no tiene migraciones, pero sí reglas e índices)
  5. Validación (Smoke Test con casos reales del proyecto, verificación funcional, revisión de logs)
  6. Cierre (actualización documental, registro de evidencias, lecciones aprendidas)
- **Casos de humo vigentes:** lista solo los flujos que existen hoy en la app (inicio de sesión, registro, creación de reporte, avistamientos, mapa, chat, notificaciones, panel admin, carga de modelos TFLite). **No incluyas DNI.**

**K. Anexos obligatorios** *(Parte IV)*
- **Anexo A. Matriz RACI:** parte de las 4 actividades del PDF (Configuración, Pruebas, Despliegue, Validación) y añade, si corresponde, *Aprobación* y *Rollback*. Columnas: Desarrollador, QA, DevOps, Líder (y opcionalmente Cliente). Asigna con nombres reales o `PENDIENTE`. Verifica que cada actividad tenga **un solo A**.
- **Anexo B. Checklist de despliegue:** *Pre-despliegue* (código aprobado, pruebas completadas, backups realizados, documentación actualizada, riesgos identificados) y *Post-despliegue* (aplicación disponible, servicios operativos, base de datos validada, usuario conforme), con la verificación concreta de SOS Mascota para cada ítem.
- **Anexo C. Plan de rollback:** debe incluir los 5 puntos del PDF: **escenarios de falla** (app con crash, reglas rotas, fallo de notificaciones, pérdida de integridad en Firestore, fallo de firma o rechazo de tienda), **responsables**, **procedimiento de reversión** con comandos verificados (detener rollout en Play Console, hotfix con `versionCode` mayor, reversión de reglas con `firebase deploy --only firestore:rules`, restauración con `gcloud firestore import`, Remote Config), **tiempo objetivo de recuperación (RTO)** por escenario (márcalos como `PROPUESTA`, el equipo debe confirmarlos) y **validación posterior**.
- **Anexo D. Pipeline CI/CD:** referencia a la sección H y al archivo `pipeline_propuesto.yml`, más un diagrama Mermaid del flujo.

**L. Evidencias del repositorio Git** *(Entregable 8)*
Ejecuta y guarda la salida **completa** en `entrega/evidencias/git/` (un archivo `.txt` por comando):
`git remote -v` · `git status` · `git branch -a` · `git tag` · `git log --oneline --graph --decorate --all -n 80` · `git shortlog -sne --all` · `git log --stat -n 10` · `.gitignore` · estructura de carpetas (`tree` de 3 niveles) · listado de archivos de configuración de despliegue (`pubspec.yaml`, `android/app/build.gradle.kts`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`, etc.; **sin secretos**).
En el informe incluye una tabla *Evidencia → archivo → qué demuestra*.

**M. Evidencias de pruebas** *(Entregable 9)*
Ejecuta y guarda en `entrega/evidencias/pruebas/`: `flutter doctor -v` · `flutter pub get` · `flutter analyze --no-pub` · `flutter test` (salida completa, incluidas las fallas) · `flutter test --coverage` si es posible (resumen de cobertura por carpeta) · `flutter pub outdated`. Si algo falla (por ejemplo el conflicto `image`/`archive`), guarda el error tal cual y explica causa y solución probable.
En el informe: tabla con *Prueba, comando, resultado (aprobadas/falladas), archivo de evidencia*, el inventario de pruebas existentes y los casos de humo candidatos.
Crea también `entrega/evidencias/LEEME_capturas_pendientes.md` con la **lista de capturas de pantalla que el usuario debe tomar a mano** (Firebase Console por proyecto, GitHub Actions/Issues/PR, Play Console o App Distribution si existen, app corriendo en emulador, resultado de `flutter test`), indicando para cada una qué debe verse.

**N. Cambios respecto a la auditoría anterior y restos de DNI**
- Tabla comparativa *Hallazgo anterior → estado hoy* (flavors, proyectos Firebase, `service_account.json`, token hardcodeado, reglas de Firestore, `storage.rules`, Crashlytics, CI/CD, suite de pruebas rota, permisos del manifiesto).
- Resultado de la búsqueda de referencias a DNI en el código y archivos de configuración (ruta y línea), para poder eliminarlas.

**O. Hallazgos, riesgos y datos pendientes**
- Tabla `Riesgo | Impacto | Severidad | Mitigación` (riesgos de la liberación, requisito del resultado de aprendizaje "Gestionar riesgos relacionados con la liberación de software").
- Lista de **preguntas que el usuario debe responder**: nombres de integrantes y roles, nombre del docente, ventana de despliegue, si hay cuenta de Play Console, si hay plan Blaze, si las ramas están protegidas en GitHub, si hay proyectos Firebase separados, quién es el "cliente" de aceptación final.

### Cierre del informe
Termina con un **Resumen ejecutivo** (máximo 10 líneas) y una **lista de verificación de cobertura** que confirme, apartado por apartado del PDF (Parte I tema 1–5 aplicados, Parte II §1–6, Parte III, Anexos A–D, Entregables 1–10), si quedó `COMPLETO`, `PARCIAL` o `PENDIENTE DEL USUARIO`.

---

## PARTE 4 — Qué haré yo con el material

Cuando me devuelvas `entrega/INFORME_CONFIGURACION_SOSMascota.md` y el contenido o resumen de `entrega/evidencias/`, redactaré:

1. **Informe de investigación (10–15 páginas):** Temas 1 a 5 de la Parte I, con la teoría explicada y vinculada a SOS Mascota.
2. **Documento de Configuración de Ambientes:** Parte II completa (§1–6) con datos reales.
3. **Procedimiento de Despliegue:** Parte III con las 6 fases por ambiente.
4. **Anexos A–D:** RACI, checklist, plan de rollback y pipeline CI/CD.
5. **Diagrama de arquitectura** y **pipeline** en versión final.
6. **Presentación de sustentación de 15 minutos** sobre todo lo anterior.

Todo en el formato que prefieras (Word con formato APA, como el plan anterior, o el que pida el docente) y coherente con el Plan de Despliegue que ya tienes.
