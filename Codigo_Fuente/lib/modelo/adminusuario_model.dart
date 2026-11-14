import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ✅ Crear desde Map (para compatibilidad con fromMap)
  factory AdminUsuarioModel.fromMap(Map<String, dynamic> data, String uid) {
    return AdminUsuarioModel.fromFirestore(data, uid);
  }

  // Crear desde Firestore con manejo robusto de datos
  factory AdminUsuarioModel.fromFirestore(Map<String, dynamic> data, String uid) {
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
        print('Error al parsear fecha: $e');
        fechaRegistro = DateTime.now();
      }
    }
    
    // Intentar múltiples variaciones de nombres de campos
    String nombre = '';
    String apellido = '';
    String email = '';
    
    // Para apellido: buscar primero en los campos directos
    apellido = (data['apellido'] ?? 
                data['apellidos'] ?? 
                data['lastName'] ?? 
                data['apellidoPaterno'] ?? 
                '').toString();
    
    // Para nombre: buscar en campos directos
    nombre = (data['nombre'] ?? 
              data['nombres'] ?? 
              data['name'] ?? 
              '').toString();
    
    // Si apellido está vacío pero nombre tiene múltiples palabras, separar
    // según la convención mexicana de nombres
    if (apellido.isEmpty && nombre.isNotEmpty && nombre.contains(' ')) {
      final partes = nombre.trim().split(RegExp(r'\s+'));
      
      if (partes.length == 2) {
        // Un nombre y un apellido: "YESSICA HINOJOSA"
        nombre = partes[0];
        apellido = partes[1];
      } else if (partes.length == 3) {
        // Dos nombres y un apellido: "YESSICA ANDREA HINOJOSA"
        nombre = '${partes[0]} ${partes[1]}';
        apellido = partes[2];
      } else if (partes.length >= 4) {
        // Dos nombres y dos apellidos: "YESSICA ANDREA HINOJOSA MUCHO"
        nombre = '${partes[0]} ${partes[1]}';
        apellido = partes.sublist(2).join(' ');
      }
    }
    
    // Si aún no hay nombre pero hay displayName, usarlo y separar
    if (nombre.isEmpty && data['displayName'] != null) {
      final nombreCompleto = data['displayName'].toString().trim();
      final partes = nombreCompleto.split(RegExp(r'\s+'));
      
      if (partes.length == 1) {
        // Solo un nombre: "YESSICA"
        nombre = partes[0];
        apellido = '';
      } else if (partes.length == 2) {
        // Un nombre y un apellido: "YESSICA HINOJOSA"
        nombre = partes[0];
        apellido = partes[1];
      } else if (partes.length == 3) {
        // Dos nombres y un apellido: "YESSICA ANDREA HINOJOSA"
        nombre = '${partes[0]} ${partes[1]}';
        apellido = partes[2];
      } else if (partes.length >= 4) {
        // Dos nombres y dos apellidos: "YESSICA ANDREA HINOJOSA MUCHO"
        nombre = '${partes[0]} ${partes[1]}';
        apellido = partes.sublist(2).join(' ');
      }
    }
    
    // Para email: buscar "email", "correo", "correoElectronico"
    email = (data['email'] ?? 
             data['correo'] ?? 
             data['correoElectronico'] ?? 
             '').toString();
    
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
      telefono: (data['telefono'] ?? 
                data['phone'] ?? 
                data['celular'] ?? 
                '').toString(),
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