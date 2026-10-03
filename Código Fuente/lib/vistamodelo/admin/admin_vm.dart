import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modelo/usuario.dart';
import '../../servicios/api_dni_servicio.dart';

class AdminVM extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final claveCtrl = TextEditingController();
  final dniCtrl = TextEditingController();

  bool cargando = false;
  bool buscandoDni = false;
  String? error;

  final ApiDniServicio apiDni;

  AdminVM({required this.apiDni});

  /// 🔎 Buscar datos por DNI en la API
  Future<bool> buscarYAutocompletarNombre() async {
    final dni = dniCtrl.text.trim();
    if (dni.isEmpty) {
      error = "Ingrese DNI";
      notifyListeners();
      return false;
    }

    Map<String, dynamic>? datos;
    try {
      datos = await apiDni.consultarDni(dni);
    } catch (e) {
      buscandoDni = false;
      error = "DNI inválido o error en el servicio: $e";
      notifyListeners();
      return false;
    }

    buscandoDni = false;

    if (datos == null) {
      error = "DNI no encontrado o servicio no disponible";
      notifyListeners();
      return false;
    }

    final nombreCompleto = [
      datos['nombres'] ?? '',
      datos['ape_paterno'] ?? '',
      datos['ape_materno'] ?? '',
    ].where((s) => s.toString().trim().isNotEmpty).join(' ');

    nombreCtrl.text = nombreCompleto;

    error = null;
    notifyListeners();
    return true;
  }

  /// Crea una cuenta de administrador en Firebase Auth y guarda el perfil en Firestore.
  ///
  /// Verifica duplicado de DNI antes de crear la cuenta.
  /// Retorna `true` si el registro fue exitoso. Retorna `false` y expone
  /// el mensaje en [error] si ocurre un error de autenticación o de red.
  Future<bool> registrarAdministrador() async {
    if (!formKey.currentState!.validate()) return false;

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final dni = dniCtrl.text.trim();

      // Verificar duplicado por DNI antes de crear la cuenta en Auth
      // para evitar crear cuentas Auth huérfanas sin documento en Firestore.
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('dni', isEqualTo: dni)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        cargando = false;
        error = 'El DNI ya está registrado en otra cuenta.';
        notifyListeners();
        return false;
      }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      final usuario = Usuario(
        id: uid,
        dni: dni,
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
    dniCtrl.dispose();
    super.dispose();
  }
}