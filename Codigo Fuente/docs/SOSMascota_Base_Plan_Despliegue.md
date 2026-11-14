# SOSMascota — Base de conocimiento para el Plan de Despliegue

> **Cómo usar este archivo:** pásaselo completo a Antigravity (abierto sobre la carpeta del proyecto SOSMascota). La **Parte 4** contiene las instrucciones que debe ejecutar. Su resultado será un **informe técnico `.md`** que se me devuelve para que yo redacte el **Plan de Despliegue final**, el cual podrá aplicar cualquier persona (o el propio autor) para desplegar la app.

---

## PARTE 0 — Contexto del encargo

- **Proyecto:** SOSMascota — aplicación móvil.
- **Materia:** Ingeniería de Software — Unidad 2, Semana 03: *Despliegue, testabilidad y QA*.
- **Qué pidió el docente:** un **plan de despliegue detallado** para poner en marcha el sistema SOSMascota. El docente explicó los **ambientes de sistemas** (tabla de la Parte 1) y pidió que se detalle, **sobre todo, los dos primeros ambientes: Desarrollo y Pruebas/QA**. Esas dos filas son el foco principal del plan; Preproducción y Producción deben incluirse igualmente, pero con el nivel de detalle que corresponda al proyecto real.
- **Objetivo final del plan:** que sea **ejecutable y reproducible** por otra persona (paso a paso, con comandos, rutas, variables, evidencias y rollback), no solo teórico.
- **Entregable final (lo hago yo, Claude):** Plan de Despliegue de SOSMascota siguiendo la estructura de la plantilla (Parte 2), alimentado con los datos reales del proyecto (informe de Antigravity, Parte 4) y con los conceptos de la clase (Parte 3).

---

## PARTE 1 — Imagen del docente: "Ambientes de sistemas"

**Sección 1 · DESPLIEGUE — Ambientes de sistemas**

| Ambiente | Propósito | Datos |
|---|---|---|
| Desarrollo | Codificación y pruebas unitarias | Ficticios |
| Pruebas / QA | Pruebas funcionales e integración | Prueba controlados |
| Preproducción | Ensayo igual a producción | Copia anonimizada |
| Producción | Operación para usuarios finales | Reales |

**Énfasis del docente:** las **dos primeras filas (Desarrollo y Pruebas/QA)** deben quedar detalladas al máximo en el plan de despliegue.

---

## PARTE 2 — PDF 1: `Plan_de_Despliegue_SW.pdf` (plantilla del Plan de despliegue — contenido íntegro)

**Encabezado del documento:** *Plan de despliegue de software • Documento adaptable y sujeto a aprobación*

**DOCUMENTO DE GESTIÓN TECNOLÓGICA**
**PLAN DE DESPLIEGUE DE SOFTWARE**
Modelo de implementación y puesta en producción | Versión 1.0

Campos de cabecera a completar:
- Proyecto / sistema: [Nombre del sistema]
- Organización: [Nombre]
- Fecha: [dd/mm/aaaa]
- Responsable del plan: [Nombre / cargo]
- Ambiente de destino: [Producción / otro]

### 1. Propósito y descripción
Establecer un procedimiento controlado, reproducible y verificable para liberar e implementar una versión de software en el ambiente objetivo, minimizando interrupciones, errores de configuración, pérdida de datos y riesgos de seguridad. El plan define las condiciones previas, la secuencia de ejecución, las responsabilidades, las pruebas, la comunicación y las acciones de reversión.

### 2. Objetivos
- Asegurar que la versión autorizada se instale con sus dependencias y configuraciones correctas.
- Mantener la disponibilidad, integridad, confidencialidad y trazabilidad durante el cambio.
- Validar los procesos críticos antes de habilitar el sistema a usuarios finales.
- Disponer de un procedimiento de retorno a la versión estable ante fallas relevantes.

### 3. Alcance y supuestos
Incluye preparación de entornos, respaldo, distribución de artefactos, migración de datos cuando aplique, despliegue, pruebas técnicas y funcionales, monitoreo, soporte inicial y cierre. **No incluye** nuevas funcionalidades ni cambios de alcance no aprobados.

**Supuestos:** existen versión candidata identificada, repositorio de artefactos, acceso aprobado a ambientes, responsables disponibles y ventana de cambio autorizada. Los campos entre corchetes deben completarse según el proyecto.

