// /**
//  * Archivo/Clase : servicio_tflite.dart / ServicioTFLite
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Servicio de visión computacional en el dispositivo (on-device ML) basado
//  *                 en TensorFlow Lite para clasificar mascotas y comparar similitud visual.
//  * Se vincula con: - USA: tflite_flutter (Interpreter), package:image (decodeImage, copyResize)
//  *                   y los modelos 'assets/model/animales.tflite' y
//  *                   'assets/model/extractor_animales.tflite'.
//  *                 - ES USADO POR: main.dart, ImagenUtil (imagen_util.dart), AvistamientoVM
//  *                   (avistamiento_vm.dart), PantallaReporteMascota y PantallaAvistamiento.
//  * Funcionamiento: Preprocesa imágenes a tensores RGB normalizados de 224x224, ejecuta un
//  *                 clasificador de 3 clases ('gato', 'otro', 'perro') y un extractor de
//  *                 embeddings de 1280 dimensiones que se comparan mediante similitud coseno.
//  * Requerimiento : RF-04 (Validación de mascota con IA), RF-05 (Coincidencia visual de avistamientos)
//  */

import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio para inferencia y extraccion de caracteristicas con TensorFlow Lite.
///
/// Gestiona dos intérpretes locales: uno para detección de especie animal y
/// otro para extracción de vectores de características (embeddings visuales).
class ServicioTFLite {
  Interpreter? _detectorAnimales;
  Interpreter? _extractorEmbeddings;

  /// Crea una instancia de [ServicioTFLite] permitiendo inyectar intérpretes preconfigurados.
  ///
  /// - Parámetros: [detectorAnimales] intérprete clasificador opcional;
  ///   [extractorEmbeddings] intérprete extractor de características opcional.
  ServicioTFLite({
    Interpreter? detectorAnimales,
    Interpreter? extractorEmbeddings,
  }) : _detectorAnimales = detectorAnimales,
       _extractorEmbeddings = extractorEmbeddings;

  static ServicioTFLite _instancia = ServicioTFLite();

  /// Permite inyectar una instancia simulada para pruebas unitarias.
  ///
  /// - Parámetros: [servicio] instancia sustituta de [ServicioTFLite].
  /// - Efectos secundarios: Reemplaza el singleton estático [_instancia].
  @visibleForTesting
  static void setInstancia(ServicioTFLite servicio) {
    _instancia = servicio;
  }

  /// Inicializa ambos modelos de TensorFlow Lite.
  ///
  /// - Parámetros: Ninguno.
  /// - Precondiciones: Los archivos `.tflite` deben existir en `assets/model/`.
  /// - Valor de retorno: [Future<void>].
  /// - Errores: Lanza excepción si el asset no existe o el binario TFLite es inválido.
  /// - Efectos secundarios: Reserva memoria nativa para los intérpretes con 4 hilos de CPU.
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
  ///
  /// - Valor de retorno: [Future<void>] que completa al cargar los intérpretes.
  static Future<void> inicializarModelos() => _instancia.inicializar();

  /// Detecta el tipo de animal en [imagen] y retorna etiqueta y confianza.
  ///
  /// - Parámetros: [imagen] archivo de imagen local a evaluar.
  /// - Precondiciones: [imagen] debe ser un archivo existente y decodificable.
  /// - Valor de retorno: Mapa con `'etiqueta'` (`'gato'`, `'otro'` o `'perro'`) y `'confianza'` (`double` entre 0.0 y 1.0).
  /// - Errores: Propaga [FileSystemException] o [FormatException] desde [_preprocesarImagen].
  /// - Efectos secundarios: Inicializa los intérpretes si aún no estaban cargados.
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
  ///
  /// - Parámetros: [imagen] archivo local de la fotografía.
  /// - Valor de retorno: Mapa con `'etiqueta'` y `'confianza'`.
  static Future<Map<String, dynamic>> detectarAnimal(File imagen) =>
      _instancia.detectarAnimalInstancia(imagen);

  /// Extrae el vector de caracteristicas (embedding de 1280 dimensiones) de [imagen].
  ///
  /// - Parámetros: [imagen] archivo local de imagen.
  /// - Precondiciones: El archivo debe existir y representar una imagen válida.
  /// - Valor de retorno: `List<double>` de longitud 1280 correspondiente a la capa de características.
  /// - Errores: Lanza [FileSystemException] o [FormatException] si el archivo falla al leerse.
  /// - Efectos secundarios: Inicializa los intérpretes TFLite si es necesario.
  Future<List<double>> extraerEmbeddingsInstancia(File imagen) async {
    await inicializar();
    final input = await _preprocesarImagen(imagen, 224, 224);

    final output = List.filled(1280, 0.0).reshape([1, 1280]);
    _extractorEmbeddings!.run(input, output);

    return output[0];
  }

  /// Extrae el vector de caracteristicas usando la instancia compartida.
  ///
  /// - Parámetros: [imagen] archivo de imagen local.
  /// - Valor de retorno: Vector `List<double>` de 1280 dimensiones.
  static Future<List<double>> extraerEmbeddings(File imagen) =>
      _instancia.extraerEmbeddingsInstancia(imagen);

  /// Compara dos imagenes y devuelve la similitud coseno (0 a 1).
  ///
  /// - Parámetros: [img1] primera imagen local; [img2] segunda imagen local.
  /// - Valor de retorno: `double` acotado en `[0.0, 1.0]` donde 1.0 representa máxima similitud.
  /// - Errores: Propaga excepciones de lectura o decodificación de cualquiera de las imágenes.
  /// - Ejemplo: `final sim = await servicio.compararImagenesInstancia(fotoAvistada, fotoReporte);`
  // FUENTE: [por confirmar con el autor] (Fórmula estándar de similitud coseno sobre embeddings L2)
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
  ///
  /// - Parámetros: [img1] y [img2] archivos de imagen a contrastar.
  /// - Valor de retorno: Coeficiente de similitud coseno en `[0.0, 1.0]`.
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
  ///
  /// - Parámetros: [a] y [b] listas numéricas de igual dimensión.
  /// - Precondiciones: `a.length <= b.length`.
  /// - Valor de retorno: Suma acumulada de los productos componente a componente.
  static double _productoPunto(List<double> a, List<double> b) {
    double suma = 0;
    for (int i = 0; i < a.length; i++) {
      suma += a[i] * b[i];
    }
    return suma;
  }
}
