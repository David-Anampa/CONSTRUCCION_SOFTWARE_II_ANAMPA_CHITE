import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sos_mascotas/servicios/notificacion_servicio.dart';
import 'package:sos_mascotas/servicios/servicio_tflite.dart';
import '../../modelo/avistamiento.dart';

/// ViewModel para el registro y gestión de avistamientos de mascotas.
///
/// Coordina la validación de imágenes con TFLite, la subida a Firebase
/// Storage, la persistencia en Firestore y la búsqueda automática de
/// coincidencias con reportes de mascotas perdidas.
class AvistamientoVM extends ChangeNotifier {

  // ─── Constantes de negocio ───────────────────────────────────────────────

  /// Umbral mínimo de confianza (0–1) que debe alcanzar el modelo TFLite
  /// para aceptar que la imagen contiene un perro o gato válido.
  static const double _umbralConfianzaTflite = 0.95;

  /// Calidad de compresión JPEG aplicada antes de subir imágenes (0–100).
  static const int _calidadCompresionJpeg = 70;

  /// Distancia máxima en kilómetros para considerar que un avistamiento
  /// podría estar relacionado con un reporte de mascota perdida.
  static const double _distanciaMaxCoincidenciaKm = 9.0;

  /// Similitud mínima entre imágenes (0–1) para vincular un avistamiento
  /// con un reporte existente.
  static const double _umbralSimilitudImagen = 0.5;

  /// Radio de la Tierra en kilómetros, usado en la fórmula de Haversine.
  static const double _radioTierraKm = 6371.0;

  // ─── Estado ──────────────────────────────────────────────────────────────

  Avistamiento avistamiento = Avistamiento();
  bool _cargando = false;

  bool get cargando => _cargando;

  // ─── Setters de campos individuales ──────────────────────────────────────

  void setDireccion(String nuevaDireccion) =>
      avistamiento.direccion = nuevaDireccion;

  void setDescripcion(String nuevaDescripcion) =>
      avistamiento.descripcion = nuevaDescripcion;

  // ─── Foto ─────────────────────────────────────────────────────────────────

  /// Comprime [archivoOriginal] en formato JPEG antes de subirlo.
  ///
  /// Retorna el archivo comprimido, o el original si la compresión falla.
  Future<File> _comprimirImagen(File archivoOriginal) async {
    final directorioTemporal = await getTemporaryDirectory();
    final rutaDestino =
        "${directorioTemporal.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final archivoComprimido = await FlutterImageCompress.compressAndGetFile(
      archivoOriginal.absolute.path,
      rutaDestino,
      quality: _calidadCompresionJpeg,
    );

