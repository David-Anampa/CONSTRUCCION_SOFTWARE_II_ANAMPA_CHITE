// /**
//  * Archivo/Clase : avistamiento_vm_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pruebas unitarias originales de validación de campos obligatorios en
//  *                 AvistamientoVM (descripción, fotografía y coordenadas válidas).
//  * Se vincula con: - USA: AvistamientoVM (avistamiento_vm.dart), Avistamiento
//  *                   (avistamiento.dart) y flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Instancia AvistamientoVM antes de cada caso y comprueba los mensajes
//  *                 de error devueltos por validarCampos() ante entradas incompletas.
//  * Requerimiento : RF-05 (Registrar avistamiento de mascota)
//  */

import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vistamodelo/reportes/avistamiento_vm.dart';
import 'package:sos_mascotas/modelo/avistamiento.dart';

/// Punto de entrada de la suite original de validación de [AvistamientoVM].
void main() {
  group('Validación de avistamiento', () {
    late AvistamientoVM vm;

    setUp(() {
      vm = AvistamientoVM();
    });

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
