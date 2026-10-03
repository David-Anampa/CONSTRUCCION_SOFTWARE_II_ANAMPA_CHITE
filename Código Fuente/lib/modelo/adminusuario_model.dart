import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminUsuarioModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String telefono;
  final DateTime fechaRegistro;
  final bool activo;

  AdminUsuarioModel({
    required this.uid,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.telefono = '',
    required this.fechaRegistro,
    this.activo = true,
  });

  /// Desglosa una cadena de nombre completo en nombre y apellido de forma pura (9.1).
  static (String, String) _desglosarNombreYApellido(String nombreCompleto) {
    final partes = nombreCompleto
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return ('', '');
    if (partes.length == 1) return (partes[0], '');
    if (partes.length == 2) return (partes[0], partes[1]);
    if (partes.length == 3) return ('${partes[0]} ${partes[1]}', partes[2]);
    return ('${partes[0]} ${partes[1]}', partes.sublist(2).join(' '));
  }

  // ✅ Crear desde Map (para compatibilidad con fromMap)
  factory AdminUsuarioModel.fromMap(Map<String, dynamic> data, String uid) {
    return AdminUsuarioModel.fromFirestore(data, uid);
  }

  // Crear desde Firestore con manejo robusto de datos
  factory AdminUsuarioModel.fromFirestore(
    Map<String, dynamic> data,
    String uid,
  ) {
    DateTime fechaRegistro = DateTime.now();

    if (data['fechaRegistro'] != null) {
      try {
        final fechaData = data['fechaRegistro'];
        if (fechaData is Timestamp) {
          fechaRegistro = fechaData.toDate();
        } else if (fechaData is String) {
          fechaRegistro = DateTime.parse(fechaData);
        }
      } catch (e) {
        debugPrint('Error al parsear fecha: $e');
        fechaRegistro = DateTime.now();
      }
    }

    // Mapeo puro de campos directos
    final String rawApellido =
        (data['apellido'] ??
                data['apellidos'] ??
                data['lastName'] ??
                data['apellidoPaterno'] ??
                '')
            .toString();

    final String rawNombre =
        (data['nombre'] ?? data['nombres'] ?? data['name'] ?? '').toString();

    // Resolucion inmutable de nombre y apellido sin reasignaciones
    final (String nombre, String apellido) = () {
      if (rawApellido.isEmpty &&
          rawNombre.isNotEmpty &&
          rawNombre.contains(' ')) {
        return _desglosarNombreYApellido(rawNombre);
      }
      if (rawNombre.isEmpty && data['displayName'] != null) {
        return _desglosarNombreYApellido(data['displayName'].toString());
      }
      return (rawNombre, rawApellido);
    }();

    final String email =
        (data['email'] ?? data['correo'] ?? data['correoElectronico'] ?? '')
            .toString();

    // ✅ CRÍTICO: Mapear correctamente el campo 'activo'
    bool activo = true;
    if (data.containsKey('activo')) {
      activo = data['activo'] ?? true;
    } else if (data.containsKey('active')) {
      activo = data['active'] ?? true;
    } else if (data.containsKey('estadoRol')) {
      // Compatibilidad con tu modelo Usuario
      activo = data['estadoRol'] == 'activo';
    }

    return AdminUsuarioModel(
      uid: uid,
      nombre: nombre,
      apellido: apellido,
      email: email,
      rol: data['rol'] ?? 'usuario',
      telefono: (data['telefono'] ?? data['phone'] ?? data['celular'] ?? '')
          .toString(),
      fechaRegistro: fechaRegistro,
      activo: activo,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'activo': activo,
    };
  }

  // Método para obtener nombre completo
  String get nombreCompleto {
    final partes = <String>[];
    if (nombre.isNotEmpty) partes.add(nombre);
    if (apellido.isNotEmpty) partes.add(apellido);
    return partes.isEmpty ? 'Sin nombre' : partes.join(' ');
  }

  // Copiar con cambios
  AdminUsuarioModel copyWith({
    String? uid,
    String? nombre,
    String? apellido,
    String? email,
    String? rol,
    String? telefono,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return AdminUsuarioModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  // Método para validar si el modelo tiene datos completos
  bool get esValido {
    return nombre.isNotEmpty && email.isNotEmpty;
  }

  @override
  String toString() {
    return 'AdminUsuarioModel(uid: $uid, nombre: $nombre, apellido: $apellido, email: $email, rol: $rol, telefono: $telefono, activo: $activo)';
  }
}
