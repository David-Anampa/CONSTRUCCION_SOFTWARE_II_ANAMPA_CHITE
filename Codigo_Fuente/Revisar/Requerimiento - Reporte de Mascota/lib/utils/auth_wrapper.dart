import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sos_mascotas/servicios/firebase_availability.dart' as fb_avail;

/// Widget que maneja la navegación entre login e inicio.
/// Verifica si el usuario está autenticado y muestra la pantalla correspondiente.
class AuthWrapper extends StatelessWidget {
  final Widget loginScreen;
  final Function(String uid, Map<String, dynamic>? userData) homeScreenBuilder;

  const AuthWrapper({
    super.key,
    required this.loginScreen,
    required this.homeScreenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!fb_avail.firebaseAvailable) {
      return loginScreen;
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrando indicador de carga mientras se verifica autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay un usuario autenticado, mostrar home
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return homeScreenBuilder(user.uid, null);
        }

        // Si no hay usuario, mostrar login
        return loginScreen;
      },
    );
  }
}
