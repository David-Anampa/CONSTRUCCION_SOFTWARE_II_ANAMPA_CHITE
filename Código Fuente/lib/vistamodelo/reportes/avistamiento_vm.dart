import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sos_mascotas/servicios/notificacion_servicio.dart';
import 'package:sos_mascotas/servicios/servicio_tflite.dart';
import 'package:sos_mascotas/utils/imagen_util.dart';
import '../../modelo/avistamiento.dart';

/// ViewModel para registrar un avistamiento de mascota.
///
/// Gestiona la subida de foto (con validación TFLite), el guardado en Firestore,
/// la búsqueda de coincidencias con reportes cercanos y la notificación al dueño.
class AvistamientoVM extends ChangeNotifier {
  Avistamiento avistamiento = Avistamiento();
  bool _cargando = false;

  bool get cargando => _cargando;

  void setDireccion(String v) => avistamiento.direccion = v;
  void setDescripcion(String v) => avistamiento.descripcion = v;

  /// Valida que [archivo] contenga un perro o gato y lo sube a Storage.
  ///
  /// Delega en [ImagenUtil.validarYSubirFoto] para centralizar la lógica
  /// compartida con [ReporteMascotaVM]. Lanza [Exception] si la imagen
  /// no supera el umbral de confianza del modelo TFLite.
  Future<String> subirFoto(File archivo) =>
      ImagenUtil.validarYSubirFoto(archivo, storagePath: 'avistamientos');

