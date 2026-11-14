import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sos_mascotas/servicios/servicio_tflite.dart';

void main() {
  group('ServicioTFLite.detectarAnimal', () {
    test('rechaza una imagen tipo coche blanco sobre fondo verde', () async {
      final image = img.Image(width: 224, height: 224);

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final green = img.ColorRgba8(40, 120, 50, 255);
          image.setPixel(x, y, green);
        }
      }

      for (int y = 40; y < 180; y++) {
        for (int x = 25; x < 210; x++) {
          if (y > 72 && y < 150 && x > 65 && x < 190) {
            image.setPixel(x, y, img.ColorRgba8(245, 245, 245, 255));
          } else if (y > 60 && y < 120 && x > 80 && x < 170) {
            image.setPixel(x, y, img.ColorRgba8(180, 185, 190, 255));
          }
        }
      }

      for (int y = 65; y < 110; y++) {
        for (int x = 85; x < 145; x++) {
          image.setPixel(x, y, img.ColorRgba8(20, 20, 20, 255));
        }
      }

      final bytes = Uint8List.fromList(img.encodeJpg(image));
      final resultado = await ServicioTFLite.detectarAnimal(bytes);

      expect(resultado['etiqueta'], isNot(equals('perro')));
      expect(resultado['etiqueta'], isNot(equals('gato')));
    });

    test('rechaza un coche blanco grande sobre fondo verde con árboles', () async {
      final image = img.Image(width: 224, height: 224);

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final blue = ((x * 3 + y * 2) % 40) + 40;
          final green = 90 + ((x + y) % 60);
          image.setPixel(x, y, img.ColorRgba8(20, green, blue, 255));
        }
      }

      for (int y = 30; y < 200; y++) {
        for (int x = 15; x < 210; x++) {
          final isTrunk = x > 35 && x < 50 && y > 40 && y < 200;
          final isLeaves = (x - 120).abs() < 70 && (y - 80).abs() < 70;
          if (isTrunk) {
            image.setPixel(x, y, img.ColorRgba8(90, 60, 35, 255));
          } else if (isLeaves) {
            image.setPixel(x, y, img.ColorRgba8(30, 120, 45, 255));
          }
        }
      }

      for (int y = 70; y < 200; y++) {
        for (int x = 30; x < 190; x++) {
          if (x > 45 && x < 177 && y > 88 && y < 182) {
            image.setPixel(x, y, img.ColorRgba8(245, 245, 245, 255));
          }
        }
      }

      for (int y = 96; y < 150; y++) {
        for (int x = 88; x < 150; x++) {
          image.setPixel(x, y, img.ColorRgba8(20, 20, 20, 255));
        }
      }

      final bytes = Uint8List.fromList(img.encodeJpg(image));
      final resultado = await ServicioTFLite.detectarAnimal(bytes);

      expect(resultado['etiqueta'], isNot(anyOf(['perro', 'gato'])));
    });

    test('acepta una imagen con textura y color de mascota', () async {
      final image = img.Image(width: 224, height: 224);
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final noise = ((x * 13 + y * 17) % 23) - 11;
          final r = (140 + noise).clamp(0, 255).toInt();
          final g = (80 + noise * 2).clamp(0, 255).toInt();
          final b = (40 + noise).clamp(0, 255).toInt();
          image.setPixel(x, y, img.ColorRgba8(r, g, b, 255));
        }
      }

      final bytes = Uint8List.fromList(img.encodeJpg(image));
      final resultado = await ServicioTFLite.detectarAnimal(bytes);

      expect(resultado['confianza'], greaterThanOrEqualTo(0.9));
      expect(resultado['etiqueta'], anyOf(['perro', 'gato']));
    });
  });
}
