import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Servicio para consultar la identidad de un ciudadano mediante su DNI.
class ApiDniServicio {
  final String baseUrl = "https://miapi.cloud/v1/dni";
  final String bearerToken;

  ApiDniServicio({required this.bearerToken});

  /// Consulta la información asociada a un [dni] de 8 dígitos numéricos.
  ///
  /// Lanza [ArgumentError] si el DNI no cumple con el formato requerido.
  /// Lanza [StateError] si el token de autorización no ha sido provisto.
  Future<Map<String, dynamic>?> consultarDni(String dni) async {
    final dniLimpio = dni.trim();
    if (dniLimpio.length != 8 || !RegExp(r'^\d{8}$').hasMatch(dniLimpio)) {
      throw ArgumentError.value(
        dni,
        'dni',
        'El DNI debe contener exactamente 8 dígitos numéricos.',
      );
    }

    if (bearerToken.trim().isEmpty) {
      throw StateError('El token de autenticación para el servicio DNI no está configurado.');
    }

    final uri = Uri.parse("$baseUrl/$dniLimpio");
    try {
      final resp = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $bearerToken",
          "Content-Type": "application/json",
        },
      );
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        if (body["success"] == true && body["datos"] != null) {
          return Map<String, dynamic>.from(body["datos"]);
        }
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error en ApiDniServicio.consultarDni: $e');
      rethrow;
    }
  }
}
