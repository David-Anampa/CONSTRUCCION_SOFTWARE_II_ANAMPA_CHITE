// /**
//  * Archivo/Clase : auth_wrapper.dart / AuthWrapper
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Widget guardián de sesión que escucha en tiempo real el estado de
//  *                 autenticación y el campo 'activo' del documento del usuario en Firestore.
//  * Se vincula con: - USA: firebase_auth (FirebaseAuth) y cloud_firestore (FirebaseFirestore).
//  *                 - ES USADO POR: Pruebas unitarias REQ01 (req01_autenticacion_prueba_unitaria_test.dart)
//  *                   y flujos de protección de sesión activa.
//  * Funcionamiento: Anida dos StreamBuilder (authStateChanges y snapshots del documento
//  *                 'usuarios/{uid}'); si el usuario no existe o su cuenta es desactivada
//  *                 por un administrador, ejecuta signOut() y redirige a loginScreen.
//  * Requerimiento : RF-01 / REQ01 (Autenticación y control de acceso), RF-13 (Cerrar sesión),
//  *                 RF-15 (Suspensión administrativa en tiempo real)
//  */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🛡️ AuthWrapper - Valida el estado de la cuenta en tiempo real
/// 
/// Este wrapper monitorea constantemente:
/// - Si el usuario está autenticado
/// - Si la cuenta está activa (campo 'activo' en Firestore)
/// - Si el documento del usuario existe
/// 
/// Si la cuenta es desactivada por un admin, el usuario será
/// expulsado automáticamente de la aplicación.
class AuthWrapper extends StatelessWidget {
  /// Pantalla que se muestra cuando NO hay usuario autenticado
  final Widget loginScreen;
  
  /// Constructor que recibe el UID y los datos del usuario
  /// para determinar qué pantalla mostrar
  final Widget Function(String uid, Map<String, dynamic> userData) homeScreenBuilder;
  
  /// Crea un [AuthWrapper] con la pantalla de login y el constructor de pantalla principal.
  ///
  /// - Parámetros: [loginScreen] widget de respaldo; [homeScreenBuilder] función que
  ///   construye la vista autenticada a partir del `uid` y `userData`.
  const AuthWrapper({
    super.key,
    required this.loginScreen,
    required this.homeScreenBuilder,
  });

  /// Construye el árbol reactivo que verifica sesión y estado activo del usuario.
  ///
  /// - Parámetros: [context] contexto de construcción de Flutter.
  /// - Valor de retorno: [loginScreen], pantalla de carga o resultado de [homeScreenBuilder].
  /// - Efectos secundarios: Invoca `FirebaseAuth.instance.signOut()` y muestra un
  ///   [SnackBar] en un post-frame callback si el documento no existe o `activo == false`.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 🚫 Si no hay usuario autenticado, mostrar login
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          print('🔓 No hay usuario autenticado - Mostrando login');
          return loginScreen;
        }

        final user = authSnapshot.data!;

        // 👀 Escuchar cambios en el documento del usuario en tiempo real
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            // ⏳ Mientras carga, mostrar indicador
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Verificando cuenta...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ❌ Si hay error o no existe el documento
            if (userSnapshot.hasError || 
                !userSnapshot.hasData || 
                !userSnapshot.data!.exists) {
              print('⚠️ Error o documento no existe para usuario: ${user.uid}');
              // Cerrar sesión y volver al login
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error al cargar los datos del usuario.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              });
              return loginScreen;
            }

            // 📦 Obtener datos del usuario
            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
            
            if (userData == null) {
              print('⚠️ userData es null para usuario: ${user.uid}');
              // Si no hay datos, cerrar sesión
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await FirebaseAuth.instance.signOut();
              });
              return loginScreen;
            }

            // ✅ Verificar si la cuenta está activa
            final bool isActive = userData['activo'] ?? true;

            print('🔍 Usuario: ${user.email}');
            print('📊 Estado activo: $isActive');
            print('👤 Rol: ${userData['rol']}');

            // 🚫 Si la cuenta está DESACTIVADA, cerrar sesión
            if (!isActive) {
              print('❌ Cuenta DESACTIVADA - Cerrando sesión');
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.block, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cuenta Desactivada',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tu cuenta ha sido desactivada. Contacta al administrador para más información.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red.shade700,
                      duration: const Duration(seconds: 6),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              });
              return loginScreen;
            }

            // ✅ Cuenta ACTIVA - Construir la pantalla correspondiente
            print('✅ Cuenta ACTIVA - Permitiendo acceso');
            return homeScreenBuilder(user.uid, userData);
          },
        );
      },
    );
  }
}