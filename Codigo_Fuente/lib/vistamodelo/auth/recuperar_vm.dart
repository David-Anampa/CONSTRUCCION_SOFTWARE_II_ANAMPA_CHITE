import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarVM extends ChangeNotifier {
  final correoCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool enviando = false;
  bool enviado = false; // ✅ nuevo: controla la pantalla de éxito
  String? error;

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

  void reiniciar() {
    enviado = false;
    error = null;
    correoCtrl.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    correoCtrl.dispose();
    super.dispose();
  }
}
