// /**
//  * Archivo/Clase : req03_recuperar_contrasena_prueba_unitaria_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Suite de pruebas unitarias (PU-01 a PU-04) para RecuperarVM usando
//  *                 dobles en memoria de FirebaseAuthPlatform.
//  * Se vincula con: - USA: RecuperarVM (recuperar_vm.dart), firebase_fakes.dart y flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Prueba el envío exitoso de restablecimiento, el manejo y traducción
//  *                 de errores de FirebaseAuthException y la función reiniciar().
//  * Requerimiento : REQ03 / RF-03 (Recuperar contraseña)
//  */

// REQ03 - Recuperación de contraseña por correo
// Tipo de prueba: UNITARIA (PU-01 a PU-04)
//
// Componente: RecuperarVM (enviarCorreo, reiniciar, traducción de errores).
// Ejecutar: flutter test test/req03_recuperar_contrasena_prueba_unitaria_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vistamodelo/auth/recuperar_vm.dart';

import 'helpers/firebase_fakes.dart';

/// enviarCorreo exige BuildContext y un Form con la llave del VM.
Future<BuildContext> _montar(WidgetTester tester, RecuperarVM vm) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(builder: (c) {
          ctx = c;
          return Form(key: vm.formKey, child: const SizedBox());
        }),
      ),
    ),
  );
  return ctx;
}

/// Punto de entrada de la suite de pruebas unitarias para REQ03.
void main() {
  final auth = FakeAuthPlatform.instancia;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await iniciarFirebaseFake();
  });

  setUp(() => auth.reiniciar());

  group('REQ03 - Recuperación de contraseña | Prueba unitaria', () {
    testWidgets('PU-01 Correo válido solicita el envío y marca éxito',
        (tester) async {
      final vm = RecuperarVM();
      final ctx = await _montar(tester, vm);
      vm.correoCtrl.text = 'usuario.prueba@sosmascotas.pe';

      await tester.runAsync(() => vm.enviarCorreo(ctx));

      expect(auth.correosRecuperacion, ['usuario.prueba@sosmascotas.pe']);
      expect(vm.enviado, isTrue);
      expect(vm.enviando, isFalse);
      expect(vm.error, isNull);
    });

    testWidgets('PU-02 Correo inexistente muestra el mensaje traducido',
        (tester) async {
      auth.errorRecuperacion = 'user-not-found';
      final vm = RecuperarVM();
      final ctx = await _montar(tester, vm);
      vm.correoCtrl.text = 'noexiste@sosmascotas.pe';

      await tester.runAsync(() => vm.enviarCorreo(ctx));

      expect(vm.enviado, isFalse);
      expect(vm.error, 'No existe una cuenta con ese correo electrónico.');
    });

    testWidgets('PU-03 Correo con formato inválido muestra mensaje traducido',
        (tester) async {
      auth.errorRecuperacion = 'invalid-email';
      final vm = RecuperarVM();
      final ctx = await _montar(tester, vm);
      vm.correoCtrl.text = 'correo-mal-formado';

      await tester.runAsync(() => vm.enviarCorreo(ctx));

      expect(vm.enviado, isFalse);
      expect(vm.error, 'El formato del correo es inválido.');
    });

    testWidgets('PU-04 reiniciar() restaura el estado inicial', (tester) async {
      final vm = RecuperarVM();
      final ctx = await _montar(tester, vm);
      vm.correoCtrl.text = 'usuario.prueba@sosmascotas.pe';
      await tester.runAsync(() => vm.enviarCorreo(ctx));
      expect(vm.enviado, isTrue);

      vm.reiniciar();

      expect(vm.correoCtrl.text, isEmpty);
      expect(vm.error, isNull);
      expect(vm.enviado, isFalse);
    });
  });
}