    return archivoComprimido != null
        ? File(archivoComprimido.path)
        : archivoOriginal;
  }

  /// Valida con TFLite que [archivo] contiene un perro o gato y lo sube
  /// a Firebase Storage.
  ///
  /// Lanza [Exception] si:
  /// - El archivo no existe en disco.
  /// - La imagen no supera el umbral de confianza del modelo.
  /// - El animal detectado no es perro ni gato.
  ///
  /// Retorna la URL de descarga de Firebase Storage si la validación pasa.
  Future<String> subirFoto(File archivo) async {
    if (!archivo.existsSync()) {
      throw Exception(
        'El archivo de imagen no existe. Por favor, selecciona la foto nuevamente.',
      );
    }

    final archivoComprimido = await _comprimirImagen(archivo);
    final resultado = await ServicioTFLite.detectarAnimal(archivoComprimido);

    final tipoAnimalDetectado = resultado["etiqueta"] as String;
    final confianzaDeteccion = resultado["confianza"] as double;

    final bool esAnimalValido =
        tipoAnimalDetectado == "perro" || tipoAnimalDetectado == "gato";

    if (confianzaDeteccion < _umbralConfianzaTflite || !esAnimalValido) {
      throw Exception(
        "❌ La imagen no parece contener un perro o gato válido. "
        "Intenta subir una imagen más clara.",
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final referenciaStorage = FirebaseStorage.instance
        .ref()
        .child("avistamientos")
        .child(uid)
        .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

    await referenciaStorage.putFile(archivoComprimido);
    return await referenciaStorage.getDownloadURL();
  }

  // ─── Persistencia ─────────────────────────────────────────────────────────

  /// Valida los campos del avistamiento y lo persiste en Firestore.
  ///
  /// Retorna `true` si el guardado fue exitoso, `false` en caso de error.
  /// Falla rápido si los datos no son válidos antes de intentar la escritura.
  Future<bool> guardarAvistamiento() async {
    final mensajeErrorValidacion = validarCampos();
    if (mensajeErrorValidacion != null) {
      debugPrint("❌ Validación fallida: $mensajeErrorValidacion");
      return false;
    }

    try {
      _cargando = true;
      notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final referenciaDocumento = FirebaseFirestore.instance
          .collection("avistamientos")
          .doc();

      avistamiento.id = referenciaDocumento.id;
      avistamiento.usuarioId = uid;
      avistamiento.direccion = avistamiento.direccion.trim();
      avistamiento.distrito = avistamiento.distrito.trim();

      await referenciaDocumento.set(
        avistamiento.toMap()
          ..addAll({"fechaRegistro": FieldValue.serverTimestamp()}),
      );

      await _buscarCoincidenciaConReportes(avistamiento);

      await NotificacionServicio.enviarPush(
        titulo: "Nuevo avistamiento 👀",
        cuerpo: "Se ha registrado un nuevo avistamiento de mascota.",
      );

      _cargando = false;
      notifyListeners();
      return true;
    } catch (error) {
      _cargando = false;
      notifyListeners();
      debugPrint("❌ Error al guardar avistamiento: $error");
      return false;
    }
  }

  // ─── Coincidencia con reportes ────────────────────────────────────────────

  /// Calcula la distancia en kilómetros entre dos puntos geográficos
  /// usando la fórmula de Haversine.
  ///
  /// Fuente: https://en.wikipedia.org/wiki/Haversine_formula
  ///
  /// @param latitudOrigen   Latitud del punto de origen en grados decimales.
  /// @param longitudOrigen  Longitud del punto de origen en grados decimales.
  /// @param latitudDestino  Latitud del punto destino en grados decimales.
  /// @param longitudDestino Longitud del punto destino en grados decimales.
  /// @return Distancia en kilómetros entre los dos puntos.
  double _calcularDistanciaKm(
    double latitudOrigen,
    double longitudOrigen,
    double latitudDestino,
    double longitudDestino,
  ) {
    final diferenciaLat = _gradosARadianes(latitudDestino - latitudOrigen);
    final diferenciaLon = _gradosARadianes(longitudDestino - longitudOrigen);

    final factorHaversine =
        sin(diferenciaLat / 2) * sin(diferenciaLat / 2) +
        cos(_gradosARadianes(latitudOrigen)) *
            cos(_gradosARadianes(latitudDestino)) *
            sin(diferenciaLon / 2) *
            sin(diferenciaLon / 2);

    final angulosCentrales =
        2 * atan2(sqrt(factorHaversine), sqrt(1 - factorHaversine));

    return _radioTierraKm * angulosCentrales;
  }

  /// Convierte [grados] decimales a radianes.
  double _gradosARadianes(double grados) => grados * pi / 180.0;

  /// Busca reportes de mascotas perdidas cercanos al [avistamientoNuevo]
  /// y, si hay coincidencia por distancia e imagen, los vincula.
  Future<void> _buscarCoincidenciaConReportes(
    Avistamiento avistamientoNuevo,
  ) async {
    try {
      final reportesPerdidos = await FirebaseFirestore.instance
          .collection("reportes_mascotas")
          .where("estado", isEqualTo: "Perdido")
          .get();

      for (final documentoReporte in reportesPerdidos.docs) {
        final datosReporte = documentoReporte.data();
        final fotosReporte = List<String>.from(datosReporte["fotos"] ?? []);
        if (fotosReporte.isEmpty) continue;

        final distanciaKm = _calcularDistanciaKm(
          avistamientoNuevo.latitud ?? 0,
          avistamientoNuevo.longitud ?? 0,
          (datosReporte["latitud"] ?? 0).toDouble(),
          (datosReporte["longitud"] ?? 0).toDouble(),
        );

        if (distanciaKm > _distanciaMaxCoincidenciaKm) continue;

        final similitudImagen = await _compararImagenes(
          avistamientoNuevo.foto,
          fotosReporte.first,
        );

        if (similitudImagen >= _umbralSimilitudImagen) {
          await FirebaseFirestore.instance
              .collection("avistamientos")
              .doc(avistamientoNuevo.id)
              .update({"reporteId": documentoReporte.id});

          final idUsuarioDueno = datosReporte["usuarioId"] as String?;
          if (idUsuarioDueno != null) {
            await _notificarCoincidencia(
              idUsuarioDueno,
              avistamientoNuevo.id,
            );
          }
          break;
        }
      }
    } catch (error) {
      debugPrint("⚠️ Error al buscar coincidencias con reportes: $error");
    }
  }

  /// Compara dos imágenes por URL usando embeddings TFLite y retorna
  /// su grado de similitud entre 0.0 (ninguna) y 1.0 (idénticas).
  ///
  /// Retorna `0.0` si la comparación falla, para no bloquear el flujo.
  Future<double> _compararImagenes(
    String urlImagen1,
    String urlImagen2,
  ) async {
    try {
      if (urlImagen1 == urlImagen2) return 1.0;
      final archivoImagen1 = await _descargarImagenTemporal(urlImagen1);
      final archivoImagen2 = await _descargarImagenTemporal(urlImagen2);
      return await ServicioTFLite.compararImagenes(
        archivoImagen1,
        archivoImagen2,
      );
    } catch (error) {
      debugPrint("⚠️ Error comparando imágenes: $error");
      return 0.0;
    }
  }

  /// Descarga la imagen desde [url] a un archivo temporal en disco.
  Future<File> _descargarImagenTemporal(String url) async {
    final respuesta = await http.get(Uri.parse(url));
    final directorioTemporal = await getTemporaryDirectory();
    final archivoTemporal = File(
      "${directorioTemporal.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );
    await archivoTemporal.writeAsBytes(respuesta.bodyBytes);
    return archivoTemporal;
  }

  // ─── Notificaciones ───────────────────────────────────────────────────────

  /// Envía una notificación push al usuario con [idUsuario] informando
  /// que su mascota perdida podría haber sido avistada.
  Future<void> _notificarCoincidencia(
    String idUsuario,
    String idAvistamiento,
  ) async {
    try {
      await NotificacionServicio.enviarPush(
        titulo: "Posible coincidencia 🐾",
        cuerpo: "Tu mascota perdida podría haber sido vista recientemente.",
      );
    } catch (error) {
      debugPrint("Error enviando notificación de coincidencia: $error");
    }
  }

  // ─── Validación ───────────────────────────────────────────────────────────

  /// Verifica que las coordenadas [latitud] y [longitud] no sean nulas ni cero.
  bool _esUbicacionValida(double? latitud, double? longitud) =>
      latitud != null && longitud != null && (latitud != 0 || longitud != 0);

  /// Valida todos los campos requeridos del avistamiento.
  ///
  /// Retorna un mensaje de error descriptivo si algún campo no es válido,
  /// o `null` si todos los campos son correctos.
  String? validarCampos() {
    final descripcionLimpia = avistamiento.descripcion.trim();
    final fotoUrl = avistamiento.foto.trim();

    if (descripcionLimpia.isEmpty) {
      return 'La descripción no puede estar vacía';
    }
    if (fotoUrl.isEmpty) {
      return 'Debe adjuntar una foto del avistamiento';
    }
    if (!_esUbicacionValida(avistamiento.latitud, avistamiento.longitud)) {
      return 'Debe seleccionar una ubicación válida';
    }
    return null;
  }

  // ─── Ubicación ────────────────────────────────────────────────────────────

  /// Actualiza la ubicación del avistamiento con los datos del mapa.
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
