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

  /// Retorna un stream en tiempo real de todos los usuarios excepto admins.
  ///
  /// Los documentos con rol `admin` se filtran del lado del cliente
  /// porque Firestore no admite `!=` combinado con `orderBy` en la misma consulta.
  Stream<List<AdminUsuarioModel>> obtenerUsuariosStream() {
    return _firestore.collection('usuarios').snapshots().map((snapshot) {
      _usuarios = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data['rol'] == 'admin') return null;
              return AdminUsuarioModel.fromFirestore(data, doc.id);
            } catch (e) {
              debugPrint('Error al deserializar usuario ${doc.id}: $e');
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

  /// Activa o desactiva la cuenta de un usuario en Firestore.
  ///
  /// Hace una lectura previa para verificar que el documento exista antes de
  /// actualizar, porque Firestore no lanza error si se actualiza un doc inexistente
  /// cuando se usa `update()` con un documento que no tiene los permisos correctos.
  ///
  /// Retorna `true` si el campo `activo` quedó con el valor esperado, `false` si
  /// el documento no existe, o si ocurrió un error.
  Future<bool> cambiarEstadoUsuario(String uid, bool nuevoEstado) async {
    try {
      final docRef = _firestore.collection('usuarios').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        debugPrint('❌ cambiarEstadoUsuario: doc no existe para uid=$uid');
        return false;
      }

      await docRef.update({'activo': nuevoEstado});

      // Verificación post-escritura: Firestore puede devolver ok en update()
      // aunque las reglas lo silencien. La lectura confirma el estado real.
      await Future.delayed(const Duration(milliseconds: 800));
      final verificacion = await docRef.get();
      final estadoFinal = verificacion.data()?['activo'];

      notifyListeners();
      return estadoFinal == nuevoEstado;
    } catch (e, stackTrace) {
      debugPrint('❌ Error en cambiarEstadoUsuario (uid=$uid): $e\n$stackTrace');
      return false;
    }
  }

  /// Cambia el [nuevoRol] del usuario identificado por [uid].
  ///
  /// Retorna `true` si la operación fue exitosa, `false` en caso de error.
  Future<bool> cambiarRolUsuario(String uid, String nuevoRol) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'rol': nuevoRol,
      });
      return true;
    } catch (e) {
      debugPrint('Error al cambiar rol (uid=$uid): $e');
      return false;
    }
  }

  /// Elimina el documento del usuario [uid] de la colección `usuarios`.
  ///
  /// Retorna `true` si fue exitoso, `false` en caso de error.
  Future<bool> eliminarUsuario(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar usuario (uid=$uid): $e');
      return false;
    }
  }

  /// Elimina el documento del colaborador [id] de la colección `colaboradores`.
  ///
  /// Retorna `true` si fue exitoso, `false` en caso de error.
  Future<bool> eliminarColaborador(String id) async {
    try {
      await _firestore.collection('colaboradores').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error al eliminar colaborador (id=$id): $e');
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
