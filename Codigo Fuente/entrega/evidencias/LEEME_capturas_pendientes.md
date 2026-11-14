# Capturas que debe tomar el usuario (manual)

| # | Captura | Qué debe verse |
|---|---|---|
| 1 | Firebase Console → proyecto `sosmascota-71d79` → Configuración | Nombre del proyecto, ID, plan (Spark/Blaze) |
| 2 | Firebase Console → Authentication → Sign-in method | Proveedores habilitados (correo/contraseña; Google si está activo) |
| 3 | Firestore → Reglas (pestaña Reglas) | Reglas publicadas y fecha de publicación |
| 4 | Firestore → Índices | Índices compuestos desplegados |
| 5 | Storage → Reglas | Si hay reglas de Storage publicadas (el repo NO tiene `storage.rules`) |
| 6 | Cloud Messaging / Cloud Console → IAM | Cuentas de servicio y roles; MFA de la cuenta Google |
| 7 | GitHub → Settings → Branches | Reglas de protección de rama (o su ausencia) |
| 8 | GitHub → Insights → Contributors y pestaña Commits | Autores y actividad |
| 9 | GitHub → Actions / Issues / Pull Requests | Estado (hoy: sin workflows) |
| 10 | GitHub → Settings → Security (2FA) | Verificación en dos pasos habilitada |
| 11 | Play Console / App Distribution (si existen) | Releases, tracks o grupos de testers |
| 12 | App corriendo en emulador/dispositivo | Login, mapa, creación de reporte, notificaciones |
| 13 | Terminal con `flutter test` | Resumen +14 -1 (ver evidencias/pruebas/flutter_test.txt) |
| 14 | Terminal con `flutter analyze` | 137 issues (0 errores, 0 warnings) |
