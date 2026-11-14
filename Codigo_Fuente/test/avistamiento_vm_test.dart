// test/avistamiento_vm_test.dart
//
// Test original de validación de avistamiento (mantenido por compatibilidad).
// La suite completa está en rf05_avistamiento_test.dart
//
// Ejecutar: flutter test test/avistamiento_vm_test.dart -v

import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vistamodelo/reportes/avistamiento_vm.dart';
import 'package:sos_mascotas/modelo/avistamiento.dart';

void main() {
  group('Validación de avistamiento', () {
    late AvistamientoVM vm;

    setUp(() {
      vm = AvistamientoVM();
    });

    // ── CASO DE ÉXITO ──────────────────────────────────────────────────────

    test('✅ Éxito: datos completos retornan null (sin error)', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Se vio un perro labrador cerca del mercado',
        latitud: -18.0120,
        longitud: -70.2534,
      );

      final resultado = vm.validarCampos();
      expect(resultado, isNull,
          reason: 'Todos los campos válidos no deben producir error');
    });

    // ── CASOS DE ERROR ─────────────────────────────────────────────────────

    test('❌ Falla si la descripción está vacía', () async {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: '',
        latitud: -18.0,
        longitud: -70.0,
      );

      final valido = vm.validarCampos();
      expect(valido, equals('La descripción no puede estar vacía'));
    });

    test('❌ Falla si no hay foto', () async {
      vm.avistamiento = Avistamiento(
        foto: '',
        descripcion: 'Se vio un perro cerca del mercado',
        latitud: -18.0,
        longitud: -70.0,
      );

      final valido = vm.validarCampos();
      expect(valido, equals('Debe adjuntar una foto del avistamiento'));
    });

    test('❌ Falla si no tiene ubicación válida', () async {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Gato blanco',
        latitud: 0.0,
        longitud: 0.0,
      );

      final valido = vm.validarCampos();
      expect(valido, equals('Debe seleccionar una ubicación válida'));
    });
  });
}
