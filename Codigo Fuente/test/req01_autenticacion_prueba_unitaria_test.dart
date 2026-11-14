// /**
//  * Archivo/Clase : req01_autenticacion_prueba_unitaria_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Suite de pruebas unitarias (PU-01 a PU-05) para validar LoginVM y
//  *                 AuthWrapper usando los dobles de plataforma en memoria de Firebase.
//  * Se vincula con: - USA: LoginVM (login_vm.dart), AuthWrapper (auth_wrapper.dart),
//  *                   firebase_fakes.dart y flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Verifica el enrutamiento por rol (usuario, admin), bloqueo por correo no
//  *                 verificado o credenciales erróneas y expulsión en tiempo real de cuentas
//  *                 desactivadas.
//  * Requerimiento : REQ01 / RF-01 (Autenticación de usuario), RF-13 (Cierre de sesión)
//  */

// REQ01 - Autenticación de usuario con verificación de rol
// Tipo de prueba: UNITARIA (PU-01 a PU-05)
//
// Componentes: LoginVM (loginYDeterminarRuta) y AuthWrapper.
// Ejecutar: flutter test test/req01_autenticacion_prueba_unitaria_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/utils/auth_wrapper.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';

import 'helpers/firebase_fakes.dart';

const _correoUsuario = 'usuario.prueba@sosmascotas.pe';
const _correoAdmin = 'admin.prueba@sosmascotas.pe';
const _correoBloqueado = 'bloqueado.prueba@sosmascotas.pe';
const _clave = 'Clave123';

/// Monta un Form con la llave del VM, requerida por validate().
Future<void> _montarForm(WidgetTester tester, LoginVM vm) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Form(key: vm.formKey, child: const SizedBox()))),
  );
}

/// Punto de entrada de la suite de pruebas unitarias para REQ01.
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
    auth.agregarCuenta(_correoUsuario, _clave, 'uid_usuario');
    auth.agregarCuenta(_correoAdmin, _clave, 'uid_admin');
    auth.agregarCuenta(_correoBloqueado, _clave, 'uid_bloqueado');
    db.sembrar('usuarios/uid_usuario', {
      'nombre': 'Usuario Prueba',
      'correo': _correoUsuario,
      'rol': 'usuario50',
      'activo': true,
      'fotoPerfil': 'https://example.com/foto.jpg',
    });
    db.sembrar('usuarios/uid_admin', {
      'nombre': 'Admin Prueba',
      'correo': _correoAdmin,
      'rol': 'admin',
      'activo': true,
    });
    db.sembrar('usuarios/uid_bloqueado', {
      'nombre': 'Bloqueado Prueba',
      'correo': _correoBloqueado,
      'rol': 'usuario',
      'activo': false,
      'fotoPerfil': 'https://example.com/foto.jpg',
    });
  });

  group('REQ01 - Autenticación | Prueba unitaria', () {
    testWidgets('PU-01 Login de usuario común retorna la ruta /inicio',
        (tester) async {
      final vm = LoginVM();
      await _montarForm(tester, vm);
      vm.correoCtrl.text = _correoUsuario;
      vm.claveCtrl.text = _clave;

      final ruta = await tester.runAsync(() => vm.loginYDeterminarRuta());

      expect(ruta, '/inicio');
      expect(vm.error, isNull);
      expect(vm.cargando, isFalse);
    });

    testWidgets('PU-02 Login de administrador retorna la ruta /inicioAdmin',
        (tester) async {
      final vm = LoginVM();
      await _montarForm(tester, vm);
      vm.correoCtrl.text = _correoAdmin;
      vm.claveCtrl.text = _clave;

      final ruta = await tester.runAsync(() => vm.loginYDeterminarRuta());

      expect(ruta, '/inicioAdmin');
      expect(vm.error, isNull);
    });

    testWidgets('PU-03 Credenciales inválidas retornan null y guardan error',
        (tester) async {
      final vm = LoginVM();
      await _montarForm(tester, vm);
      vm.correoCtrl.text = _correoUsuario;
      vm.claveCtrl.text = 'incorrecta';

      final ruta = await tester.runAsync(() => vm.loginYDeterminarRuta());

      expect(ruta, isNull);
      expect(vm.error, 'Contraseña incorrecta');
      expect(vm.cargando, isFalse);
    });

    testWidgets(
        'PU-04 Cuenta desactivada: AuthWrapper cierra sesión y muestra el login',
        (tester) async {
      await auth.signInWithEmailAndPassword(_correoBloqueado, _clave);

      await tester.pumpWidget(MaterialApp(
        home: AuthWrapper(
          loginScreen: const Scaffold(body: Text('PANTALLA_LOGIN')),
          homeScreenBuilder: (uid, data) =>
              const Scaffold(body: Text('PANTALLA_HOME')),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(auth.cierresDeSesion, 1, reason: 'Debe ejecutar signOut()');
      expect(auth.currentUser, isNull);
      expect(find.text('PANTALLA_LOGIN'), findsOneWidget);
      expect(find.text('PANTALLA_HOME'), findsNothing);
      expect(find.text('Cuenta Desactivada'), findsOneWidget);
    });

    testWidgets(
        'PU-05 Perfil inexistente: AuthWrapper ejecuta signOut() y muestra el login',
        (tester) async {
      // Usuario autenticado en Auth pero SIN documento en "usuarios".
      auth.agregarCuenta('sinperfil@sosmascotas.pe', _clave, 'uid_sin_perfil');
      await auth.signInWithEmailAndPassword('sinperfil@sosmascotas.pe', _clave);

      await tester.pumpWidget(MaterialApp(
        home: AuthWrapper(
          loginScreen: const Scaffold(body: Text('PANTALLA_LOGIN')),
          homeScreenBuilder: (uid, data) =>
              const Scaffold(body: Text('PANTALLA_HOME')),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(auth.cierresDeSesion, 1, reason: 'Debe ejecutar signOut()');
      expect(find.text('PANTALLA_LOGIN'), findsOneWidget);
      expect(find.text('PANTALLA_HOME'), findsNothing);
    });
  });
}