### 4. Estrategia de despliegue
Se recomienda un despliegue gradual por ambiente: **desarrollo → pruebas/calidad → preproducción → producción**. Para producción podrá utilizarse estrategia por fases, blue-green o rolling, según la arquitectura y tolerancia a indisponibilidad. La modalidad definitiva deberá documentarse y aprobarse antes de ejecutar el cambio.

| Elemento | Definición por completar |
|---|---|
| Tipo de despliegue | [Gradual / rolling / blue-green / directo] |
| Versión / paquete | [Etiqueta, hash o identificador inmutable] |
| Servicios afectados | [Aplicación, API, BD, integraciones] |
| Ventana programada | [Fecha, hora inicio y fin; zona horaria] |
| Interrupción esperada | [Sin interrupción / hasta X minutos] |
| Criterio para avanzar | [Pruebas y métricas mínimas aceptadas] |

### 5. Roles y responsabilidades

| Rol | Responsabilidad principal |
|---|---|
| Líder de despliegue | Coordina, registra hitos, verifica aprobaciones y decide escalamiento. |
| Equipo de desarrollo / DevOps | Prepara artefactos, scripts y automatizaciones; ejecuta la liberación. |
| Infraestructura / operaciones | Valida capacidad, accesos, red, certificados, monitoreo y respaldos. |
| Calidad (QA) / usuario clave | Ejecuta pruebas de humo y valida procesos críticos. |
| Seguridad de la información | Revisa controles, vulnerabilidades relevantes y tratamiento de excepciones. |
| Propietario del servicio / CAB | Autoriza ventana, impacto aceptable y decisión final de puesta en marcha. |

### 6. Prerrequisitos y condiciones de entrada
- Solicitud de cambio registrada y aprobada; análisis de impacto y riesgos disponible.
- Código y versión congelados; compilación y pruebas automatizadas satisfactorias.
- Paquete almacenado en repositorio controlado, con integridad verificable.
- Secretos, variables, certificados y privilegios revisados sin exponer credenciales.
- Respaldos y restauración verificados; plan de reversión probado cuando sea viable.
- Capacidad, conectividad, dependencias externas y observabilidad comprobadas.
- Plan de comunicaciones enviado a los involucrados y usuarios afectados.

### 7. Procedimiento operativo de implementación

| Fase | Actividad / descripción | Evidencia esperada |
|---|---|---|
| 1. Preparación | Validar checklist, alcance, responsables, ventana y versión aprobada. | Acta / ticket de autorización |
| 2. Salvaguarda | Generar respaldo de base de datos, configuración y versión previa; confirmar restauración. | Registro y ubicación del respaldo |
| 3. Prechequeo | Comprobar capacidad, conectividad, permisos, certificados y estado de servicios. | Checklist técnico |
| 4. Ejecución | Desplegar artefactos aprobados; aplicar variables y migraciones con orden documentado. | Logs de pipeline / comandos |
| 5. Verificación | Revisar salud, endpoints, integraciones, registros, pruebas de humo y datos. | Resultados de pruebas |
| 6. Habilitación | Restablecer tráfico o accesos y comunicar disponibilidad a los usuarios. | Aprobación de habilitación |
| 7. Estabilización | Monitorear errores, latencia, consumo, incidentes y satisfacción operativa. | Tablero / bitácora de monitoreo |
| 8. Cierre | Documentar resultado, desviaciones, evidencias y conformidad del propietario. | Acta de cierre |

### 8. Cronograma referencial

| Hito | Momento referencial | Responsable |
|---|---|---|
| Revisión y aprobación | T−5 a T−1 días | Líder / propietario |
| Respaldo y prechequeos | T−60 a T−15 min | Operaciones |
| Implementación | T0 a T+45 min | DevOps |
| Pruebas y decisión go/no-go | T+45 a T+75 min | QA / propietario |
| Monitoreo reforzado | Primeras 24–48 horas | Operaciones |
| Cierre formal | T+2 días | Líder de despliegue |

*Los tiempos son referenciales y deben ajustarse a la complejidad del sistema, dependencias y duración real de las tareas.*

### 9. Pruebas y criterios de aceptación
- **Disponibilidad:** servicios, URL y componentes críticos reportan estado saludable.
- **Funcionalidad:** autenticación, operaciones principales e integraciones completan pruebas de humo.
- **Datos:** migraciones conciliadas; no existen errores de integridad ni pérdida de registros.
- **Seguridad:** perfiles y accesos apropiados, comunicaciones cifradas, sin secretos expuestos.
- **Rendimiento:** latencia, tasa de errores y consumo dentro de umbrales aprobados.
- **Operación:** bitácoras, alertas, paneles y respaldos funcionan correctamente.

