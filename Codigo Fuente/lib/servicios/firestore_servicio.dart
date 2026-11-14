// /**
//  * Archivo/Clase : firestore_servicio.dart / FirestoreServicio
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Servicio de acceso a datos que gestiona el guardado y la actualización
//  *                 del estado de verificación de documentos en la colección 'usuarios'.
//  * Se vincula con: - USA: cloud_firestore (FirebaseFirestore, SetOptions).
//  *                 - ES USADO POR: PantallaVerificaEmail (pantalla_verifica_email.dart).
//  * Funcionamiento: Ejecuta escrituras merge y actualizaciones parciales sobre el documento
//  *                 identificado por el UID del usuario en Cloud Firestore.
//  * Requerimiento : RF-02 / REQ02 (Registrar usuario y confirmar verificación de correo)
//  */

import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio de persistencia para operaciones puntuales sobre la colección `usuarios` en Firestore.
class FirestoreServicio {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Guarda o actualiza un usuario en la colección `usuarios`
  ///
  /// - Parámetros: [uid] identificador único del documento; [data] mapa de campos a persistir.
  /// - Precondiciones: [uid] no debe ser vacío.
  /// - Valor de retorno: [Future<void>].
  /// - Errores: Lanza [FirebaseException] si falla la escritura o por permisos insuficientes.
  /// - Efectos secundarios: Crea o fusiona (`merge: true`) el documento `usuarios/{uid}` en Firestore.
  Future<void> guardarUsuario(String uid, Map<String, dynamic> data) async {
    await _db
        .collection("usuarios")
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Actualiza el indicador booleano `estadoVerificado` del usuario en Firestore.
  ///
  /// - Parámetros: [uid] identificador del usuario; [verificado] nuevo estado de verificación.
  /// - Precondiciones: El documento `usuarios/{uid}` debe existir previamente en la colección.
  /// - Valor de retorno: [Future<void>].
  /// - Errores: Lanza [FirebaseException] (código `not-found` si el documento no existe).
  /// - Efectos secundarios: Modifica el campo `estadoVerificado` en Cloud Firestore.
  Future<void> actualizarEstadoVerificado(String uid, bool verificado) async {
    await _db.collection("usuarios").doc(uid).update({
      "estadoVerificado": verificado,
    });
  }
}
