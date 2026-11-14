// /**
//  * Archivo/Clase : recuperar_vm.dart / RecuperarVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel que gestiona el envío del correo de restablecimiento de
//  *                 contraseña mediante Firebase Auth y la traducción de códigos de error.
//  * Se vincula con: - USA: firebase_auth (FirebaseAuth).
//  *                 - ES USADO POR: app.dart, PantallaRecuperar (pantalla_recuperar.dart) y
//  *                   pruebas unitarias REQ03 (req03_recuperar_contrasena_prueba_unitaria_test.dart).
//  * Funcionamiento: Valida el correo ingresado, solicita a Firebase Auth el envío del enlace
//  *                 de recuperación y actualiza los flags enviando/enviado/error para la UI.
//  * Requerimiento : RF-03 / REQ03 (Recuperar contraseña)
//  */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ViewModel para el flujo de recuperación de contraseña por correo electrónico.
class RecuperarVM extends ChangeNotifier {
  final correoCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool enviando = false;
  bool enviado = false; // ✅ nuevo: controla la pantalla de éxito
  String? error;

  /// Traduce un código de error de Firebase Auth a un mensaje legible en español.
  ///
  /// - Parámetros: [code] código de [FirebaseAuthException].
  /// - Valor de retorno: Mensaje descriptivo para mostrar al usuario.
  static String _traducirError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo electrónico.';
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return 'Ocurrió un error inesperado. Inténtalo nuevamente.';
    }
  }

  /// Envía el correo de restablecimiento de contraseña usando Firebase Auth.
  ///
  /// - Parámetros: [context] contexto de la vista (conservado en la firma pública).
  /// - Valor de retorno: [Future<void>].
  /// - Errores: Captura [FirebaseAuthException] y excepciones genéricas guardando el mensaje en [error].
  /// - Efectos secundarios: Dispara correo de recuperación de Firebase y actualiza [enviando]/[enviado].
  Future<void> enviarCorreo(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    enviando = true;
    error = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: correoCtrl.text.trim(),
      );

      enviado = true;
    } on FirebaseAuthException catch (e) {
      error = _traducirError(e.code);
    } catch (_) {
      error = 'Ocurrió un error inesperado. Inténtalo nuevamente.';
    }

    enviando = false;
    notifyListeners();
  }

  /// Restablece el estado del ViewModel para permitir intentar con otro correo.
  void reiniciar() {
    enviado = false;
    error = null;
    correoCtrl.clear();
    notifyListeners();
  }

  /// Libera el controlador [correoCtrl] al destruir el ViewModel.
  @override
  void dispose() {
    correoCtrl.dispose();
    super.dispose();
  }
}
