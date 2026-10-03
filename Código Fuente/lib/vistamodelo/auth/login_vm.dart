import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';

class LoginVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final correoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();

  bool cargando = false;
  String? error;

  @override
  void dispose() {
    correoCtrl.dispose();
    claveCtrl.dispose();
    super.dispose();
  }

  Future<void> guardarTokenFCM(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 5),
      );

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .update({'token': token})
            .timeout(const Duration(seconds: 5));
        debugPrint("Token FCM guardado para usuario: $uid");
      }
    } catch (e) {
      // No bloquear el login si falla el token FCM
      debugPrint("Error al guardar token FCM (ignorado): $e");
    }
  }

  Future<String?> loginYDeterminarRuta() async {
    if (!formKey.currentState!.validate()) return null;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      // 1. Autenticación con timeout
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: correoCtrl.text.trim(),
            password: claveCtrl.text.trim(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception(
              "Tiempo de espera agotado. Verifica tu conexión a internet.",
            ),
          );

      final uid = cred.user!.uid;

      // 2. Leer perfil de Firestore con timeout
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              "No se pudo cargar tu perfil. Intenta de nuevo.",
            ),
          );

      if (!doc.exists) {
        error =
            "El perfil de usuario no está completo. Contacte al administrador.";
        await FirebaseAuth.instance.signOut();
        cargando = false;
        notifyListeners();
        return null;
      }

      final usuario = Usuario.fromMap(doc.data() ?? {}, doc.id);

      // 3. Verificación de email solo para usuarios normales
      if (usuario.rol != "admin" && usuario.rol != "colaborador") {
        await cred.user?.reload();
        if (cred.user != null && !cred.user!.emailVerified) {
          error = "Debe verificar su correo antes de continuar.";
          cargando = false;
          notifyListeners();
          return null;
        }
      }

      // 4. Guardar token FCM en segundo plano sin demorar la navegación del usuario
      unawaited(guardarTokenFCM(uid));

      cargando = false;
      notifyListeners();

      // 5. Determinar ruta según rol
      if (usuario.rol == "admin") return "/inicioAdmin";
      if (usuario.rol == "colaborador") return "/inicioColaborador";

      // Usuario normal
      if (usuario.fotoPerfil == null || usuario.fotoPerfil!.isEmpty) {
        return "/perfil";
      } else {
        return "/inicio";
      }
    } on FirebaseAuthException catch (e) {
      error = (e.code == 'user-not-found')
          ? 'Usuario no existe'
          : (e.code == 'wrong-password')
          ? 'Contraseña incorrecta'
          : (e.message ?? 'Error al iniciar sesión');
      cargando = false;
      notifyListeners();
      return null;
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
      cargando = false;
      notifyListeners();
      return null;
    }
  }
}
