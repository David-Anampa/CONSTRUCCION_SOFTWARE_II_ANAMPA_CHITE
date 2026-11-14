import 'package:flutter_test/flutter_test.dart';

bool esEmailValido(String email) {
  return email.contains('@') && email.contains('.');
}

bool esContrasenaValida(String pass) {
  return pass.length >= 8;
}

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