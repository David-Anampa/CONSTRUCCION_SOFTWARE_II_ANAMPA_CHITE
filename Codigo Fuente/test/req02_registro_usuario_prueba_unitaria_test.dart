// /**
//  * Archivo/Clase : req02_registro_usuario_prueba_unitaria_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Suite de pruebas unitarias (PU-01 a PU-05) para validar el flujo de
//  *                 registro de usuarios en RegistroVM, AuthServicio y FirestoreServicio.
//  * Se vincula con: - USA: RegistroVM (registro_vm.dart), AuthServicio (auth_servicio.dart),
//  *                   FirestoreServicio (firestore_servicio.dart) y firebase_fakes.dart.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Simula altas exitosas, rechazo por correo duplicado o clave débil,
//  *                 verificación de correo y actualización de estadoVerificado en Firestore.
//  * Requerimiento : REQ02 / RF-02 (Registro de usuario)
//  */

// REQ02 - Registro de usuario en la plataforma
// Tipo de prueba: UNITARIA (PU-01 a PU-05)
//
// Componentes: RegistroVM, AuthServicio, FirestoreServicio.
// Ejecutar: flutter test test/req02_registro_usuario_prueba_unitaria_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/servicios/auth_servicio.dart';
import 'package:sos_mascotas/servicios/firestore_servicio.dart';
import 'package:sos_mascotas/vistamodelo/auth/registro_vm.dart';

import 'helpers/firebase_fakes.dart';

/// Monta un widget [Form] mínimo asociado a `vm.formKey` para habilitar `validate()`.
Future<void> _montarForm(WidgetTester tester, RegistroVM vm) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Form(key: vm.formKey, child: const SizedBox()))),
  );
}

/// Rellena los controladores de [vm] con datos de prueba para [correo] y [clave].
void _llenar(RegistroVM vm, {required String correo, required String clave}) {
  vm.nombreCtrl.text = 'Persona Nueva';
  vm.correoCtrl.text = correo;
  vm.telefonoCtrl.text = '952123456';
  vm.claveCtrl.text = clave;
}

/// Punto de entrada de la suite de pruebas unitarias para REQ02.
void main() {
  final auth = FakeAuthPlatform.instancia;
  final db = FakeFirestorePlatform.instancia;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await iniciarFirebaseFake();
  });

  setUp(() {
    auth.reiniciar();
    db.reiniciar();
  });

  group('REQ02 - Registro de usuario | Prueba unitaria', () {
    testWidgets(
        'PU-01 Registro con datos válidos crea usuario en Auth y perfil en Firestore',
        (tester) async {
      final vm = RegistroVM();
      await _montarForm(tester, vm);
      _llenar(vm, correo: 'nuevo@sosmascotas.pe', clave: 'Clave123');

      final ok = await tester.runAsync(() => vm.registrarUsuario());

      expect(ok, isTrue);
      expect(vm.error, isNull);
      expect(auth.cuentas.containsKey('nuevo@sosmascotas.pe'), isTrue);
      expect(db.docs['usuarios/uid_1'], isNotNull);
      expect(auth.verificacionesEnviadas, contains('nuevo@sosmascotas.pe'));
    });

    testWidgets('PU-02 Correo ya registrado retorna false con error',
        (tester) async {
      auth.agregarCuenta('existente@sosmascotas.pe', 'Clave123', 'uid_x');
      final vm = RegistroVM();
      await _montarForm(tester, vm);
      _llenar(vm, correo: 'existente@sosmascotas.pe', clave: 'Clave123');

      final ok = await tester.runAsync(() => vm.registrarUsuario());

      expect(ok, isFalse);
      expect(vm.error, isNotNull);
      expect(vm.error, contains('already in use'));
      expect(vm.cargando, isFalse);
    });

    testWidgets('PU-03 Contraseña débil (<6) retorna false con mensaje',
        (tester) async {
      final vm = RegistroVM();
      await _montarForm(tester, vm);
      _llenar(vm, correo: 'debil@sosmascotas.pe', clave: '123');

      final ok = await tester.runAsync(() => vm.registrarUsuario());

      expect(ok, isFalse);
      expect(vm.error, contains('6 characters'));
      expect(auth.cuentas.containsKey('debil@sosmascotas.pe'), isFalse);
    });

    test('PU-04 AuthServicio.registrar genera credencial y retorna UID', () async {
      final uid = await AuthServicio().registrar('servicio@sosmascotas.pe', 'Clave123');

      expect(uid, isNotEmpty);
      expect(auth.cuentas.containsKey('servicio@sosmascotas.pe'), isTrue);
    });

    test('PU-05 FirestoreServicio.guardarUsuario persiste los campos esperados',
        () async {
      await FirestoreServicio().guardarUsuario('uid_perfil', {
        'nombre': 'Persona Nueva',
        'correo': 'perfil@sosmascotas.pe',
        'rol': 'usuario',
        'activo': true,
      });

      final doc = db.docs['usuarios/uid_perfil']!;
      expect(doc['nombre'], 'Persona Nueva');
      expect(doc['correo'], 'perfil@sosmascotas.pe');
      expect(doc['rol'], 'usuario');
      expect(doc['activo'], true);
    });
  });
}
