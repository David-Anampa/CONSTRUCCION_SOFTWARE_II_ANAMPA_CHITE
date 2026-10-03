import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../modelo/comentario_model.dart';

/// ViewModel para la gestión reactiva de comentarios asociados a publicaciones.
class ComentariosViewModel extends ChangeNotifier {
  final CollectionReference _ref =
      FirebaseFirestore.instance.collection('comentarios');

  /// Retorna un Stream con la lista ordenada cronológicamente de comentarios.
  Stream<List<Comentario>> obtenerComentarios() {
    return _ref.orderBy('fecha', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Comentario.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
