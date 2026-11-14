// /**
//  * Archivo/Clase : adminusuario_model.dart / AdminUsuarioModel
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelo especializado para la gestión administrativa de cuentas de
//  *                 usuario, con soporte de normalización de nombres y múltiples alias de campos.
//  * Se vincula con: - USA: cloud_firestore (Timestamp) y flutter/foundation.dart (debugPrint).
//  *                 - ES USADO POR: AdminUsuarioVM (adminusuario_vm.dart) y
//  *                   PantallaAdminUsuarios (pantalla_adminusuarios.dart).
//  * Funcionamiento: Deserializa documentos heterogéneos de la colección 'usuarios' separando
//  *                 nombres y apellidos, resolviendo el estado 'activo' y proveyendo métodos
//  *                 inmutables como copyWith y validadores de integridad.
//  * Requerimiento : RF-15 (Gestionar usuarios desde el panel administrativo)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Modelo de datos de usuario para el módulo de administración.
///
/// Soporta la lectura tolerante a fallos de documentos de Firestore que pueden
/// provenir de distintas versiones del esquema de registro.
class AdminUsuarioModel {
  final String uid;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String telefono;
  final DateTime fechaRegistro;
  final bool activo;

  /// Crea una instancia de [AdminUsuarioModel].
  ///
  /// - Parámetros: Identificador [uid], datos personales ([nombre], [apellido], [email],
  ///   [telefono]), privilegio [rol], [fechaRegistro] e indicador de cuenta [activo].
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
  ///
  /// - Parámetros: [nombreCompleto] cadena con uno o más tokens separados por espacios.
  /// - Valor de retorno: Record `(String nombre, String apellido)` separado según la cantidad de palabras.
  /// - Efectos secundarios: Ninguno (función pura).
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
  /// Factoría de compatibilidad que delega la construcción a [AdminUsuarioModel.fromFirestore].
  ///
  /// - Parámetros: [data] mapa de campos del usuario; [uid] identificador único.
  /// - Valor de retorno: Instancia de [AdminUsuarioModel].
  factory AdminUsuarioModel.fromMap(Map<String, dynamic> data, String uid) {
    return AdminUsuarioModel.fromFirestore(data, uid);
  }

  // Crear desde Firestore con manejo robusto de datos
  /// Construye un [AdminUsuarioModel] normalizando alias de campos y formatos de fecha.
  ///
  /// - Parámetros: [data] mapa crudo del documento en Firestore; [uid] ID del documento.
  /// - Valor de retorno: Instancia normalizada de [AdminUsuarioModel].
  /// - Errores: Captura internamente errores de parseo de fecha, usando `DateTime.now()` como respaldo.
  /// - Efectos secundarios: Registra en consola mediante [debugPrint] si falla el parseo de `fechaRegistro`.
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
  /// Serializa el modelo administrativo a un mapa para su actualización en Firestore.
  ///
  /// - Valor de retorno: `Map<String, dynamic>` con los campos estandarizados.
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
  /// Concatena [nombre] y [apellido] ignorando partes vacías, o retorna `'Sin nombre'`.
  String get nombreCompleto {
    final partes = <String>[];
    if (nombre.isNotEmpty) partes.add(nombre);
    if (apellido.isNotEmpty) partes.add(apellido);
    return partes.isEmpty ? 'Sin nombre' : partes.join(' ');
  }

  // Copiar con cambios
  /// Crea una copia de este [AdminUsuarioModel] reemplazando únicamente los campos provistos.
  ///
  /// - Parámetros: Campos opcionales a sobrescribir.
  /// - Valor de retorno: Nueva instancia inmutable de [AdminUsuarioModel].
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
  /// Indica si el usuario posee al menos [nombre] y [email] no vacíos.
  bool get esValido {
    return nombre.isNotEmpty && email.isNotEmpty;
  }

  /// Retorna una representación textual de depuración con las propiedades del usuario.
  @override
  String toString() {
    return 'AdminUsuarioModel(uid: $uid, nombre: $nombre, apellido: $apellido, email: $email, rol: $rol, telefono: $telefono, activo: $activo)';
  }
}
