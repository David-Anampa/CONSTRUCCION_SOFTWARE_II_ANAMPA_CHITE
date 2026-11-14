// /**
//  * Archivo/Clase : rf02_registro_test.dart / main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pruebas unitarias para validadores de registro y serialización del
//  *                 modelo Usuario correspondientes al requerimiento RF-02.
//  * Se vincula con: - USA: Usuario (usuario.dart), firebase_auth y flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Verifica restricciones de nombre, correo, contraseña y teléfono, además
//  *                 de los valores por defecto al construir y serializar Usuario.
//  * Requerimiento : RF-02 (Registrar usuario)
//  */

// test/rf02_registro_test.dart
//
// Pruebas Unitarias — RF-02: Registrar Usuario
// SOSMascota v1.0 | Construcción de Software I | UPT
//
// Cubre: lógica de validación del formulario de registro y
// la estructura del modelo Usuario que se persiste en Firestore.
// No requiere conexión a Firebase.
//
// Ejecutar: flutter test test/rf02_registro_test.dart -v

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sos_mascotas/modelo/usuario.dart';

// ─── Helpers de validación pura (extraídos de PantallaRegistro validators) ───

/// Valida el nombre del usuario.
String? validarNombre(String? valor) {
  if (valor == null || valor.trim().isEmpty) {
    return 'El nombre es obligatorio';
  }
  if (valor.trim().length < 3) {
    return 'El nombre debe tener al menos 3 caracteres';
  }
  return null;
}

/// Valida el formato del correo electrónico.
String? validarCorreoRegistro(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'El correo es obligatorio';
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(valor.trim())) return 'Formato de correo inválido';
  return null;
}

/// Valida la contraseña según las reglas de Firebase Auth.
String? validarContrasena(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'La contraseña es obligatoria';
  if (valor.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
  return null;
}

/// Valida el número de teléfono.
String? validarTelefono(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'El teléfono es obligatorio';
  final digitosOnly = valor.replaceAll(RegExp(r'\D'), '');
  if (digitosOnly.length < 9) return 'Ingresa un número de teléfono válido';
  return null;
}

/// Mapea errores de FirebaseAuthException del registro al mensaje visible.
String mapearErrorRegistro(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este correo ya está registrado';
    case 'weak-password':
      return 'La contraseña es muy débil';
    case 'invalid-email':
      return 'El formato del correo no es válido';
    default:
      return e.message ?? 'Error al registrar usuario';
  }
}

// ─── Suite de pruebas ─────────────────────────────────────────────────────────

