// /**
//  * Archivo/Clase : comentarios_viewmodel.dart / ComentariosViewModel
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel que provee el flujo en tiempo real de comentarios ya sea
//  *                 del muro comunitario general o de la subcolección de un reporte/avistamiento.
//  * Se vincula con: - USA: Comentario (comentario_model.dart) y FirebaseFirestore.
//  *                 - ES USADO POR: PantallaComentarios (pantalla_comentarios.dart) y
//  *                   pruebas unitarias RF-12 (rf12_comentarios_test.dart).
//  * Funcionamiento: Resuelve dinámicamente la referencia de colección según reporteId y tipo
//  *                 ('reporte' -> 'reportes_mascotas', otro -> 'avistamientos') y expone
//  *                 un Stream ordenado descendentemente por fecha.
//  * Requerimiento : RF-12 (Agregar y visualizar comentarios)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../modelo/comentario_model.dart';

/// ViewModel para la gestión reactiva de comentarios asociados a publicaciones.
class ComentariosViewModel extends ChangeNotifier {
  final String? reporteId;
  final String? tipo;

  /// Crea una instancia de [ComentariosViewModel].
  ///
  /// - Parámetros: [reporteId] y [tipo] opcionales; si se omiten, consulta la colección raíz `comentarios`.
  ComentariosViewModel({
    this.reporteId,
    this.tipo,
  });

  String get _coleccionPadre =>
      tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';

  CollectionReference get _ref => (reporteId != null && tipo != null)
      ? FirebaseFirestore.instance
          .collection(_coleccionPadre)
          .doc(reporteId)
          .collection('comentarios')
      : FirebaseFirestore.instance.collection('comentarios');

  /// Retorna un Stream con la lista ordenada cronológicamente de comentarios.
  ///
  /// - Valor de retorno: `Stream<List<Comentario>>` emitido en tiempo real desde Firestore.
  Stream<List<Comentario>> obtenerComentarios() {
    return _ref.orderBy('fecha', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Comentario.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
