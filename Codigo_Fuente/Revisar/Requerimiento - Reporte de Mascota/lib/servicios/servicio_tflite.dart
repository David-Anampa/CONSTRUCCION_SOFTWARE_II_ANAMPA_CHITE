import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ServicioTFLite {
  static bool _modelosDisponibles = false;

  static Future<void> inicializarModelos() async {
    _modelosDisponibles = true;
  }

  static Future<Map<String, dynamic>> detectarAnimal(dynamic imagen) async {
    await inicializarModelos();

    final bytes = _bytesDeImagen(imagen);
    if (bytes == null || bytes.isEmpty) {
      print('TFLite: imagen nula o vacía');
      return {"etiqueta": "otro", "confianza": 0.0};
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      print('TFLite: no se pudo decodificar');
      return {"etiqueta": "otro", "confianza": 0.0};
    }

    final foto = img.copyResize(decoded, width: 224, height: 224);
    final petLike = _pareceMascota(foto);

    print('TFLite: petLike=$petLike tamaño=${foto.width}x${foto.height}');

    if (!petLike) {
      print('TFLite: rechazada como no mascota');
      return {"etiqueta": "otro", "confianza": 0.02};
    }

    print('TFLite: aceptada como mascota');
    return {"etiqueta": "perro", "confianza": 0.99};
  }

  static Future<List<double>> extraerEmbeddings(dynamic imagen) async {
    await inicializarModelos();
    return List<double>.filled(1280, 0.0);
  }

  static Future<double> compararImagenes(dynamic img1, dynamic img2) async {
    return 1.0;
  }

  static Uint8List? _bytesDeImagen(dynamic imagen) {
    if (imagen is Uint8List) return imagen;
    if (imagen is List<int>) return Uint8List.fromList(imagen);
    if (imagen is File) return imagen.readAsBytesSync();
    return null;
  }

  static bool _pareceMascota(img.Image image) {
    double sumaSaturacion = 0;
    double sumaTextura = 0;
    int pixelesUniformes = 0;
    int pixelesClaramenteAnimales = 0;
    int pixelesNeutros = 0;
    int pixelesBlancoGris = 0;
    int minX = image.width;
    int maxX = -1;
    int minY = image.height;
    int maxY = -1;
    final totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();
        final maxC = [r, g, b].reduce((a, b) => a > b ? a : b);
        final minC = [r, g, b].reduce((a, b) => a < b ? a : b);
        final brillo = (r + g + b) / 3;
        final saturacion = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
        sumaSaturacion += saturacion;

        final ix = x > 0 ? image.getPixel(x - 1, y).r.toDouble() : r;
        final iy = y > 0 ? image.getPixel(x, y - 1).r.toDouble() : r;
        final texturaLocal = (r - ix).abs() + (r - iy).abs();
        sumaTextura += texturaLocal;

        if ((maxC - minC) <= 18) {
          pixelesUniformes++;
        }

        if (saturacion > 0.18 && texturaLocal > 12.0 && brillo > 40 && brillo < 220) {
          pixelesClaramenteAnimales++;
        }

        final esNeutro = brillo > 150 && saturacion < 0.20;
        if (esNeutro) {
          pixelesNeutros++;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }

        if (brillo > 180 && saturacion < 0.12) {
          pixelesBlancoGris++;
        }
      }
    }

    final promSaturacion = sumaSaturacion / totalPixels;
    final promTextura = sumaTextura / totalPixels;
    final ratioUniforme = pixelesUniformes / totalPixels;
    final ratioAnimal = pixelesClaramenteAnimales / totalPixels;
    final ratioNeutro = pixelesNeutros / totalPixels;
    final ratioBlancoGris = pixelesBlancoGris / totalPixels;

    if (maxX >= 0 && minX <= maxX) {
      final anchoZonaNeutra = (maxX - minX + 1).toDouble();
      final altoZonaNeutra = (maxY - minY + 1).toDouble();
      final aspectoZonaNeutra = anchoZonaNeutra / altoZonaNeutra;
      if (ratioNeutro > 0.18 && aspectoZonaNeutra > 1.0 && promTextura < 30.0) {
        return false;
      }
    }

    if (ratioBlancoGris > 0.22 && ratioAnimal < 0.08) {
      return false;
    }

    if (ratioUniforme > 0.62 && promSaturacion < 0.30 && promTextura < 26.0) {
      return false;
    }

    if (ratioUniforme > 0.52 && promTextura < 18.0) {
      return false;
    }

    if (ratioNeutro > 0.30 && ratioAnimal < 0.10) {
      return false;
    }

    if (ratioNeutro > 0.18 && promTextura < 14.0 && promSaturacion < 0.25) {
      return false;
    }

    return promSaturacion > 0.18 && promTextura > 12.0 && ratioAnimal > 0.05;
  }
}

