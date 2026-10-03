import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sos_mascotas/servicios/servicio_tflite.dart';

/// Umbral mínimo de confianza aceptado por el modelo TFLite para
/// considerar que una imagen contiene un perro o gato válido.
const double kUmbralTflite = 0.95;

/// Utilidad reutilizable para procesamiento, validación y subida de imágenes.
///
/// Centraliza operaciones comunes para evitar duplicación entre ViewModels:
/// compresión, validación con TFLite y subida a Firebase Storage.
class ImagenUtil {
  ImagenUtil._();

  /// Comprime un [archivo] de imagen en formato JPEG.
  ///
  /// - [calidad]: valor entre 0 y 100 (por defecto 70).
  /// - Retorna el archivo comprimido, o el original si la compresión falla.
  static Future<File> comprimirImagen(File archivo, {int calidad = 70}) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      archivo.absolute.path,
      targetPath,
      quality: calidad,
    );

    return result != null ? File(result.path) : archivo;
  }

  /// Valida que [archivo] contenga un perro o gato (usando TFLite), lo comprime
  /// y lo sube a Firebase Storage bajo la ruta [storagePath]/[uid]/[timestamp].jpg.
  ///
  /// - [storagePath]: carpeta raíz en Storage (p.ej. `"reportes_mascotas"` o `"avistamientos"`).
  /// - Lanza [Exception] si la imagen no supera el umbral de confianza del modelo.
  /// - Lanza [StateError] si no hay un usuario autenticado.
  /// - Retorna la URL de descarga pública del archivo subido.
  static Future<String> validarYSubirFoto(
    File archivo, {
    required String storagePath,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'No hay un usuario autenticado. Inicie sesión antes de subir fotos.',
      );
    }

    final comprimido = await comprimirImagen(archivo);

    final resultado = await ServicioTFLite.detectarAnimal(comprimido);
    final etiqueta = resultado['etiqueta'] as String;
    final confianza = resultado['confianza'] as double;

    // Solo se permiten perro/gato con confianza >= kUmbralTflite (0.95).
    // Un umbral bajo causaría falsos positivos que degradan la calidad del reporte.
    if (confianza < kUmbralTflite ||
        (etiqueta != 'perro' && etiqueta != 'gato')) {
      throw Exception(
        '❌ La imagen no parece contener un perro o gato válido. '
        'Por favor, sube una imagen clara de la mascota.',
      );
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child(storagePath)
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(comprimido);
    return ref.getDownloadURL();
  }
}
