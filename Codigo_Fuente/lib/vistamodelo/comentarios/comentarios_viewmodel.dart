import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/comentario_model.dart';

/// ViewModel para acceder a los comentarios de un reporte o avistamiento.
///
/// La ruta de Firestore se construye dinámicamente según [tipo] y [reporteId],
/// apuntando a la subcolección correcta:
/// - `reportes_mascotas/{reporteId}/comentarios` si [tipo] es `'reporte'`.
/// - `avistamientos/{reporteId}/comentarios` si [tipo] es `'avistamiento'`.
class ComentariosViewModel {
  /// Identificador del documento padre (reporte o avistamiento).
  final String reporteId;

  /// Tipo de publicación: `'reporte'` o `'avistamiento'`.
  final String tipo;

  ComentariosViewModel({
    required this.reporteId,
    required this.tipo,
  });

  /// Nombre de la colección padre en Firestore según [tipo].
  String get _coleccionPadre =>
      tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';

  /// Referencia a la subcolección de comentarios del documento padre.
  CollectionReference get _comentariosRef =>
      FirebaseFirestore.instance
          .collection(_coleccionPadre)
          .doc(reporteId)
          .collection('comentarios');

  /// Retorna un [Stream] con la lista de [Comentario] ordenados por fecha
  /// descendente (más reciente primero).
  Stream<List<Comentario>> obtenerComentarios() {
    return _comentariosRef
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((instantanea) {
      return instantanea.docs
          .map(
            (documento) => Comentario.fromMap(
              documento.id,
              documento.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }
}
