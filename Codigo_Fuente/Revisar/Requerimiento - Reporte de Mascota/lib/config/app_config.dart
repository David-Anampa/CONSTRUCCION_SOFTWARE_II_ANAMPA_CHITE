/// Configuración global de la app
///
/// Centraliza valores que antes estaban repetidos como "números mágicos"
/// (colores, duraciones, tamaños de SnackBar, etc.) para que un cambio
/// de diseño no obligue a tocar varios archivos. `auth_wrapper.dart`
/// importa esta clase desde aquí (import circular permitido en Dart).
import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();// Evita instanciar esta clase; solo se usa de forma estática.

  static const String appTitle = 'SOS Mascota';

  static const String bearerToken = String.fromEnvironment(
    'BEARER_TOKEN',
    defaultValue: '',
  );

  // Colores base del tema
  static const Color primaryColor = Color(0xFF4D9EF6);
  static const Color scaffoldBackground = Color(0xFFF5F6FA);
  // Duraciones de SnackBar
  static const Duration snackDurationDefault = Duration(seconds: 4);
  static const Duration snackDurationLong = Duration(seconds: 6);
// Tamaños y espaciados usados en los avisos (SnackBars) de AuthWrapper
  static const double snackIconSize = 28;
  static const double snackSpacing = 12;
  static const double snackTextSpacing = 4;
  static const double snackBorderRadiusDefault = 10;
  static const double snackBorderRadiusLarge = 12;
  static const double snackMargin = 16;
  // Modo local de desarrollo: cuando es true la app evita usar Firebase
  // y activa comportamientos de depuración (autologin). Úsalo solo para pruebas.
  static const bool forceLocalMode = true;
}
