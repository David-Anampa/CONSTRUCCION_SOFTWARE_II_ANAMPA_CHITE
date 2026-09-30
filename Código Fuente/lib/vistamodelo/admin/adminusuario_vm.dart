import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/adminusuario_model.dart';

class AdminUsuarioVM extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdminUsuarioModel> _usuarios = [];
  List<AdminUsuarioModel> _usuariosFiltrados = [];
  bool _cargando = false;
  String _filtroRol = 'todos';
  String _busqueda = '';

  List<AdminUsuarioModel> get usuarios => _usuariosFiltrados;
  bool get cargando => _cargando;
  String get filtroRol => _filtroRol;

  // Obtener todos los usuarios (excepto admins)
  Stream<List<AdminUsuarioModel>> obtenerUsuariosStream() {
    return _firestore.collection('usuarios').snapshots().map((snapshot) {
      _usuarios = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Filtrar admins aquí
              if (data['rol'] == 'admin') {
                return null;
              }
              return AdminUsuarioModel.fromFirestore(data, doc.id);
            } catch (e) {
              print('Error al procesar usuario ${doc.id}: $e');
              return null;
            }
          })
          .where((usuario) => usuario != null)
          .cast<AdminUsuarioModel>()
          .toList();

      _aplicarFiltros();
      return _usuariosFiltrados;
    });
  }



  // Aplicar filtros de búsqueda y rol
  void _aplicarFiltros() {
    _usuariosFiltrados = _usuarios.where((usuario) {
      // Filtro por rol
      bool cumpleFiltroRol = _filtroRol == 'todos' || usuario.rol == _filtroRol;

      // Filtro por búsqueda (nombre, email o teléfono)
      bool cumpleBusqueda =
          _busqueda.isEmpty ||
          usuario.nombreCompleto.toLowerCase().contains(
            _busqueda.toLowerCase(),
          ) ||
          usuario.email.toLowerCase().contains(_busqueda.toLowerCase()) ||
          usuario.telefono.toLowerCase().contains(_busqueda.toLowerCase());

      return cumpleFiltroRol && cumpleBusqueda;
    }).toList();

    notifyListeners();
  }

  // Cambiar filtro de rol
  void cambiarFiltroRol(String nuevoFiltro) {
    _filtroRol = nuevoFiltro;
    _aplicarFiltros();
  }

  // Buscar usuarios
  void buscarUsuarios(String termino) {
    _busqueda = termino;
    _aplicarFiltros();
  }

  // 🔥 Activar/Desactivar usuario - VERSIÓN MEJORADA CON LOGS
  Future<bool> cambiarEstadoUsuario(String uid, bool nuevoEstado) async {
    try {
      print('');
      print('╔════════════════════════════════════════════════════╗');
      print('║        INICIANDO CAMBIO DE ESTADO USUARIO         ║');
      print('╚════════════════════════════════════════════════════╝');
      print('📌 UID: $uid');
      print(
        '📌 Nuevo Estado: $nuevoEstado (${nuevoEstado ? "ACTIVO" : "DESACTIVADO"})',
      );
      print('📌 Timestamp: ${DateTime.now()}');
      print('');

      // Verificar que el documento existe
      final docRef = _firestore.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print('❌ ERROR: El documento NO EXISTE en Firestore');
        print('   Collection: usuarios');
        print('   Document ID: $uid');
        return false;
      }

      final datosAnteriores = docSnapshot.data();
      print('✅ Documento encontrado en Firestore');
      print('📄 Datos ANTES del cambio:');
      print(
        '   - Email: ${datosAnteriores?['correo'] ?? datosAnteriores?['email']}',
      );
      print('   - Nombre: ${datosAnteriores?['nombre']}');
      print('   - Rol: ${datosAnteriores?['rol']}');
      print('   - Estado Actual: ${datosAnteriores?['activo']}');
      print('');

      // Actualizar el campo 'activo'
      print('🔄 Ejecutando actualización en Firestore...');
      await docRef.update({'activo': nuevoEstado});

      print('✅ Comando UPDATE ejecutado exitosamente');
      print('');

      // Esperar un momento para que Firestore procese
      await Future.delayed(const Duration(milliseconds: 800));

      // Verificar el cambio
      print('🔍 Verificando el cambio en Firestore...');
      final docVerificacion = await docRef.get();
      final datosNuevos = docVerificacion.data();

      print('');
      print('╔════════════════════════════════════════════════════╗');
      print('║              VERIFICACIÓN FINAL                    ║');
      print('╚════════════════════════════════════════════════════╝');
      print('📊 Campo "activo" en Firestore: ${datosNuevos?['activo']}');
      print(
        '✅ ¿Cambió correctamente?: ${datosNuevos?['activo'] == nuevoEstado ? "SÍ ✓" : "NO ✗"}',
      );

      if (datosNuevos?['activo'] == nuevoEstado) {
        print('🎉 ÉXITO: El estado se cambió correctamente');
      } else {
        print('⚠️ ADVERTENCIA: El estado NO cambió como se esperaba');
        print('   Esperado: $nuevoEstado');
        print('   Obtenido: ${datosNuevos?['activo']}');
      }
      print('╚════════════════════════════════════════════════════╝');
      print('');

      notifyListeners();
      return datosNuevos?['activo'] == nuevoEstado;
    } catch (e, stackTrace) {
      print('');
      print('╔════════════════════════════════════════════════════╗');
      print('║                  ⚠️  ERROR CRÍTICO                 ║');
      print('╚════════════════════════════════════════════════════╝');
      print('❌ Tipo de error: ${e.runtimeType}');
      print('❌ Mensaje: $e');
      print('');
      print('📍 Stack Trace:');
      print(stackTrace);
      print('╚════════════════════════════════════════════════════╝');
      print('');
      return false;
    }
  }

  // Cambiar rol de usuario
  Future<bool> cambiarRolUsuario(String uid, String nuevoRol) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'rol': nuevoRol,
      });
      return true;
    } catch (e) {
      print('Error al cambiar rol: $e');
      return false;
    }
  }

  // Eliminar usuario
  Future<bool> eliminarUsuario(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).delete();
      return true;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }

  // Eliminar colaborador
  Future<bool> eliminarColaborador(String id) async {
    try {
      await _firestore.collection('colaboradores').doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar colaborador: $e');
      return false;
    }
  }

  // Obtener estadísticas
  Map<String, int> obtenerEstadisticas() {
    return {
      'total': _usuarios.length,
      'activos': _usuarios.where((u) => u.activo).length,
      'inactivos': _usuarios.where((u) => !u.activo).length,
      'usuarios': _usuarios.where((u) => u.rol == 'usuario').length,
    };
  }
}
