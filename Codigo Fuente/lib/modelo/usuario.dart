// /**
//  * Archivo/Clase : usuario.dart / Usuario
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Entidad de dominio que modela los datos de cuenta, perfil, rol,
//  *                 verificación y token FCM de un usuario registrado en SOS Mascota.
//  * Se vincula con: - USA: cloud_firestore (Timestamp, FieldValue) para serialización.
//  *                 - ES USADO POR: LoginVM (login_vm.dart), RegistroVM (registro_vm.dart),
//  *                   AdminVM (admin_vm.dart) y pruebas unitarias REQ01, REQ02 y RF-02.
//  * Funcionamiento: Provee un modelo inmutable con constructor constante y métodos de
//  *                 conversión bidireccional (fromMap / toMap) hacia la colección 'usuarios'
//  *                 de Cloud Firestore.
//  * Requerimiento : RF-01 / REQ01 (Autenticación), RF-02 / REQ02 (Registro), RF-09 (Perfil)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un usuario registrado en el sistema SOS Mascota.
///
/// Encapsula datos de perfil, credenciales de rol, estado de cuenta y
/// token para notificaciones push de Firebase Cloud Messaging.
class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String rol;
  final bool estadoVerificado;
  final String estadoRol;
  final String? fotoPerfil;
  final DateTime? fechaRegistro;
  final String? fcmToken;
  final bool activo;
  final String? idColaborador;

  /// Crea una instancia inmutable de [Usuario].
  ///
  /// - Parámetros: Datos identificatorios ([id], [nombre], [correo], [telefono]),
  ///   permisos ([rol], [estadoVerificado], [estadoRol], [activo]) y metadatos
  ///   opcionales ([fotoPerfil], [fechaRegistro], [fcmToken], [idColaborador]).
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.estadoVerificado,
    required this.estadoRol,
    this.fotoPerfil,
    this.fechaRegistro,
    this.fcmToken,
    this.activo = true,
    this.idColaborador,
  });

  /// Construye una instancia de [Usuario] a partir de un mapa proveniente de Firestore.
  ///
  /// - Parámetros: [map] diccionario de campos del documento; [id] UID del documento.
  /// - Precondiciones: Si `fechaRegistro` está presente en [map], debe ser de tipo [Timestamp].
  /// - Valor de retorno: Nueva instancia de [Usuario] con valores por defecto seguros.
  /// - Errores: Puede lanzar [TypeError] si `fechaRegistro` no es nulo ni [Timestamp].
  /// - Efectos secundarios: Ninguno (función pura de deserialización).
  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      nombre: map["nombre"] ?? "",
      correo: map["correo"] ?? "",
      telefono: map["telefono"] ?? "",
      rol: map["rol"] ?? "usuario",
      estadoVerificado: map["estadoVerificado"] ?? false,
      estadoRol: map["estadoRol"] ?? "activo",
      fotoPerfil: map["fotoPerfil"],
      fechaRegistro: map["fechaRegistro"] != null
          ? (map["fechaRegistro"] as Timestamp).toDate()
          : null,
      // Admite tanto 'fcmToken' como 'token' por compatibilidad entre módulos de registro y login.
      fcmToken: map["fcmToken"] ?? map["token"],
      activo: map["activo"] ?? true,
      idColaborador: map["idColaborador"],
    );
  }

  /// Convierte la instancia actual en un mapa clave-valor compatible con Cloud Firestore.
  ///
  /// - Parámetros: Ninguno.
  /// - Valor de retorno: `Map<String, dynamic>` listo para persistir en la colección `usuarios`.
  /// - Efectos secundarios: Si [fechaRegistro] es nulo, inserta un marcador
  ///   [FieldValue.serverTimestamp] que será resuelto en el servidor de Firestore.
  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "correo": correo,
      "telefono": telefono,
      "rol": rol,
      "estadoVerificado": estadoVerificado,
      "estadoRol": estadoRol,
      "fotoPerfil": fotoPerfil,
      "fechaRegistro": fechaRegistro != null
          ? Timestamp.fromDate(fechaRegistro!)
          : FieldValue.serverTimestamp(),
      "fcmToken": fcmToken,
      "activo": activo,
      "idColaborador": idColaborador,
    };
  }
}