**Criterio de aceptación final:** el propietario del servicio y QA confirman los resultados y autorizan la continuidad de la nueva versión. Registrar evidencias y excepciones aceptadas.

### 10. Riesgos, contingencia y reversión

| Riesgo | Mitigación / respuesta |
|---|---|
| Incompatibilidad de configuración | Validar parámetros por ambiente; aplicar checklist y control de versiones. |
| Falla de migración o corrupción | Respaldo íntegro, migración ensayada, verificación y restauración documentada. |
| Indisponibilidad o degradación | Despliegue fuera de horario crítico; monitoreo y rollback por umbrales. |
| Problemas de permisos o seguridad | Accesos mínimos temporales y validaciones de seguridad antes de habilitar. |
| Fallas de integraciones | Pruebas de conectividad y coordinación con terceros. |

### 11. Procedimiento de rollback
**Activadores:** incumplimiento de criterios de aceptación, error crítico no recuperable en la ventana autorizada, pérdida de integridad de datos, incidente de seguridad o degradación superior al umbral aprobado.

1. El líder declara "no-go" o rollback, registra la hora y comunica la decisión.
2. Se bloquean nuevos cambios y, cuando corresponde, se desvía o detiene el tráfico.
3. Se restaura el artefacto y la configuración previos; si hubo cambios de esquema/datos, se aplica el procedimiento de reversión validado y se evalúa el impacto de transacciones posteriores.
4. Se verifican salud, consistencia e integraciones y se comunica la recuperación.
5. Se abre incidente o problema, se conservan evidencias y se reprograma el despliegue.

**Importante:** no ejecutar restauración de base de datos sin verificar previamente la posible pérdida de transacciones posteriores al respaldo; esta decisión debe ser autorizada por el propietario del servicio.

### 12. Plan de comunicación y soporte

| Momento | Destinatarios | Mensaje / canal |
|---|---|---|
| Antes | Áreas usuarias, soporte y directivos | Aviso de ventana, impacto previsto y contacto / correo o ticket |
| Inicio | Equipo técnico y responsables | Confirmación de inicio / canal operativo |
| Fin o reversión | Usuarios y partes interesadas | Resultado, restricciones y hora efectiva / correo |
| Estabilización | Mesa de ayuda y operaciones | Estado, incidentes y seguimiento / tablero o reunión |

### 13. Evidencias y entregables
- Ticket de cambio y aprobación, versión exacta y registro de artefactos.
- Checklists firmados, respaldos, scripts y resultados de ejecución.
- Pruebas funcionales, técnicas y de seguridad con sus resultados.
- Métricas iniciales, incidencias, decisiones go/no-go y acta de cierre.
- Manual operativo, actualización de inventario y lecciones aprendidas.

### 14. Matriz breve de aprobación

| Instancia | Nombre y cargo | Fecha / conformidad |
|---|---|---|
| Elaborado por | [Completar] | [Completar] |
| Revisado por (técnico/seguridad) | [Completar] | [Completar] |
| Autorizado por (propietario/CAB) | [Completar] | [Completar] |

### Anexo A. Lista de verificación go/no-go
- [ ] Cambio aprobado y ventana confirmada
- [ ] Respaldo comprobado y rollback disponible
- [ ] Paquete y dependencias validados
- [ ] Equipos y contactos de soporte disponibles
- [ ] Pruebas críticas ejecutadas y sin fallos bloqueantes
- [ ] Monitoreo activo y alertas verificadas
- [ ] Autorización expresa para habilitar producción

---

## PARTE 3 — PDF 2: `Semana_03_U2_Plan_de_Despliegue.pdf` (presentación de clase — contenido íntegro, por diapositiva)

**Título:** INGENIERÍA DE SOFTWARE — *Despliegue, testabilidad y QA*
Subtítulo: Plan de despliegue, ambientes de sistemas, criterios de testabilidad y participación de QA en el desarrollo.

### Agenda — Tres temas
1. **Despliegue:** plan, áreas de sistemas y ambientes
2. **Testabilidad:** criterios aplicados al proyecto
3. **QA:** participación en el proceso de desarrollo

---

### 1 · DESPLIEGUE

**Diapositiva — Plan de despliegue: objetivo y alcance**
- Objetivo: llevar cada versión a producción de forma controlada y repetible.
- Alcance: componentes, base de datos, configuración y dependencias.
- Cronograma, ventanas de mantenimiento y responsables.
- Criterios de aceptación y de reversión acordados antes de liberar.

