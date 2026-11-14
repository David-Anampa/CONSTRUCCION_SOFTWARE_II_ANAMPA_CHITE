import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String dni;
  final String rol;
  final bool estadoVerificado;
  final String estadoRol;
  final String? fotoPerfil;
  final DateTime? fechaRegistro;
  final String? fcmToken;
  final bool activo;

  // NUEVO: vínculo con tabla Colaboradores
  final String? idColaborador;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.dni,
    required this.rol,
    required this.estadoVerificado,
    required this.estadoRol,
    this.fotoPerfil,
    this.fechaRegistro,
    this.fcmToken,
    this.activo = true,
    this.idColaborador, // nuevo
  });

  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      nombre: map["nombre"] ?? "",
      correo: map["correo"] ?? "",
      telefono: map["telefono"] ?? "",
      dni: map["dni"] ?? "",
      rol: map["rol"] ?? "usuario",
      estadoVerificado: map["estadoVerificado"] ?? false,
      estadoRol: map["estadoRol"] ?? "activo",
      fotoPerfil: map["fotoPerfil"],
      fechaRegistro: map["fechaRegistro"] != null
          ? (map["fechaRegistro"] as Timestamp).toDate()
          : null,
      fcmToken: map["fcmToken"],
      activo: map["activo"] ?? true,
      idColaborador: map["idColaborador"], // NUEVO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "correo": correo,
      "telefono": telefono,
      "dni": dni,
      "rol": rol,
      "estadoVerificado": estadoVerificado,
      "estadoRol": estadoRol,
      "fotoPerfil": fotoPerfil,
      "fechaRegistro": fechaRegistro != null
          ? Timestamp.fromDate(fechaRegistro!)
          : FieldValue.serverTimestamp(),
      "fcmToken": fcmToken,
      "activo": activo,

      // NUEVO
      "idColaborador": idColaborador,
    };
  }
}
