// /**
//  * Archivo/Clase : perfil_vm.dart / PerfilVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel para consultar y editar el perfil del usuario autenticado,
//  *                 actualizar su foto en Storage, restablecer clave o eliminar cuenta.
//  * Se vincula con: - USA: FirebaseAuth, FirebaseFirestore ('usuarios'), FirebaseStorage
//  *                   y ImagePicker.
//  *                 - ES USADO POR: app.dart y PantallaPerfil (pantalla_perfil.dart).
//  * Funcionamiento: Carga los datos del documento del usuario al instanciarse, permite
//  *                 actualizar teléfono, ubicación y avatar, y gestiona acciones de cuenta.
//  * Requerimiento : RF-09 (Gestionar perfil de usuario)
//  */

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ViewModel que administra los datos y acciones del perfil del usuario actual.
class PerfilVM extends ChangeNotifier {
  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final ubicacionCtrl = TextEditingController();

  String? fotoUrl;
  bool cargando = true;

  bool notificacionesPush = true;
  bool alertasEmail = false;

  /// Inicializa el ViewModel disparando la carga inmediata del perfil desde Firestore.
  PerfilVM() {
    cargarPerfil();
  }

  /// Obtiene los datos actuales del usuario autenticado desde `usuarios/{uid}`.
  ///
  /// - Precondiciones: Debe existir una sesión activa en [FirebaseAuth].
  /// - Valor de retorno: [Future<void>].
  /// - Efectos secundarios: Puebla los controladores de texto, asigna [fotoUrl] y desactiva [cargando].
  Future<void> cargarPerfil() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (doc.exists) {
        final d = doc.data()!;
        nombreCtrl.text = d["nombre"] ?? "";
        correoCtrl.text = d["correo"] ?? "";
        telefonoCtrl.text = d["telefono"] ?? "";
        ubicacionCtrl.text = d["ubicacion"] ?? "";
        fotoUrl = d["fotoPerfil"];
      }
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Persiste los cambios de teléfono, ubicación y foto de perfil en Firestore.
  ///
  /// - Precondiciones: Usuario autenticado en [FirebaseAuth].
  /// - Valor de retorno: [Future<void>].
  /// - Efectos secundarios: Actualiza el documento en `usuarios/{uid}` y notifica listeners.
  Future<void> guardar() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("usuarios").doc(uid).update({
      "telefono": telefonoCtrl.text.trim(),
      "ubicacion": ubicacionCtrl.text.trim(),
      "fotoPerfil": fotoUrl ?? "",
    });

    notifyListeners();
  }

  /// Permite seleccionar una imagen de galería, subirla a Storage y actualizar el perfil.
  ///
  /// - Precondiciones: Usuario autenticado y permisos de galería concedidos.
  /// - Valor de retorno: [Future<void>].
  /// - Efectos secundarios: Sube el archivo a `usuarios/{uid}/perfil.jpg` y actualiza `fotoPerfil`.
  Future<void> cambiarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref().child(
      "usuarios/$uid/perfil.jpg",
    );

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    fotoUrl = url;
    await FirebaseFirestore.instance.collection("usuarios").doc(uid).update({
      "fotoPerfil": url,
    });

    notifyListeners();
  }

  /// Envía un correo de restablecimiento de contraseña al correo cargado en [correoCtrl].
  Future<void> enviarResetPassword() async {
    final correo = correoCtrl.text.trim();
    if (correo.isNotEmpty) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
    }
  }

  /// Elimina el documento del usuario en Firestore y borra su cuenta en Firebase Auth.
  ///
  /// - Precondiciones: Usuario autenticado con sesión reciente (requerido por `User.delete`).
  /// - Errores: Puede lanzar [FirebaseAuthException] (`requires-recent-login`).
  Future<void> eliminarCuenta() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection("usuarios").doc(uid).delete();
    await FirebaseAuth.instance.currentUser!.delete();
  }

  /// Libera los cuatro controladores de texto del formulario de perfil.
  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    telefonoCtrl.dispose();
    ubicacionCtrl.dispose();
    super.dispose();
  }
}
