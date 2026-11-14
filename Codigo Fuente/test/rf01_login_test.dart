// /**
//  * Archivo/Clase : rf01_login_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pruebas unitarias puras para las reglas de validación de formulario y
//  *                 mapeo de excepciones de autenticación correspondientes a RF-01.
//  * Se vincula con: - USA: flutter_test y firebase_auth (FirebaseAuthException).
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Evalúa validadores de correo y contraseña junto con el mapeo de códigos
//  *                 de error de FirebaseAuth sin requerir red ni inicialización de Firebase.
//  * Requerimiento : RF-01 (Autenticar usuario)
//  */

// test/rf01_login_test.dart
//
// Pruebas Unitarias — RF-01: Autenticar Usuario
// SOSMascota v1.0 | Construcción de Software I | UPT
//
// Cubre: lógica de validación del LoginVM sin depender de Firebase real.
// Se prueba el método validarCampos() y la lógica de mapeo de errores
// de FirebaseAuthException, los cuales son puramente síncronos y
// no requieren inicializar Firebase.
//
// Ejecutar: flutter test test/rf01_login_test.dart -v

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Helpers de validación pura (extraídos de LoginVM) ────────────────────────

/// Valida el formato básico de un correo electrónico.
/// Replica la lógica del validator del formulario de login.
String? validarCorreo(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'El correo es obligatorio';
  }
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(valor.trim())) {
    return 'Formato de correo inválido';
  }
  return null;
}

/// Valida que la contraseña no esté vacía.
/// Replica la lógica del validator del formulario de login.
String? validarClave(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'La contraseña es obligatoria';
  }
  return null;
}

/// Mapea un código de FirebaseAuthException al mensaje de error que
/// muestra el LoginVM al usuario (lógica en loginYDeterminarRuta()).
String mapearErrorAuth(FirebaseAuthException e) {
  if (e.code == 'user-not-found') return 'Usuario no existe';
  if (e.code == 'wrong-password') return 'Contraseña incorrecta';
  if (e.code == 'invalid-email') return 'Correo inválido';
  if (e.code == 'user-disabled') return 'Tu cuenta ha sido desactivada. Contacta al administrador.';
  if (e.code == 'too-many-requests') return e.message ?? 'Demasiados intentos. Intenta más tarde.';
  return e.message ?? 'Error al iniciar sesión';
}

// ─── Suite de pruebas ─────────────────────────────────────────────────────────

void main() {
  group('RF-01 | Autenticar Usuario — Validación de formulario', () {
    // ── CASOS DE ÉXITO ───────────────────────────────────────────────────────

    test('✅ ÉXITO: correo y contraseña válidos no retornan error', () {
      final errorCorreo = validarCorreo('usuario@gmail.com');
      final errorClave = validarClave('miClave123');

      expect(errorCorreo, isNull,
          reason: 'Un correo válido no debe producir error');
      expect(errorClave, isNull,
          reason: 'Una contraseña no vacía no debe producir error');
    });

    test('✅ ÉXITO: correo con subdominio es válido', () {
      final error = validarCorreo('maria.garcia@uni.edu.pe');
      expect(error, isNull);
    });

    test('✅ ÉXITO: mapeo de error retorna mensaje legible para el usuario', () {
      final exc = FirebaseAuthException(code: 'user-not-found');
      final mensaje = mapearErrorAuth(exc);
      expect(mensaje, equals('Usuario no existe'));
    });

    // ── CASOS DE ERROR ───────────────────────────────────────────────────────

    test('❌ ERROR: correo vacío retorna mensaje de obligatorio', () {
      final error = validarCorreo('');
      expect(error, equals('El correo es obligatorio'));
    });

    test('❌ ERROR: correo null retorna mensaje de obligatorio', () {
      final error = validarCorreo(null);
      expect(error, equals('El correo es obligatorio'));
    });

    test('❌ ERROR: correo sin @ retorna formato inválido', () {
      final error = validarCorreo('usuariogmail.com');
      expect(error, equals('Formato de correo inválido'));
    });

    test('❌ ERROR: correo sin dominio retorna formato inválido', () {
      final error = validarCorreo('usuario@');
      expect(error, equals('Formato de correo inválido'));
    });

    test('❌ ERROR: contraseña vacía retorna mensaje de obligatorio', () {
      final error = validarClave('');
      expect(error, equals('La contraseña es obligatoria'));
    });

    test('❌ ERROR: contraseña null retorna mensaje de obligatorio', () {
      final error = validarClave(null);
      expect(error, equals('La contraseña es obligatoria'));
    });

    test('❌ ERROR: código wrong-password se mapea correctamente', () {
      final exc = FirebaseAuthException(code: 'wrong-password');
      expect(mapearErrorAuth(exc), equals('Contraseña incorrecta'));
    });

    test('❌ ERROR: código user-disabled se mapea con mensaje de cuenta desactivada', () {
      final exc = FirebaseAuthException(code: 'user-disabled');
      expect(
        mapearErrorAuth(exc),
        contains('desactivada'),
      );
    });

    test('❌ ERROR: código desconocido retorna el message del SDK', () {
      final exc = FirebaseAuthException(
        code: 'network-request-failed',
        message: 'Sin conexión a internet',
      );
      expect(mapearErrorAuth(exc), equals('Sin conexión a internet'));
    });
  });
}
