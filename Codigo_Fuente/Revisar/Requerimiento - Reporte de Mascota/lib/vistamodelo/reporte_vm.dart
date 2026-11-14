import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sos_mascotas/servicios/firebase_availability.dart' as fb_avail;
import 'package:sos_mascotas/servicios/notificacion_servicio.dart';
import 'package:sos_mascotas/servicios/servicio_tflite.dart';
import '../../modelo/reporte_mascota.dart';

class ReporteMascotaVM extends ChangeNotifier {
  int _paso = 0;
  ReporteMascota reporte = ReporteMascota();
  bool _cargando = false;
  bool _disposed = false; // 👈 nuevo flag de control
  String? _fotoTemporal;

  // ✅ FormKeys para validaciones
  final formKeyPaso1 = GlobalKey<FormState>();
  final formKeyPaso2 = GlobalKey<FormState>();
  final formKeyPaso3 = GlobalKey<FormState>();

  // Getters
  int get paso => _paso;
  bool get cargando => _cargando;
  String? get fotoTemporal => _fotoTemporal;
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

  void limpiarFotos() {
    reporte.fotos.clear();
    _fotoTemporal = null;
    _notify();
  }

  void mostrarFotoTemporal(String url) {
    _fotoTemporal = url;
    _notify();
  }

  void limpiarFotoTemporal() {
    _fotoTemporal = null;
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
  Future<String> subirFoto(dynamic archivo) async {
    final bytes = archivo is Uint8List
        ? archivo
        : archivo is File
        ? await archivo.readAsBytes()
        : null;

    if (bytes == null) {
      throw Exception(
        "❌ La imagen no se pudo leer. Intenta nuevamente con otra foto.",
      );
    }

    final resultado = await ServicioTFLite.detectarAnimal(bytes);
    final etiqueta = resultado["etiqueta"];
    final confianza = resultado["confianza"];

    print('VM: etiqueta=$etiqueta confianza=$confianza');

    if (confianza < 0.9 || (etiqueta != "perro" && etiqueta != "gato")) {
      throw Exception(
        "❌ La imagen no es válida. Debe ser una foto clara de una mascota, como un perro o gato.",
      );
    }

    final file = archivo is File ? archivo : null;
    final comprimido = file != null ? await _comprimirImagen(file) : null;
    final finalBytes = comprimido != null ? await comprimido.readAsBytes() : bytes;

    final firebaseEnabled = fb_avail.firebaseAvailable && Firebase.apps.isNotEmpty;

    if (!firebaseEnabled) {
      return 'data:image/jpeg;base64,${base64Encode(finalBytes)}';
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'offline_user';
    final ref = FirebaseStorage.instance
        .ref()
        .child("reportes_mascotas")
        .child(uid)
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

    await ref.putData(finalBytes);
    return await ref.getDownloadURL();
  }

  // 🎥 Subir video (máx 10 segundos)
  Future<String> subirVideo(File archivo) async {
    if (!fb_avail.firebaseAvailable || Firebase.apps.isEmpty) {
      throw Exception("❌ La carga de videos no está disponible en este entorno.");
    }

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

      if (fb_avail.firebaseAvailable && Firebase.apps.isNotEmpty) {
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

        await NotificacionServicio.enviarPush(
          titulo: "Nuevo reporte 🐾",
          cuerpo: "Se ha registrado una nueva mascota perdida.",
        );
      }

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
