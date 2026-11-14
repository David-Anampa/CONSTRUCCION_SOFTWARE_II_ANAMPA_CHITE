// /**
//  * Archivo/Clase : login_vm.dart / LoginVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel encargado de autenticar usuarios, validar verificación de
//  *                 correo, actualizar el token FCM y resolver la ruta inicial según rol.
//  * Se vincula con: - USA: Usuario (usuario.dart), FirebaseAuth, FirebaseFirestore
//  *                   (colección 'usuarios'), FirebaseMessaging.
//  *                 - ES USADO POR: app.dart, PantallaLogin (pantalla_login.dart) y
//  *                   pruebas unitarias REQ01 y RF-01.
//  * Funcionamiento: Valida el formulario, autentica con Firebase Auth con timeout, lee el
//  *                 perfil en Firestore, verifica email si no es admin/colaborador y
//  *                 retorna la ruta destino (`/inicioAdmin`, `/inicio`, `/perfil`, etc.).
//  * Requerimiento : RF-01 / REQ01 (Autenticar usuario)
//  */

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';

/// ViewModel que gestiona el estado y la lógica de inicio de sesión.
class LoginVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final correoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();

  bool cargando = false;
  String? error;

  /// Libera los controladores de correo y contraseña al destruir el ViewModel.
  @override
  void dispose() {
    correoCtrl.dispose();
    claveCtrl.dispose();
    super.dispose();
  }

  /// Obtiene el token FCM actual y lo guarda en `usuarios/{uid}` sin bloquear el login.
  ///
  /// - Parámetros: [uid] identificador del usuario autenticado.
  /// - Valor de retorno: [Future<void>].
  /// - Errores: Captura y registra excepciones o timeouts internamente sin propagar.
  /// - Efectos secundarios: Actualiza el campo `token` en Cloud Firestore.
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

  /// Autentica al usuario con correo/clave y determina la ruta de navegación inicial.
  ///
  /// - Parámetros: Ninguno (lee [correoCtrl] y [claveCtrl] tras validar [formKey]).
  /// - Valor de retorno: Ruta nombrada (`String`) o `null` si falló la validación o login.
  /// - Errores: Captura [FirebaseAuthException] y excepciones generales asignando [error].
  /// - Efectos secundarios: Actualiza [cargando] y [error], notifica listeners, puede
  ///   cerrar sesión si no existe perfil y lanza [guardarTokenFCM] en segundo plano.
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
