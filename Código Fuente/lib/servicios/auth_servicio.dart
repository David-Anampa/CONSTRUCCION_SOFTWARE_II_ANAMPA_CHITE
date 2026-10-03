import 'package:firebase_auth/firebase_auth.dart';

/// Encapsula las operaciones de autenticación de Firebase Auth.
///
/// Centraliza registro, login, verificación de correo y recarga de datos
/// para que los ViewModels no accedan directamente a [FirebaseAuth].
class AuthServicio {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crea una cuenta nueva con [correo] y [clave].
  ///
  /// Retorna el UID del usuario creado.
  /// Lanza [FirebaseAuthException] si el correo ya está en uso o la clave es débil.
  Future<String> registrar(String correo, String clave) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: clave,
    );
    return cred.user!.uid;
  }

  /// Envía un correo de verificación al usuario actualmente autenticado.
  ///
  /// No hace nada si no hay usuario autenticado o si ya verificó su correo.
  Future<void> enviarVerificacionCorreo() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Recarga los datos del usuario desde Firebase para leer el estado
  /// actualizado de [emailVerified] sin necesidad de cerrar sesión.
  Future<void> recargarUsuario() async {
    final user = _auth.currentUser;
    if (user != null) await user.reload();
  }

  /// Retorna `true` si el usuario actual tiene el correo verificado.
  bool get correoVerificado {
    final user = _auth.currentUser;
    return (user != null && user.emailVerified);
  }

  /// Alias de [enviarVerificacionCorreo] para reenvíos explícitos.
  Future<void> reenviarVerificacion() => enviarVerificacionCorreo();

  /// Inicia sesión con [correo] y [clave], bloqueando el acceso si el correo
  /// no ha sido verificado aún.
  ///
  /// Lanza [FirebaseAuthException] con code `email-not-verified` si el usuario
  /// existe pero su correo no está confirmado, para que el caller pueda
  /// diferenciarlo de un error de credenciales.
  Future<User?> loginBloqueandoSiNoVerificado(
    String correo,
    String clave,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: correo,
      password: clave,
    );
    await cred.user?.reload();
    if (cred.user != null && !cred.user!.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Debe verificar su correo antes de continuar.',
      );
    }

    return cred.user;
  }
}
