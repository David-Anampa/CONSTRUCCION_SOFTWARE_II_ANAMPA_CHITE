// /**
//  * Archivo/Clase : admin_vm.dart / AdminVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel para el registro de nuevas cuentas con rol de administrador
//  *                 en Firebase Authentication y Cloud Firestore.
//  * Se vincula con: - USA: Usuario (usuario.dart), FirebaseAuth, FirebaseFirestore
//  *                   ('usuarios') y FirebaseMessaging.
//  *                 - ES USADO POR: app.dart y PantallaRegistroAdmin (pantalla_registro_admin.dart).
//  * Funcionamiento: Valida el formulario administrativo, crea la cuenta en Firebase Auth,
//  *                 persiste el documento con rol 'admin', guarda el token FCM de forma
//  *                 tolerante a fallos y envía el correo de verificación.
//  * Requerimiento : RF-14 (Gestionar panel y cuentas administrativas)
//  */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';

/// ViewModel responsable del alta de nuevos usuarios administradores.
class AdminVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();

  bool cargando = false;
  String? error;

  /// Crea una instancia de [AdminVM].
  AdminVM();

  /// Crea una cuenta de administrador en Firebase Auth y guarda el perfil en Firestore.
  ///
  /// Retorna `true` si el registro fue exitoso. Retorna `false` y expone
  /// el mensaje en [error] si ocurre un error de autenticación o de red.
  Future<bool> registrarAdministrador() async {
    if (!formKey.currentState!.validate()) return false;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      final usuario = Usuario(
        id: uid,
        nombre: nombreCtrl.text.trim(),
        correo: correoCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim(),
        rol: 'admin',
        estadoVerificado: false,
        estadoRol: 'activo',
        fechaRegistro: DateTime.now(),
        fotoPerfil: null,
        activo: true,
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set(usuario.toMap());

      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .update({'token': token});
        }
      } catch (e) {
        // El token FCM es best-effort; su fallo no debe cancelar el registro.
        debugPrint('Error guardando token FCM del admin (uid=$uid): $e');
      }

      await cred.user?.sendEmailVerification();

      cargando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Error de autenticación desconocido.';
    } catch (e) {
      error = e.toString();
      debugPrint('Error inesperado en registrarAdministrador: $e');
    }

    cargando = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    telefonoCtrl.dispose();
    claveCtrl.dispose();
    super.dispose();
  }
}