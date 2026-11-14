// /**
//  * Archivo/Clase : registro_vm.dart / RegistroVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel encargado del registro de nuevos usuarios en Firebase Auth,
//  *                 creación de su perfil en Firestore y envío de verificación de correo.
//  * Se vincula con: - USA: Usuario (usuario.dart), FirebaseAuth, FirebaseFirestore
//  *                   (colección 'usuarios'), FirebaseMessaging.
//  *                 - ES USADO POR: app.dart, PantallaRegistro (pantalla_registro.dart) y
//  *                   pruebas unitarias REQ02 y RF-02.
//  * Funcionamiento: Valida el formulario, crea la credencial en Auth, persiste el objeto
//  *                 Usuario en Firestore, registra el token FCM si está disponible y envía
//  *                 el correo de verificación.
//  * Requerimiento : RF-02 / REQ02 (Registrar usuario)
//  */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';

/// ViewModel para el registro de nuevos usuarios en SOS Mascota.
class RegistroVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();

  bool cargando = false;
  String? error;

  /// Crea una instancia de [RegistroVM].
  RegistroVM();

  /// 📝 Registrar usuario
  ///
  /// Crea la cuenta en Firebase Auth, guarda el perfil inicial en Firestore,
  /// intenta almacenar el token FCM y envía el correo de verificación.
  /// - Parámetros: Ninguno (lee los controladores tras validar [formKey]).
  /// - Valor de retorno: `true` si el alta se completó con éxito; `false` si falló.
  /// - Errores: Captura [FirebaseAuthException] y otros errores exponiendo el detalle en [error].
  /// - Efectos secundarios: Crea usuario en Firebase Auth, escribe en `usuarios/{uid}`,
  ///   envía correo de verificación y actualiza [cargando] / [error].
  Future<bool> registrarUsuario() async {
    // 🛑 Opcional: Podrías añadir una validación aquí para que el nombre NO sea vacío,
    // ya que no hay autocompletado forzándolo. Ya está en la vista.
    if (!formKey.currentState!.validate()) return false;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      // 1) Crear cuenta en Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2) Crear objeto Usuario
      final usuario = Usuario(
        id: uid,
        nombre: nombreCtrl.text.trim(),
        correo: correoCtrl.text.trim(),
        telefono: telefonoCtrl.text.trim(),
        rol: "usuario",
        estadoVerificado: false,
        estadoRol: "activo",
        fechaRegistro: DateTime.now(),
        fotoPerfil: null,
      );

      // 3) Guardar en Firestore
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .set(usuario.toMap());

      // 🔥 Guardar token FCM y enviar verificación
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .update({'token': token});
        }
      } catch (e) {
        debugPrint("Error guardando token FCM: $e");
      }

      // 4) Enviar verificación
      await cred.user?.sendEmailVerification();

      cargando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    }

    cargando = false;
    notifyListeners();
    return false;
  }
}