void main() {
  group('RF-02 | Registrar Usuario — Validación de campos', () {
    // ── CASOS DE ÉXITO ───────────────────────────────────────────────────────

    test('✅ ÉXITO: todos los campos válidos no producen errores', () {
      expect(validarNombre('Carlos Mamani'), isNull);
      expect(validarCorreoRegistro('carlos@gmail.com'), isNull);
      expect(validarContrasena('Segura123'), isNull);
      expect(validarTelefono('952147896'), isNull);
    });

    test('✅ ÉXITO: nombre con acento es válido', () {
      expect(validarNombre('María García'), isNull);
    });

    test('✅ ÉXITO: contraseña exactamente de 6 caracteres es válida', () {
      expect(validarContrasena('abc123'), isNull);
    });

    test('✅ ÉXITO: teléfono de 9 dígitos es válido', () {
      expect(validarTelefono('952147896'), isNull);
    });
  });

  group('RF-02 | Registrar Usuario — Errores de validación de campos', () {
    // ── ERRORES DE NOMBRE ────────────────────────────────────────────────────

    test('❌ ERROR: nombre vacío retorna mensaje obligatorio', () {
      expect(validarNombre(''), equals('El nombre es obligatorio'));
    });

    test('❌ ERROR: nombre con menos de 3 caracteres es inválido', () {
      expect(validarNombre('AB'), equals('El nombre debe tener al menos 3 caracteres'));
    });

    test('❌ ERROR: nombre null retorna mensaje obligatorio', () {
      expect(validarNombre(null), equals('El nombre es obligatorio'));
    });

    // ── ERRORES DE CORREO ────────────────────────────────────────────────────

    test('❌ ERROR: correo vacío retorna mensaje obligatorio', () {
      expect(validarCorreoRegistro(''), equals('El correo es obligatorio'));
    });

    test('❌ ERROR: correo sin @ retorna formato inválido', () {
      expect(validarCorreoRegistro('carlosgmail.com'), equals('Formato de correo inválido'));
    });

    // ── ERRORES DE CONTRASEÑA ────────────────────────────────────────────────

    test('❌ ERROR: contraseña vacía retorna mensaje obligatorio', () {
      expect(validarContrasena(''), equals('La contraseña es obligatoria'));
    });

    test('❌ ERROR: contraseña de 5 caracteres es débil', () {
      expect(validarContrasena('abc12'), equals('La contraseña debe tener al menos 6 caracteres'));
    });

    // ── ERRORES DE TELÉFONO ──────────────────────────────────────────────────

    test('❌ ERROR: teléfono vacío retorna mensaje obligatorio', () {
      expect(validarTelefono(''), equals('El teléfono es obligatorio'));
    });

    test('❌ ERROR: teléfono con menos de 9 dígitos es inválido', () {
      expect(validarTelefono('9521478'), equals('Ingresa un número de teléfono válido'));
    });
  });

  group('RF-02 | Registrar Usuario — Mapeo de errores Firebase Auth', () {
    test('❌ ERROR: email-already-in-use → mensaje específico de duplicado', () {
      final exc = FirebaseAuthException(code: 'email-already-in-use');
      expect(mapearErrorRegistro(exc), equals('Este correo ya está registrado'));
    });

    test('❌ ERROR: weak-password → mensaje específico de contraseña débil', () {
      final exc = FirebaseAuthException(code: 'weak-password');
      expect(mapearErrorRegistro(exc), equals('La contraseña es muy débil'));
    });

    test('❌ ERROR: invalid-email → mensaje de formato inválido', () {
      final exc = FirebaseAuthException(code: 'invalid-email');
      expect(mapearErrorRegistro(exc), equals('El formato del correo no es válido'));
    });

    test('❌ ERROR: código desconocido usa el message del SDK', () {
      final exc = FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Operación no permitida',
      );
      expect(mapearErrorRegistro(exc), equals('Operación no permitida'));
    });
  });

  group('RF-02 | Registrar Usuario — Modelo Usuario serialización', () {
    test('✅ ÉXITO: toMap() contiene todos los campos requeridos', () {
      final usuario = Usuario(
        id: 'uid-test-001',
        nombre: 'Juan Pérez',
        correo: 'juan@gmail.com',
        telefono: '952147896',
        rol: 'usuario',
        estadoVerificado: false,
        estadoRol: 'activo',
        fotoPerfil: null,
        activo: true,
      );

      final map = usuario.toMap();

      expect(map['nombre'], equals('Juan Pérez'));
      expect(map['correo'], equals('juan@gmail.com'));
      expect(map['telefono'], equals('952147896'));
      expect(map['rol'], equals('usuario'));
      expect(map['estadoVerificado'], isFalse);
      expect(map['activo'], isTrue);
    });

    test('✅ ÉXITO: fromMap() reconstruye el usuario correctamente', () {
      final map = {
        'nombre': 'Ana Torres',
        'correo': 'ana@gmail.com',
        'telefono': '987654321',
        'dni': '',
        'rol': 'usuario',
        'estadoVerificado': false,
        'estadoRol': 'activo',
        'fotoPerfil': null,
        'activo': true,
        'fechaRegistro': null,
        'fcmToken': null,
        'idColaborador': null,
      };

      final usuario = Usuario.fromMap(map, 'uid-test-002');

      expect(usuario.id, equals('uid-test-002'));
      expect(usuario.nombre, equals('Ana Torres'));
      expect(usuario.correo, equals('ana@gmail.com'));
      expect(usuario.rol, equals('usuario'));
      expect(usuario.activo, isTrue);
    });

    test('✅ ÉXITO: fromMap() usa valores por defecto si faltan campos', () {
      // Simula un documento de Firestore incompleto
      final usuarioConDefaults = Usuario.fromMap({}, 'uid-default');

      expect(usuarioConDefaults.nombre, equals(''));
      expect(usuarioConDefaults.rol, equals('usuario'));
      expect(usuarioConDefaults.activo, isTrue);
      expect(usuarioConDefaults.estadoRol, equals('activo'));
    });
  });
}
