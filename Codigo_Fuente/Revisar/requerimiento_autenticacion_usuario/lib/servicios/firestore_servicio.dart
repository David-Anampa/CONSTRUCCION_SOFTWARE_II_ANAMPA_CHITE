import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServicio {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Guarda o actualiza un usuario en la colección `usuarios`
  Future<void> guardarUsuario(String uid, Map<String, dynamic> data) async {
    await _db
        .collection("usuarios")
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<void> actualizarEstadoVerificado(String uid, bool verificado) async {
    await _db.collection("usuarios").doc(uid).update({
      "estadoVerificado": verificado,
    });
  }
}
