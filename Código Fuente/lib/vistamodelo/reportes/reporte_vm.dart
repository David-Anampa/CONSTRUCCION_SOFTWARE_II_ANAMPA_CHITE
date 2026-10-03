import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sos_mascotas/servicios/notificacion_servicio.dart';
import 'package:sos_mascotas/utils/imagen_util.dart';
import '../../modelo/reporte_mascota.dart';

/// ViewModel del asistente (wizard) de 3 pasos para registrar una mascota perdida.
///
/// Administra el estado mutable del formulario, controla el paso activo y
/// coordina la subida de medios y el guardado final en Firestore.
class ReporteMascotaVM extends ChangeNotifier {
  int _paso = 0;
  ReporteMascota reporte = ReporteMascota();
  bool _cargando = false;

  // Flag interno para evitar notifyListeners() después de dispose().
  bool _disposed = false;

  // FormKeys para validar cada paso del wizard de forma independiente.
  final formKeyPaso1 = GlobalKey<FormState>();
  final formKeyPaso2 = GlobalKey<FormState>();
  final formKeyPaso3 = GlobalKey<FormState>();

  int get paso => _paso;
  bool get cargando => _cargando;
  List<String> get fotos => reporte.fotos;
  List<String> get videos => reporte.videos;

  /// Dispara notifyListeners() solo si el ViewModel aún está activo.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ---------- Control del wizard ----------

  void setPaso(int nuevoPaso) {
    _paso = nuevoPaso;
    _notify();
  }

  void siguientePaso() {
    if (_paso < 2) {
      _paso++;
      _notify();
    }
  }

  void pasoAnterior() {
    if (_paso > 0) {
      _paso--;
      _notify();
    }
  }

  // ---------- Gestión de medios ----------

  void agregarFoto(String url) {
    reporte.fotos.add(url);
    _notify();
  }

  void agregarVideo(String url) {
    reporte.videos.add(url);
    _notify();
  }

  void removerFoto(String url) {
    reporte.fotos.remove(url);
    _notify();
  }

  /// Valida que [archivo] contenga un perro o gato y lo sube a Storage.
  ///
  /// Delega en [ImagenUtil.validarYSubirFoto] para centralizar la lógica de
  /// compresión + validación TFLite + subida (evita duplicado con AvistamientoVM).
  /// Lanza [Exception] si la imagen no pasa el umbral de confianza del modelo.
  Future<String> subirFoto(File archivo) =>
      ImagenUtil.validarYSubirFoto(archivo, storagePath: 'reportes_mascotas');

  /// Sube un [archivo] de video a Firebase Storage.
  ///
  /// Lanza [StateError] si no hay usuario autenticado.
  Future<String> subirVideo(File archivo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado para subir el video.');
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('reportes_mascotas')
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');

    await ref.putFile(archivo);
    return ref.getDownloadURL();
  }

  // ---------- Persistencia ----------

  /// Guarda el reporte completo en Firestore y dispara la notificación push global.
  ///
  /// Retorna `true` si el guardado fue exitoso, `false` en caso de error.
  Future<bool> guardarReporte() async {
    try {
      _cargando = true;
      _notify();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('No hay usuario autenticado.');

      final docRef = FirebaseFirestore.instance
          .collection('reportes_mascotas')
          .doc();

      reporte.id = docRef.id;
      reporte.usuarioId = uid;
      reporte.estado = 'Perdido';

      await docRef.set({
        ...reporte.toMap(),
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      await NotificacionServicio.enviarPush(
        titulo: 'Nuevo reporte 🐾',
        cuerpo: 'Se ha registrado una nueva mascota perdida.',
      );

      _cargando = false;
      _notify();
      return true;
    } catch (e) {
      _cargando = false;
      _notify();
      debugPrint('❌ Error al guardar reporte: $e');
      return false;
    }
  }
}
