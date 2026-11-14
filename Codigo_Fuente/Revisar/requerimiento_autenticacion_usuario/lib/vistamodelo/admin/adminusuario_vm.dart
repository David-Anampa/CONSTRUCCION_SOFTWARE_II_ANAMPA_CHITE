import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/adminusuario_model.dart';
import '../../servicios/firebase_availability.dart' as fb_avail;

class AdminUsuarioVM extends ChangeNotifier {
  /// Obtener stream de todos los usuarios
  Stream<List<AdminUsuarioModel>> obtenerUsuariosStream() {
    if (!fb_avail.firebaseAvailable) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("usuarios")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdminUsuarioModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Cambiar estado del usuario (activo/inactivo)
  Future<void> cambiarEstadoUsuario(String uid, bool nuevoEstado) async {
    if (!fb_avail.firebaseAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .update({"activo": nuevoEstado});
      notifyListeners();
    } catch (e) {
      throw Exception("Error al cambiar estado: $e");
    }
  }

  /// Eliminar usuario
  Future<void> eliminarUsuario(String uid) async {
    if (!fb_avail.firebaseAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .delete();
      notifyListeners();
    } catch (e) {
      throw Exception("Error al eliminar usuario: $e");
    }
  }

  /// Actualizar información del usuario
  Future<void> actualizarUsuario(
      String uid, Map<String, dynamic> datos) async {
    if (!fb_avail.firebaseAvailable) return;

    try {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .update(datos);
      notifyListeners();
    } catch (e) {
      throw Exception("Error al actualizar usuario: $e");
    }
  }
}
