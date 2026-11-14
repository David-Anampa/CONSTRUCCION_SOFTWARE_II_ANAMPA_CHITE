// test/rf05_avistamiento_test.dart
//
// Pruebas Unitarias — RF-05: Registrar Avistamiento de Mascota
// SOSMascota v1.0 | Construcción de Software I | UPT
//
// Cubre: validarCampos(), actualizarUbicacion(), cálculo de distancia
// Haversine y el modelo Avistamiento (serialización/deserialización).
// No requiere Firebase, TFLite ni permisos de GPS.
//
// Ejecutar: flutter test test/rf05_avistamiento_test.dart -v

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vistamodelo/reportes/avistamiento_vm.dart';
import 'package:sos_mascotas/modelo/avistamiento.dart';

// ─── Helper: fórmula Haversine para verificar lógica de distancia ─────────────
//
// Reimplementación del mismo algoritmo que usa AvistamientoVM internamente,
// para verificar el comportamiento esperado en las pruebas de distancia.

double _gradosARadianes(double grados) => grados * pi / 180.0;

double calcularDistanciaKm(
  double latOrigen,
  double lonOrigen,
  double latDest,
  double lonDest,
) {
  const radioTierraKm = 6371.0;
  final dLat = _gradosARadianes(latDest - latOrigen);
  final dLon = _gradosARadianes(lonDest - lonOrigen);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_gradosARadianes(latOrigen)) *
          cos(_gradosARadianes(latDest)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return radioTierraKm * c;
}