  /// Persiste el avistamiento en Firestore, otorga PataCoins al registrador
  /// y lanza la búsqueda de coincidencias con reportes cercanos.
  ///
  /// Retorna `true` si todo fue exitoso, `false` en caso de error.
  /// Lanza [StateError] si no hay usuario autenticado al momento de guardar.
  Future<bool> guardarAvistamiento() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'No hay usuario autenticado para guardar el avistamiento.',
      );
    }

    try {
      _cargando = true;
      notifyListeners();

      final docRef = FirebaseFirestore.instance
          .collection('avistamientos')
          .doc();

      avistamiento.id = docRef.id;
      avistamiento.usuarioId = uid;
      avistamiento.direccion = avistamiento.direccion.trim();
      avistamiento.distrito = avistamiento.distrito.trim();

      await docRef.set(
        avistamiento.toMap()
          ..addAll({'fechaRegistro': FieldValue.serverTimestamp()}),
      );

      // Otorgar PataCoins por contribuir con un avistamiento.
      await _otorgarPataCoins(uid, 10);

      // La búsqueda de coincidencias es best-effort; su fallo no debe cancelar el avistamiento.
      await _buscarCoincidenciaConReportes(avistamiento);

      await NotificacionServicio.enviarPush(
        titulo: 'Nuevo avistamiento 👀',
        cuerpo: 'Se ha registrado un nuevo avistamiento de mascota.',
      );

      _cargando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _cargando = false;
      notifyListeners();
      debugPrint('❌ Error al guardar avistamiento: $e');
      return false;
    }
  }

  // 🔹 Calcular distancia entre coordenadas (Haversine)
  double _calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Radio de la Tierra en km
    final dLat = _gradosARadianes(lat2 - lat1);
    final dLon = _gradosARadianes(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradosARadianes(lat1)) *
            cos(_gradosARadianes(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _gradosARadianes(double grados) => grados * pi / 180.0;

  /// Compara el avistamiento con reportes activos de mascotas perdidas.
  ///
  /// Descarta reportes a más de 9 km (radio práctico para búsqueda urbana).
  /// Si la similitud de imagen supera 0.5 vincula el avistamiento al reporte
  /// y notifica al dueño. Es best-effort: los errores se loguean y no re-lanzan
  /// para no cancelar el avistamiento ya guardado.
  Future<void> _buscarCoincidenciaConReportes(Avistamiento av) async {
    try {
      final reportes = await FirebaseFirestore.instance
          .collection('reportes_mascotas')
          .where('estado', isEqualTo: 'Perdido')
          .get();

      for (var doc in reportes.docs) {
        final data = doc.data();
        final fotos = List<String>.from(data['fotos'] ?? []);
        if (fotos.isEmpty) continue;

        final distancia = _calcularDistancia(
          av.latitud ?? 0,
          av.longitud ?? 0,
          (data['latitud'] ?? 0).toDouble(),
          (data['longitud'] ?? 0).toDouble(),
        );

        // 9 km es el radio máximo definido para considerar una coincidencia posible.
        if (distancia > 9.0) continue;

        final similitud = await _compararImagenes(av.foto, fotos.first);

        if (similitud >= 0.5) {
          await FirebaseFirestore.instance
              .collection('avistamientos')
              .doc(av.id)
              .update({'reporteId': doc.id});

          final usuarioId = data['usuarioId'] as String?;
          if (usuarioId != null) {
            await _notificarCoincidencia(usuarioId, av.id);
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error al buscar coincidencias: $e');
    }
  }

  // 🧠 Comparar imágenes localmente usando embeddings TFLite
  Future<double> _compararImagenes(String url1, String url2) async {
    try {
      if (url1 == url2) return 1.0;
      final file1 = await _descargarImagen(url1);
      final file2 = await _descargarImagen(url2);
      return await ServicioTFLite.compararImagenes(file1, file2);
    } catch (e) {
      debugPrint("⚠️ Error comparando imágenes localmente: $e");
      return 0.0;
    }
  }

  /// Descarga la imagen desde [url] a un archivo temporal y la retorna.
  ///
  /// Lanza [HttpException] si el servidor retorna un status HTTP != 200.
  Future<File> _descargarImagen(String url) async {
    final response = await http.get(Uri.parse(url));

    // Verificar que la respuesta sea exitosa antes de escribir los bytes,
    // para no persistir una página de error HTML como si fuera una imagen.
    if (response.statusCode != 200) {
      throw Exception(
        'Error descargando imagen ($url): HTTP ${response.statusCode}',
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  // 🔔 Notificar al dueño del reporte si hay coincidencia
  Future<void> _notificarCoincidencia(
    String usuarioId,
    String avistamientoId,
  ) async {
    try {
      await NotificacionServicio.enviarPush(
        titulo: "Posible coincidencia 🐾",
        cuerpo: "Tu mascota perdida podría haber sido vista recientemente.",
      );
    } catch (e) {
      debugPrint("Error enviando notificación de coincidencia: $e");
    }
  }

  // 🧩 Validar campos antes de guardar
  bool _esUbicacionValida(double? lat, double? lon) =>
      lat != null && lon != null && (lat != 0 || lon != 0);

  String? validarCampos() {
    final desc = avistamiento.descripcion.trim();
    final foto = avistamiento.foto.trim();

    if (desc.isEmpty) return 'La descripción no puede estar vacía';
    if (foto.isEmpty) return 'Debe adjuntar una foto del avistamiento';
    if (!_esUbicacionValida(avistamiento.latitud, avistamiento.longitud)) {
      return 'Debe seleccionar una ubicación válida';
    }
    return null;
  }

  /// Incrementa los PataCoins del usuario [uid] en [cantidad].
  ///
  /// Usa merge para no sobreescribir otros campos del documento.
  Future<void> _otorgarPataCoins(String uid, int cantidad) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'patacoins': FieldValue.increment(cantidad),
    }, SetOptions(merge: true));
  }

  // ✅ Actualizar ubicación
  void actualizarUbicacion({
    required String direccion,
    required String distrito,
    required double latitud,
    required double longitud,
  }) {
    avistamiento.direccion = direccion;
    avistamiento.distrito = distrito;
    avistamiento.latitud = latitud;
    avistamiento.longitud = longitud;
    notifyListeners();
  }
}