**Diapositiva — Áreas de sistemas involucradas**
| Área | Función |
|---|---|
| Desarrollo | Construye, versiona y entrega el paquete |
| QA | Valida calidad y aprueba la liberación |
| Infraestructura | Provee servidores, redes y despliegue |
| Seguridad y soporte | Controla accesos y atiende incidentes |

**Diapositiva — Ambientes de sistemas** (misma tabla de la imagen, Parte 1)
| Ambiente | Propósito | Datos |
|---|---|---|
| Desarrollo | Codificación y pruebas unitarias | Ficticios |
| Pruebas / QA | Pruebas funcionales e integración | Prueba controlados |
| Preproducción | Ensayo igual a producción | Copia anonimizada |
| Producción | Operación para usuarios finales | Reales |

**Diapositiva — Estrategia y automatización**
- Integración y entrega continuas (CI/CD) con builds reproducibles.
- **Rolling:** actualización gradual de servidores.
- **Blue-green:** dos entornos y cambio de tráfico inmediato.
- **Canary:** liberar primero a un grupo pequeño de usuarios.

**Diapositiva — Plan de reversión y lista de verificación**
- Respaldo previo de base de datos y configuración.
- Criterios claros para decidir la reversión.
- Pruebas de humo posteriores al despliegue.
- Monitoreo reforzado y comunicación a los involucrados.

---

### 2 · TESTABILIDAD

**Diapositiva — ¿Qué es la testabilidad?**
Grado en que un software puede probarse de forma fácil y efectiva. A mayor testabilidad, menos esfuerzo y errores se detectan antes.

**Diapositiva — Criterios (1 de 2)**
- **Operabilidad:** si funciona mejor, se prueba con mayor eficiencia.
- **Observabilidad:** lo que se ve es lo que se prueba: salidas y estados visibles.
- **Controlabilidad:** mejor control del software implica pruebas automatizables.
- **Descomponibilidad:** módulos independientes se prueban por separado.

**Diapositiva — Criterios (2 de 2)**
- **Simplicidad:** menos que probar: diseño y código simples.
- **Estabilidad:** menos cambios, menos interrupciones en las pruebas.
- **Comprensibilidad:** más información disponible, pruebas más inteligentes.

**Diapositiva — Aplicación a nuestro proyecto**
| Criterio | Práctica en el proyecto |
|---|---|
| Observabilidad | Registros (logs) y mensajes de error claros |
| Controlabilidad | Datos de prueba y pruebas automatizadas |
| Descomponibilidad | Arquitectura modular con interfaces definidas |
| Comprensibilidad | Documentación y requisitos verificables |

---

### 3 · QA

**Diapositiva — QA desde el inicio del desarrollo**
La calidad se construye en cada fase, no solo al final. Probar antes reduce el costo de corregir.

**Diapositiva — Participación de QA por fase**
| Fase | Actividad de QA |
|---|---|
| Requisitos | Revisar criterios de aceptación |
| Diseño | Evaluar testabilidad y riesgos |
| Construcción | Plan de pruebas y automatización |
| Pruebas | Ejecutar pruebas y reportar defectos |
| Despliegue | Pruebas de humo y aprobación de liberación |

**Diapositiva — Métricas y criterios de salida**
- **Cobertura:** porcentaje del código y requisitos probados.
- **Defectos:** cantidad, severidad y tiempo de corrección.
- **Criterio de salida:** sin defectos críticos abiertos y pruebas aprobadas.

### CONCLUSIONES — Ideas clave
- Un plan de despliegue define áreas, ambientes y reversión.
- La testabilidad se diseña: observar, controlar y descomponer.
- QA participa en todas las fases como responsable de la calidad compartida.

---

## PARTE 4 — INSTRUCCIONES PARA ANTIGRAVITY

> **Rol:** eres un ingeniero DevOps/QA que analiza el repositorio de **SOSMascota** (app móvil). Tu misión es **inspeccionar el proyecto real** y generar un **informe técnico en Markdown** con TODOS los datos necesarios para redactar un plan de despliegue ejecutable. El plan se redactará con base en la plantilla de la Parte 2, los conceptos de la Parte 3 y el énfasis de la Parte 1 (**Desarrollo** y **Pruebas/QA** al máximo detalle).

