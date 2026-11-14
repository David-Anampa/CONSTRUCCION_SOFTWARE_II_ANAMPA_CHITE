import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sos_mascotas/servicios/notificacion_servicio.dart';
import 'package:sos_mascotas/servicios/servicio_tflite.dart';
import '../../modelo/reporte_mascota.dart';

class ReporteMascotaVM extends ChangeNotifier {
  int _paso = 0;
  ReporteMascota reporte = ReporteMascota();
  bool _cargando = false;
  bool _disposed = false; // 👈 nuevo flag de control

  // ✅ FormKeys para validaciones
  final formKeyPaso1 = GlobalKey<FormState>();
  final formKeyPaso2 = GlobalKey<FormState>();
  final formKeyPaso3 = GlobalKey<FormState>();

  // Getters
  int get paso => _paso;
  bool get cargando => _cargando;
  List<String> get fotos => reporte.fotos;
  List<String> get videos => reporte.videos;

  // 🧩 Safe notify (evita error after dispose)
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // 🔹 Control del wizard
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

  // 📸 Agregar fotos
  void agregarFoto(String url) {
    reporte.fotos.add(url);
    _notify();
  }

  // 🎥 Agregar videos
  void agregarVideo(String url) {
    reporte.videos.add(url);
    _notify();
  }

  // 🔧 Comprimir imagen antes de subir
  Future<File> _comprimirImagen(File archivo) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      archivo.absolute.path,
      targetPath,
      quality: 70,
    );

    return result != null ? File(result.path) : archivo;
  }

  // 📸 Subir foto con validación local (modelo TFLite)
  Future<String> subirFoto(File archivo) async {
    final comprimido = await _comprimirImagen(archivo);

    // 🧠 Validar con el modelo TFLite local
    final resultado = await ServicioTFLite.detectarAnimal(comprimido);
    final etiqueta = resultado["etiqueta"];
    final confianza = resultado["confianza"];

    // ⚠️ Solo permitir “perro” o “gato” con buena confianza
    if (confianza < 0.95 || (etiqueta != "perro" && etiqueta != "gato")) {
      // Si la validación falla, lanzamos la excepción y bloqueamos la subida.
      throw Exception(
        "❌ La imagen no parece contener un perro o gato válido. Por favor, sube una imagen clara de la mascota perdida.",
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child("reportes_mascotas")
        .child(uid)
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

    await ref.putFile(comprimido);
    return await ref.getDownloadURL();
  }

  // 🎥 Subir video (máx 10 segundos)
  Future<String> subirVideo(File archivo) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child("reportes_mascotas")
        .child(uid)
        .child("${DateTime.now().millisecondsSinceEpoch}.mp4");

    await ref.putFile(archivo);
    return await ref.getDownloadURL();
  }

  void removerFoto(String url) {
    reporte.fotos.remove(url);
    _notify();
  }

  // 💾 Guardar reporte en Firestore
  Future<bool> guardarReporte() async {
    try {
      _cargando = true;
      _notify();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final docRef = FirebaseFirestore.instance
          .collection("reportes_mascotas")
          .doc();

      reporte.id = docRef.id;

      await docRef.set(
        reporte.toMap()..addAll({
          "usuarioId": uid,
          "fechaRegistro": FieldValue.serverTimestamp(),
          "estado": "Perdido",
        }),
      );

      // 🔔 Notificación push global
      await NotificacionServicio.enviarPush(
        titulo: "Nuevo reporte 🐾",
        cuerpo: "Se ha registrado una nueva mascota perdida.",
      );

      _cargando = false;
      _notify();
      return true;
    } catch (e) {
      _cargando = false;
      _notify();
      debugPrint("❌ Error al guardar reporte: $e");
      return false;
    }
  }
}
