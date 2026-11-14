// /**
//  * Archivo/Clase : validaciones_test.dart / esEmailValido, esContrasenaValida, main
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pruebas unitarias básicas para funciones auxiliares de validación de
//  *                 formato de correo electrónico y longitud mínima de contraseña.
//  * Se vincula con: - USA: flutter_test.
//  *                 - ES USADO POR: Ejecutor `flutter test` y test/ejecutar_pruebas.ps1.
//  * Funcionamiento: Define predicados booleanos puros y verifica casos positivos y negativos.
//  * Requerimiento : RF-01 / RF-02 (Validación de credenciales de usuario)
//  */

import 'package:flutter_test/flutter_test.dart';

/// Verifica de forma básica que [email] contenga al menos `@` y `.`.
///
/// - Parámetros: [email] cadena de correo electrónico a validar.
/// - Valor de retorno: `true` si cumple la condición mínima; `false` en caso contrario.
bool esEmailValido(String email) {
  return email.contains('@') && email.contains('.');
}

/// Verifica que la contraseña [pass] tenga una longitud mínima de 8 caracteres.
///
/// - Parámetros: [pass] contraseña en texto plano.
/// - Valor de retorno: `true` si `pass.length >= 8`; `false` en caso contrario.
bool esContrasenaValida(String pass) {
  return pass.length >= 8;
}

/// Punto de entrada de las pruebas básicas de validación de email y contraseña.
void main() {
  test('Email válido debe contener arroba y punto', () {
    expect(esEmailValido('usuario@gmail.com'), true);
  });

  test('Email inválido sin arroba debe fallar', () {
    expect(esEmailValido('usuariogmail.com'), false);
  });

  test('Contraseña válida debe tener minimo 8 caracteres', () {
    expect(esContrasenaValida('12345678'), true);
  });

  test('Contraseña corta debe fallar', () {
    expect(esContrasenaValida('123'), false);
  });
}