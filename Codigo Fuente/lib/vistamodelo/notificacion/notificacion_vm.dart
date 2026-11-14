// /**
//  * Archivo/Clase : notificacion_vm.dart / NotificacionVM
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : ViewModel que mantiene la lista reactiva de notificaciones del usuario,
//  *                 el contador de no leídas y operaciones de marcado o eliminación.
//  * Se vincula con: - USA: Notificacion (notificacion.dart), NotificacionServicio
//  *                   (notificacion_servicio.dart), FirebaseAuth y FirebaseFirestore.
//  *                 - ES USADO POR: app.dart y PantallaNotificaciones (pantalla_notificacion.dart).
//  * Funcionamiento: Se suscribe al stream de notificaciones del usuario actual, recalcula
//  *                 el contador noLeidas y ejecuta actualizaciones por lotes o individuales.
//  * Requerimiento : RF-07 (Enviar y recibir notificaciones)
//  */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/notificacion.dart';
import '../../servicios/notificacion_servicio.dart';

/// ViewModel encargado del estado de la bandeja de notificaciones del usuario.
class NotificacionVM extends ChangeNotifier {
  final List<Notificacion> _notificaciones = [];
  List<Notificacion> get notificaciones => List.unmodifiable(_notificaciones);

  int _noLeidas = 0;
  int get noLeidas => _noLeidas;

  StreamSubscription? _subs;

  /// 🔔 Escucha las notificaciones en tiempo real
  ///
  /// Cancela cualquier suscripción previa y abre un nuevo listener sobre
  /// [NotificacionServicio.obtenerNotificaciones] para el usuario autenticado.
  /// - Efectos secundarios: Modifica [_notificaciones], [_noLeidas] y notifica listeners.
  void escucharNotificaciones() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subs?.cancel();
    _subs = NotificacionServicio.obtenerNotificaciones(uid).listen((lista) {
      _notificaciones
        ..clear()
        ..addAll(lista);
      _noLeidas = lista.where((n) => n.leido == false).length;
      notifyListeners();
    });
  }

  /// ✅ Marca todas las notificaciones como leídas
  ///
  /// Ejecuta un `WriteBatch` en Firestore sobre las notificaciones no leídas del usuario.
  /// - Valor de retorno: [Future<void>].
  /// - Efectos secundarios: Actualiza `leido: true` en Firestore y reinicia [_noLeidas] a 0.
  Future<void> marcarTodasComoLeidas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final query = await FirebaseFirestore.instance
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: uid)
        .where('leido', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      batch.update(doc.reference, {'leido': true});
    }

    await batch.commit();
    _noLeidas = 0;
    notifyListeners();
  }

  /// ✅ Marca una notificación individual como leída
  ///
  /// - Parámetros: [notificacionId] ID del documento en la colección `notificaciones`.
  /// - Efectos secundarios: Actualiza el campo `leido` en Firestore.
  Future<void> marcarComoLeida(String notificacionId) async {
    await FirebaseFirestore.instance
        .collection('notificaciones')
        .doc(notificacionId)
        .update({'leido': true});
    // El stream actualizará la lista automáticamente
  }

  /// 🗑️ Elimina una notificación
  ///
  /// - Parámetros: [notificacionId] identificador del documento a borrar en Firestore.
  Future<void> eliminarNotificacion(String notificacionId) async {
    await FirebaseFirestore.instance
        .collection('notificaciones')
        .doc(notificacionId)
        .delete();
  }

  /// 🚫 Detener la escucha
  ///
  /// Cancela la suscripción activa al stream de notificaciones para evitar fugas de memoria.
  void detenerEscucha() {
    _subs?.cancel();
    _subs = null;
  }
}
