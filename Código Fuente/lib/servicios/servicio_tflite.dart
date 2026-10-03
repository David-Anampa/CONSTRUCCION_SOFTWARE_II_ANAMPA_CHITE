import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio para inferencia y extraccion de caracteristicas con TensorFlow Lite.
class ServicioTFLite {
  Interpreter? _detectorAnimales;
  Interpreter? _extractorEmbeddings;

  ServicioTFLite({
    Interpreter? detectorAnimales,
    Interpreter? extractorEmbeddings,
  }) : _detectorAnimales = detectorAnimales,
       _extractorEmbeddings = extractorEmbeddings;

  static ServicioTFLite _instancia = ServicioTFLite();

  /// Permite inyectar una instancia simulada para pruebas unitarias.
  @visibleForTesting
  static void setInstancia(ServicioTFLite servicio) {
    _instancia = servicio;
  }

  /// Inicializa ambos modelos de TensorFlow Lite.
  Future<void> inicializar() async {
    final opciones = InterpreterOptions()..threads = 4; // CPU multi-hilo

    _detectorAnimales ??= await Interpreter.fromAsset(
      'assets/model/animales.tflite',
      options: opciones,
    );

    _extractorEmbeddings ??= await Interpreter.fromAsset(
      'assets/model/extractor_animales.tflite',
      options: opciones,
    );
  }

  /// Inicializa ambos modelos en la instancia por defecto.
  static Future<void> inicializarModelos() => _instancia.inicializar();

  /// Detecta el tipo de animal en [imagen] y retorna etiqueta y confianza.
  Future<Map<String, dynamic>> detectarAnimalInstancia(File imagen) async {
    await inicializar();

    final input = await _preprocesarImagen(imagen, 224, 224);
    final output = List<double>.filled(3, 0.0).reshape([1, 3]);
    _detectorAnimales!.run(input, output);

    // Etiquetas en orden alfabetico, igual que en el entrenamiento del modelo.
    final etiquetas = ['gato', 'otro', 'perro'];
    final List<double> resultados = output[0].cast<double>();

    final maxValor = resultados.reduce((a, b) => a > b ? a : b);
    final pred = resultados.indexOf(maxValor);

    final etiqueta = etiquetas[pred];
    final confianza = maxValor;

    return {'etiqueta': etiqueta, 'confianza': confianza};
  }

  /// Detecta el tipo de animal en [imagen] usando la instancia compartida.
  static Future<Map<String, dynamic>> detectarAnimal(File imagen) =>
      _instancia.detectarAnimalInstancia(imagen);

  /// Extrae el vector de caracteristicas (embedding de 1280 dimensiones) de [imagen].
  Future<List<double>> extraerEmbeddingsInstancia(File imagen) async {
    await inicializar();
    final input = await _preprocesarImagen(imagen, 224, 224);

    final output = List.filled(1280, 0.0).reshape([1, 1280]);
    _extractorEmbeddings!.run(input, output);

    return output[0];
  }

  /// Extrae el vector de caracteristicas usando la instancia compartida.
  static Future<List<double>> extraerEmbeddings(File imagen) =>
      _instancia.extraerEmbeddingsInstancia(imagen);

  /// Compara dos imagenes y devuelve la similitud coseno (0 a 1).
  Future<double> compararImagenesInstancia(File img1, File img2) async {
    final emb1 = await extraerEmbeddingsInstancia(img1);
    final emb2 = await extraerEmbeddingsInstancia(img2);

    final dot = _productoPunto(emb1, emb2);
    final norma1 = sqrt(_productoPunto(emb1, emb1));
    final norma2 = sqrt(_productoPunto(emb2, emb2));

    if (norma1 == 0.0 || norma2 == 0.0) return 0.0;
    final similitud = dot / (norma1 * norma2);
    return similitud.clamp(0.0, 1.0);
  }

  /// Compara dos imagenes usando la instancia compartida.
  static Future<double> compararImagenes(File img1, File img2) =>
      _instancia.compararImagenesInstancia(img1, img2);

  /// Convierte [archivo] en tensor float32 [1, height, width, 3] normalizado a [0,1].
  ///
  /// El preprocesamiento ocurre en el hilo de llamada (idealmente un Isolate
  /// para no bloquear la UI si la imagen es grande).
  /// Lanza [FileSystemException] si el archivo no existe.
  /// Lanza [FormatException] si la imagen no puede decodificarse.
  static Future<List<List<List<List<double>>>>> _preprocesarImagen(
    File archivo,
    int width,
    int height,
  ) async {
    if (!archivo.existsSync()) {
      throw FileSystemException(
        'El archivo de imagen no existe.',
        archivo.path,
      );
    }

    // readAsBytes es asíncrono y no bloquea el hilo de UI,
    // a diferencia de readAsBytesSync que congela la app durante la lectura.
    final bytes = await archivo.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException(
        'Formato de imagen inválido o archivo corrupto.',
      );
    }

    final image = img.copyResize(decoded, width: width, height: height);

    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b];
        }),
      ),
    );

    return input;
  }

  /// 🔹 Producto punto entre dos vectores
  static double _productoPunto(List<double> a, List<double> b) {
    double suma = 0;
    for (int i = 0; i < a.length; i++) {
      suma += a[i] * b[i];
    }
    return suma;
  }
}