### Reglas generales
1. **No inventes nada.** Si un dato no existe en el proyecto, escribe `NO ENCONTRADO` y, si corresponde, propón una recomendación marcada como `RECOMENDACIÓN`.
2. Indica siempre la **ruta del archivo** de donde sacaste cada dato (ej. `pubspec.yaml`, `android/app/build.gradle`).
3. **NUNCA incluyas secretos reales** (contraseñas, API keys, tokens, keystores, `.env` con valores). Lista solo los **nombres** de las variables y para qué sirven.
4. Los comandos deben ser **copiables y verificados** contra la estructura real (gestor de paquetes, scripts, flavors).
5. Entrega el resultado en un único archivo: **`INFORME_TECNICO_SOSMascota.md`**, con exactamente las secciones de abajo y en español.

### Estructura obligatoria del informe

**A. Identificación del sistema**
- Nombre, versión actual (`version`/`versionCode`/`versionName`/`CFBundleVersion`), identificador de la app (`applicationId`/bundle ID), descripción breve y funcionalidades principales (autenticación, reportes de mascotas, geolocalización, notificaciones, mapas, etc. — solo las que existan).
- Plataformas objetivo: Android / iOS / ambas.

**B. Stack tecnológico**
- Framework y lenguaje (Flutter/Dart, React Native, Kotlin, Swift, etc.) con **versiones exactas** (SDK, Node, Java/JDK, Gradle, Xcode, CocoaPods, etc.).
- Gestor de paquetes y archivo de dependencias; lista de dependencias principales y servicios externos.
- Arquitectura y estructura de carpetas (árbol resumido de 2–3 niveles) e indicar si es modular (relevante para *descomponibilidad*).

**C. Backend, base de datos y servicios externos**
- ¿Qué backend usa? (Firebase, Supabase, API propia, Node, Laravel, etc.) y dónde está alojado.
- Base de datos: motor, esquema/colecciones, migraciones, reglas de seguridad, scripts de seed/datos de prueba.
- Servicios de terceros: autenticación, mapas, notificaciones push, almacenamiento de imágenes, analíticas, crash reporting, etc.
- Endpoints/URLs base **por ambiente** (solo estructura, sin credenciales).

**D. Configuración y variables por ambiente** (tabla)
| Variable / archivo | Propósito | Desarrollo | Pruebas/QA | Preproducción | Producción |
|---|---|---|---|---|---|
- Indica cómo se separan los ambientes hoy (flavors, `.env.*`, `google-services.json` por flavor, proyectos Firebase distintos, etc.).
- Indica qué falta para tener los 4 ambientes: **Desarrollo, Pruebas/QA, Preproducción, Producción**.

**E. AMBIENTE DE DESARROLLO (máximo detalle)**
- Requisitos de hardware/SO e instalación paso a paso de herramientas (con versiones).
- Cómo clonar, instalar dependencias y ejecutar la app (emulador y dispositivo físico) — comandos exactos.
- Configuración de datos **ficticios** (seeds, mocks, emulador de Firebase, backend local).
- Pruebas unitarias existentes: dónde están, cómo ejecutarlas, cuántas hay, cobertura actual si es medible.
- Linters/formatters/analizadores configurados y comandos.
- Control de versiones: repositorio, estrategia de ramas (main/develop/feature), convención de commits.
- Problemas conocidos y errores frecuentes con su solución.

**F. AMBIENTE DE PRUEBAS / QA (máximo detalle)**
- Cómo se genera el build de QA (APK/AAB/IPA de debug o staging) — comandos y flavor.
- Cómo se distribuye a testers (Firebase App Distribution, TestFlight, Play Internal Testing, APK manual, etc.) o `NO ENCONTRADO` + recomendación.
- Backend/BD de pruebas con **datos de prueba controlados**: cómo se crean, reinician y limpian.
- Pruebas existentes: funcionales, de integración, widget/UI, e2e (Detox/Maestro/Appium/integration_test). Ubicación, comandos y resultados.
- Casos de prueba candidatos para las **pruebas de humo** (login, registro, crear reporte de mascota, ver mapa, notificación, etc.) — solo los que correspondan a funciones reales.
- Criterios de salida sugeridos (sin defectos críticos abiertos, cobertura mínima, etc.) y cómo se reportarían defectos.
- Evaluación de **testabilidad** de SOSMascota por criterio: Operabilidad, Observabilidad (logs), Controlabilidad, Descomponibilidad, Simplicidad, Estabilidad, Comprensibilidad → nota breve y evidencia de cada uno.

