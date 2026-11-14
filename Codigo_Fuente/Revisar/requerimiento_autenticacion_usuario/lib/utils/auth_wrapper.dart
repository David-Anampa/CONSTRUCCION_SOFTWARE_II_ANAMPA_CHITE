import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicios/firebase_availability.dart' as fb_avail;

import '../config/app_config.dart';

/// Verifica en tiempo real que el usuario esté autenticado, que su
/// documento exista en Firestore y que su cuenta siga activa.
///
/// Aplica "fail fast": ante cualquier condición inválida (sin sesión,
/// documento inexistente, error de lectura o cuenta desactivada) cierra
/// sesión de inmediato y regresa a `loginScreen`, en vez de dejar que
/// la app siga en un estado a medias.
class AuthWrapper extends StatelessWidget {
  final Widget loginScreen;
  final Widget Function(String uid, Map<String, dynamic> userData) homeScreenBuilder;

  const AuthWrapper({
    super.key,
    required this.loginScreen,
    required this.homeScreenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // Si Firebase no está disponible (por ejemplo web sin config), no
    // intentar suscribirse a streams de Firebase que causen excepciones.
    if (!fb_avail.firebaseAvailable) return loginScreen;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) return loginScreen; // Fail fast: sin sesión, no hay nada más que revisar.

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _VerificandoCuenta();
            }

            final docExiste = userSnapshot.hasData && userSnapshot.data!.exists;
            if (userSnapshot.hasError || !docExiste) {
              _cerrarSesionYAvisar(
                context,
                mensaje: 'Error al cargar los datos del usuario.',
                icono: Icons.error_outline,
                color: Colors.red,
                duracion: AppConfig.snackDurationDefault,
              );
              return loginScreen;
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            if (userData == null) {
              FirebaseAuth.instance.signOut();
              return loginScreen;
            }

            final bool cuentaActiva = userData['activo'] ?? true;
            if (!cuentaActiva) {
              _cerrarSesionYAvisar(
                context,
                titulo: 'Cuenta Desactivada',
                mensaje:
                    'Tu cuenta ha sido desactivada. Contacta al administrador para más información.',
                icono: Icons.block,
                color: Colors.red.shade700,
                duracion: AppConfig.snackDurationLong,
              );
              return loginScreen;
            }

            return homeScreenBuilder(user.uid, userData);
          },
        );
      },
    );
  }

  /// Cierra sesión y muestra un SnackBar con el motivo.
  /// Antes este mismo patrón (signOut + SnackBar) estaba duplicado
  /// para el caso de "error al cargar datos" y el de "cuenta desactivada".
  void _cerrarSesionYAvisar(
    BuildContext context, {
    String? titulo,
    required String mensaje,
    required IconData icono,
    required Color color,
    required Duration duracion,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;

      final esAvisoImportante = titulo != null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icono, color: Colors.white, size: AppConfig.snackIconSize),
              SizedBox(width: AppConfig.snackSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esAvisoImportante) ...[
                      Text(
                        titulo,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: AppConfig.snackTextSpacing),
                    ],
                    Text(mensaje, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: duracion,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              esAvisoImportante
                  ? AppConfig.snackBorderRadiusLarge
                  : AppConfig.snackBorderRadiusDefault,
            ),
          ),
          margin: esAvisoImportante ? const EdgeInsets.all(AppConfig.snackMargin) : null,
        ),
      );
    });
  }
}

/// Pantalla de carga mientras se valida el estado de la cuenta contra Firestore.
class _VerificandoCuenta extends StatelessWidget {
  const _VerificandoCuenta();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando cuenta...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}