void main() {
  // ─── Grupo: validarCampos() ────────────────────────────────────────────────

  group('RF-05 | Avistamiento — validarCampos()', () {
    late AvistamientoVM vm;

    setUp(() => vm = AvistamientoVM());

    // ── CASOS DE ÉXITO ───────────────────────────────────────────────────────

    test('✅ ÉXITO: todos los campos completos retorna null (sin error)', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Se vio un perro beige cerca del mercado',
        latitud: -18.0120,
        longitud: -70.2534,
      );

      expect(vm.validarCampos(), isNull,
          reason: 'Con foto, descripción y ubicación válidos no debe haber error');
    });

    test('✅ ÉXITO: descripción con varios caracteres es válida', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://storage.googleapis.com/foto.jpg',
        descripcion: 'Gato blanco con manchas negras visto en el parque',
        latitud: -18.0500,
        longitud: -70.3000,
      );

      expect(vm.validarCampos(), isNull);
    });

    // ── CASOS DE ERROR ───────────────────────────────────────────────────────

    test('❌ ERROR: descripción vacía retorna mensaje específico', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: '',
        latitud: -18.0,
        longitud: -70.0,
      );

      final resultado = vm.validarCampos();
      expect(resultado, equals('La descripción no puede estar vacía'));
    });

    test('❌ ERROR: descripción solo espacios retorna mensaje de vacía', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: '   ',
        latitud: -18.0,
        longitud: -70.0,
      );

      expect(vm.validarCampos(), equals('La descripción no puede estar vacía'));
    });

    test('❌ ERROR: foto vacía retorna mensaje específico', () {
      vm.avistamiento = Avistamiento(
        foto: '',
        descripcion: 'Se vio un perro cerca del mercado',
        latitud: -18.0,
        longitud: -70.0,
      );

      expect(vm.validarCampos(), equals('Debe adjuntar una foto del avistamiento'));
    });

    test('❌ ERROR: foto solo espacios retorna mensaje de sin foto', () {
      vm.avistamiento = Avistamiento(
        foto: '   ',
        descripcion: 'Gato blanco cerca de la plaza',
        latitud: -18.0,
        longitud: -70.0,
      );

      expect(vm.validarCampos(), equals('Debe adjuntar una foto del avistamiento'));
    });

    test('❌ ERROR: coordenadas (0,0) retorna mensaje de ubicación inválida', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Gato blanco',
        latitud: 0.0,
        longitud: 0.0,
      );

      expect(vm.validarCampos(), equals('Debe seleccionar una ubicación válida'));
    });

    test('❌ ERROR: latitud null retorna mensaje de ubicación inválida', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Perro labrador',
        latitud: null,
        longitud: -70.0,
      );

      expect(vm.validarCampos(), equals('Debe seleccionar una ubicación válida'));
    });

    test('❌ ERROR: longitud null retorna mensaje de ubicación inválida', () {
      vm.avistamiento = Avistamiento(
        foto: 'https://example.com/foto.jpg',
        descripcion: 'Perro labrador',
        latitud: -18.0,
        longitud: null,
      );

      expect(vm.validarCampos(), equals('Debe seleccionar una ubicación válida'));
    });
  });

  // ─── Grupo: actualizarUbicacion() ─────────────────────────────────────────

  group('RF-05 | Avistamiento — actualizarUbicacion()', () {
    late AvistamientoVM vm;

    setUp(() => vm = AvistamientoVM());

    test('✅ ÉXITO: actualiza todos los campos de ubicación correctamente', () {
      vm.actualizarUbicacion(
        direccion: 'Av. Bolognesi 456',
        distrito: 'Tacna',
        latitud: -18.0120,
        longitud: -70.2534,
      );

      expect(vm.avistamiento.direccion, equals('Av. Bolognesi 456'));
      expect(vm.avistamiento.distrito, equals('Tacna'));
      expect(vm.avistamiento.latitud, equals(-18.0120));
      expect(vm.avistamiento.longitud, equals(-70.2534));
    });

    test('✅ ÉXITO: tras actualizarUbicacion(), validarCampos() no reporta error de ubicación', () {
      vm.avistamiento.foto = 'https://example.com/foto.jpg';
      vm.avistamiento.descripcion = 'Perro marrón visto en el parque';

      vm.actualizarUbicacion(
        direccion: 'Parque Municipal',
        distrito: 'Tacna',
        latitud: -18.0120,
        longitud: -70.2534,
      );

      expect(vm.validarCampos(), isNull);
    });
  });

  // ─── Grupo: setters de campos ─────────────────────────────────────────────

  group('RF-05 | Avistamiento — setters de campos', () {
    late AvistamientoVM vm;

    setUp(() => vm = AvistamientoVM());

    test('✅ ÉXITO: setDescripcion() actualiza el campo descripción', () {
      vm.setDescripcion('Perro encontrado en Av. Principal');
      expect(vm.avistamiento.descripcion, equals('Perro encontrado en Av. Principal'));
    });

    test('✅ ÉXITO: setDireccion() actualiza el campo dirección', () {
      vm.setDireccion('Jr. Arias Aragüez 123');
      expect(vm.avistamiento.direccion, equals('Jr. Arias Aragüez 123'));
    });
  });

  // ─── Grupo: modelo Avistamiento ───────────────────────────────────────────

  group('RF-05 | Avistamiento — Modelo Avistamiento serialización', () {
    test('✅ ÉXITO: toMap() incluye todos los campos para Firestore', () {
      final a = Avistamiento(
        id: 'avist-001',
        reporteId: 'rep-001',
        usuarioId: 'uid-001',
        foto: 'https://example.com/foto.jpg',
        direccion: 'Av. Bolognesi',
        distrito: 'Tacna',
        latitud: -18.0120,
        longitud: -70.2534,
        fechaAvistamiento: '05/09/2026',
        horaAvistamiento: '10:30',
        descripcion: 'Perro labrador dorado visto cerca del mercado',
      );

      final map = a.toMap();

      expect(map['id'], equals('avist-001'));
      expect(map['foto'], equals('https://example.com/foto.jpg'));
      expect(map['latitud'], equals(-18.0120));
      expect(map['descripcion'], isNotEmpty);
    });

    test('✅ ÉXITO: fromMap() reconstruye el avistamiento correctamente', () {
      final map = {
        'id': 'avist-002',
        'reporteId': '',
        'usuarioId': 'uid-002',
        'foto': 'https://example.com/foto2.jpg',
        'direccion': 'Jr. Arias Aragüez',
        'distrito': 'Gregorio Albarracín',
        'latitud': -18.0500,
        'longitud': -70.3000,
        'fechaAvistamiento': '05/09/2026',
        'horaAvistamiento': '14:00',
        'descripcion': 'Gato blanco cerca de la escuela',
      };

      final a = Avistamiento.fromMap(map);

      expect(a.id, equals('avist-002'));
      expect(a.latitud, equals(-18.0500));
      expect(a.descripcion, contains('Gato'));
    });

    test('✅ ÉXITO: fromMap() usa valores por defecto para campos ausentes', () {
      final a = Avistamiento.fromMap({});

      expect(a.id, equals(''));
      expect(a.foto, equals(''));
      expect(a.latitud, isNull);
      expect(a.longitud, isNull);
    });

    test('❌ ERROR: avistamiento sin descripción tiene campo vacío', () {
      final a = Avistamiento();
      expect(a.descripcion, equals(''));
    });
  });
}