**G. AMBIENTES DE PREPRODUCCIÓN Y PRODUCCIÓN**
- Qué existe hoy y qué falta (proyecto Firebase/servidor de preproducción, copia anonimizada de datos, etc.).
- Proceso de build de **release**: firma (keystore/signing configs — solo describir, sin secretos), `versionCode` incremental, ofuscación/minificación, comandos de `flutter build appbundle`/`gradlew bundleRelease`/`xcodebuild archive` o equivalentes.
- Publicación: Google Play (tracks interno/cerrado/abierto/producción), App Store/TestFlight, o distribución alternativa. Requisitos de cuentas de desarrollador, fichas de tienda, política de privacidad, permisos declarados (`AndroidManifest.xml`, `Info.plist`).
- Estrategia recomendada para una app móvil: **despliegue gradual por fases / porcentaje de usuarios (equivalente a canary)** y backend con rolling o blue-green si aplica. Justifica según la arquitectura real.

**H. CI/CD y automatización**
- Pipelines existentes (`.github/workflows`, `.gitlab-ci.yml`, Codemagic, Bitrise, Fastlane, etc.) y qué hacen.
- Si no existen: propuesta mínima de pipeline (build reproducible → tests → artefacto → distribución) en pasos.
- Dónde se almacenan los artefactos y cómo se identifican (tag, hash, versión inmutable).

**I. Respaldo, reversión y monitoreo**
- Respaldos de BD y configuración: qué existe y qué se recomienda (exportaciones de Firestore/DB, copia de reglas, configuración remota).
- Estrategia de **rollback** para app móvil (detener rollout gradual, volver a build anterior, `minimum version`/force update, feature flags/Remote Config) y para backend/BD.
- Monitoreo: Crashlytics, Sentry, Analytics, logs del backend, alertas. Qué existe y qué falta.

**J. Seguridad**
- Manejo de secretos y archivos sensibles (revisar `.gitignore`), permisos de la app, reglas de seguridad de la BD, cifrado en tránsito (HTTPS), validaciones y vulnerabilidades evidentes en dependencias.
- Recomendaciones mínimas antes de producción.

**K. Roles (adaptados al equipo real)**
- Si el proyecto es individual o de equipo pequeño, indica qué rol de la tabla de la Parte 2 (Líder de despliegue, Dev/DevOps, Infraestructura, QA, Seguridad, Propietario/CAB) asume cada persona. Si no se conoce, déjalo como `PENDIENTE DE COMPLETAR POR EL USUARIO`.

**L. Hallazgos, brechas y riesgos**
- Tabla `Brecha / Riesgo | Impacto | Recomendación` priorizada (Alta/Media/Baja), considerando los riesgos de la plantilla: incompatibilidad de configuración, falla de migración, indisponibilidad, permisos/seguridad, fallas de integraciones.

**M. Datos pendientes para el usuario**
- Lista de preguntas que Antigravity **no pudo responder** con el código y que el usuario debe contestar (fechas/ventana de cambio, nombres de responsables, organización, cuentas de tienda, ambiente de destino, etc.).

### Formato del entregable
- Un solo archivo `INFORME_TECNICO_SOSMascota.md`, con encabezados `##` por cada sección A–M, tablas donde se indique y bloques de código para comandos.
- Al final, un bloque **"Resumen ejecutivo"** de máximo 10 líneas.

---

## PARTE 5 — Qué haré yo con el informe (para tu referencia)

Cuando me devuelvas `INFORME_TECNICO_SOSMascota.md` (pegado o adjunto), generaré el **Plan de Despliegue de SOSMascota** con la estructura de la plantilla (secciones 1–14 + Anexo A), con estas particularidades:

1. **Ambientes** (tabla de la imagen) con **Desarrollo y Pruebas/QA completamente detallados**, paso a paso, con comandos y evidencias; Preproducción y Producción incluidos según lo que exista/falte.
2. Estrategia de despliegue justificada (rolling / blue-green / canary / gradual en tiendas) y CI/CD.
3. Roles, prerrequisitos, procedimiento por fases (Preparación → Cierre) con evidencia esperada, cronograma T0, pruebas de humo y criterios de aceptación.
4. Rollback, riesgos, comunicación, evidencias, matriz de aprobación y checklist go/no-go.
5. Testabilidad (7 criterios) aplicada a SOSMascota y participación de QA por fase, con métricas y criterio de salida.
6. Redactado para que **otra persona pueda ejecutarlo sin ayuda**, y entregado en el formato que prefieras (.md, Word o doc).
