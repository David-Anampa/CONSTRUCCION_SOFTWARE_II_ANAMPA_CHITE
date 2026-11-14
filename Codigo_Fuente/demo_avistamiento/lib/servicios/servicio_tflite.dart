import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio estático para operaciones de Machine Learning con TFLite.
///
/// Proporciona detección de animales (perro/gato/otro) y comparación
/// de similitud entre imágenes mediante embeddings.
///
/// Archivo copiado íntegramente de:
/// [SosMascota/lib/servicios/servicio_tflite.dart]
class ServicioTFLite {
  static Interpreter? _detectorAnimales;
  static Interpreter? _extractorEmbeddings;

  /// Inicializa ambos modelos TFLite con soporte multi-hilo (CPU).
  static Future<void> inicializarModelos() async {
    // Usar 4 hilos para mejorar el rendimiento en la inferencia
    final opciones = InterpreterOptions()..threads = 4;

    // Inicializar solo si aún no están cargados (patrón singleton)
    _detectorAnimales ??= await Interpreter.fromAsset(
      'assets/model/animales.tflite',
      options: opciones,
    );

    _extractorEmbeddings ??= await Interpreter.fromAsset(
      'assets/model/extractor_animales.tflite',
      options: opciones,
    );
  }

  /// Detecta el tipo de animal en [imagen] y devuelve etiqueta + probabilidad.
  ///
  /// Retorna un [Map] con:
  /// - `"etiqueta"`: `"perro"`, `"gato"` u `"otro"`.
  /// - `"confianza"`: valor entre 0.0 y 1.0.
  static Future<Map<String, dynamic>> detectarAnimal(File imagen) async {
    await inicializarModelos();

    final input = _preprocesarImagen(imagen, 224, 224);
    final output = List<double>.filled(3, 0.0).reshape([1, 3]);
    _detectorAnimales!.run(input, output);

    // Etiquetas en orden alfabético de entrenamiento del modelo
    final etiquetas = ["gato", "otro", "perro"];
    final List<double> resultados = output[0].cast<double>();

    final maxValor = resultados.reduce((a, b) => a > b ? a : b);
    final pred = resultados.indexOf(maxValor);

    final etiqueta = etiquetas[pred];
    final confianza = maxValor;

    print("🔍 Salida del modelo: $output");
    print(
      "🐾 Clase predicha: $etiqueta (${(confianza * 100).toStringAsFixed(2)}%)",
    );

    return {"etiqueta": etiqueta, "confianza": confianza};
  }

  /// Extrae el vector de características (embedding de 1280 dimensiones)
  /// de [imagen] usando el modelo extractor.
  static Future<List<double>> extraerEmbeddings(File imagen) async {
    await inicializarModelos();
    final input = _preprocesarImagen(imagen, 224, 224);

    final output = List.filled(1280, 0.0).reshape([1, 1280]);
    _extractorEmbeddings!.run(input, output);

    return output[0];
  }

  /// Compara dos imágenes y devuelve su similitud coseno entre 0.0 y 1.0.
  ///
  /// Valores cercanos a 1.0 indican imágenes muy similares.
  static Future<double> compararImagenes(File img1, File img2) async {
    final emb1 = await extraerEmbeddings(img1);
    final emb2 = await extraerEmbeddings(img2);

    final dot = _productoPunto(emb1, emb2);
    final norma1 = sqrt(_productoPunto(emb1, emb1));
    final norma2 = sqrt(_productoPunto(emb2, emb2));

    final similitud = dot / (norma1 * norma2);
    return similitud.clamp(0.0, 1.0);
  }

  /// Convierte [archivo] en un tensor 224×224×3 normalizado en rango [0, 1].
  ///
  /// Este formato es el requerido por los modelos MobileNet entrenados.
  static List<List<List<List<double>>>> _preprocesarImagen(
    File archivo,
    int width,
    int height,
  ) {
    final bytes = archivo.readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    image = img.copyResize(image!, width: width, height: height);

    final input = List.generate(
      1,
      (_) => List.generate(
        height,
        (y) => List.generate(width, (x) {
          final pixel = image!.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b];
        }),
      ),
    );

    return input;
  }

  /// Calcula el producto punto entre dos vectores de igual longitud.
  static double _productoPunto(List<double> a, List<double> b) {
    double suma = 0;
    for (int i = 0; i < a.length; i++) {
      suma += a[i] * b[i];
    }
    return suma;
  }
}
