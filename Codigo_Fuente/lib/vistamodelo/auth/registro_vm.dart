import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';
// import '../../servicios/api_dni_servicio.dart'; // ❌ Eliminado

class RegistroVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();
  // ❌ Eliminado: final dniCtrl = TextEditingController();

  bool cargando = false;
  // ❌ Eliminado: bool buscandoDni = false;
  String? error;

  // ❌ Eliminado: final ApiDniServicio apiDni;
  // El constructor ya no necesita el servicio DNI
  RegistroVM();

  // ❌ Eliminado: Función buscarYAutocompletarNombre

  /// 📝 Registrar usuario
  Future<bool> registrarUsuario() async {
    // 🛑 Opcional: Podrías añadir una validación aquí para que el nombre NO sea vacío,
    // ya que no hay autocompletado forzándolo. Ya está en la vista.
    if (!formKey.currentState!.validate()) return false;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      // 🛑 CAMBIO CLAVE: Usamos un DNI vacío ("") para cumplir con el modelo
      const String dni = "";

      // 1) Crear cuenta en Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2) Crear objeto Usuario
      final usuario = Usuario(
        id: uid,
        dni: dni, // 🟢 Se envía un string vacío
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
        print("Error guardando token FCM: $e");
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
