import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/AdminReporte.dart';

class AdminReportesVM extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _cargando = false;
  bool get cargando => _cargando;
  
  String _filtroEstado = "TODOS";
  String get filtroEstado => _filtroEstado;
  
  String _busqueda = "";
  String get busqueda => _busqueda;
  
  List<AdminReporte> _reportes = [];
  List<AdminReporte> get reportes => _reportes;
  
  List<AdminAvistamiento> _avistamientos = [];
  List<AdminAvistamiento> get avistamientos => _avistamientos;

  // Flag para controlar si el widget está montado
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Método seguro para notificar cambios
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Estadísticas
  int get totalReportes => _reportes.length;
  int get reportesPerdidos => _reportes.where((r) => r.estado == "PERDIDO").length;
  int get reportesEncontrados => _reportes.where((r) => r.estado == "ENCONTRADO").length;
  int get totalAvistamientos => _avistamientos.length;

  // Cambiar filtro de estado
  void cambiarFiltro(String nuevoFiltro) {
    _filtroEstado = nuevoFiltro;
    _safeNotifyListeners();
  }

  // Actualizar búsqueda
  void actualizarBusqueda(String texto) {
    _busqueda = texto.toLowerCase();
    _safeNotifyListeners();
  }

  // Cargar reportes con información del usuario
  Future<void> cargarReportes() async {
    if (_disposed) return;
    
    try {
      _cargando = true;
      _safeNotifyListeners();

      final snapshot = await _firestore
          .collection("reportes_mascotas")
          .orderBy("fechaRegistro", descending: true)
          .get();

      if (_disposed) return; // Verificar antes de continuar

      _reportes = [];
      
      for (var doc in snapshot.docs) {
        if (_disposed) return; // Verificar en cada iteración
        
        final data = doc.data();
        final usuarioId = data["usuarioId"];
        
        // Obtener información del usuario
        String nombreUsuario = "Usuario desconocido";
        String emailUsuario = "";
        
        if (usuarioId != null) {
          try {
            final userDoc = await _firestore.collection("usuarios").doc(usuarioId).get();
            
            if (_disposed) return; // Verificar después de operación asíncrona
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              nombreUsuario = userData["nombre"] ?? "Sin nombre";
              emailUsuario = userData["correo"] ?? "";
            }
          } catch (e) {
            debugPrint("Error obteniendo usuario: $e");
          }
        }

        final reporte = AdminReporte.fromMap(data, doc.id);
        reporte.nombreUsuario = nombreUsuario;
        reporte.emailUsuario = emailUsuario;
        
        _reportes.add(reporte);
      }

      if (_disposed) return;

      _cargando = false;
      _safeNotifyListeners();
    } catch (e) {
      if (_disposed) return;
      
      _cargando = false;
      _safeNotifyListeners();
      debugPrint("❌ Error cargando reportes: $e");
    }
  }

  // Cargar avistamientos con información del usuario
  Future<void> cargarAvistamientos() async {
    if (_disposed) return;
    
    try {
      _cargando = true;
      _safeNotifyListeners();

      final snapshot = await _firestore
          .collection("avistamientos")
          .orderBy("fechaRegistro", descending: true)
          .get();

      if (_disposed) return;

      _avistamientos = [];
      
      for (var doc in snapshot.docs) {
        if (_disposed) return;
        
        final data = doc.data();
        final usuarioId = data["usuarioId"];
        
        String nombreUsuario = "Usuario desconocido";
        String emailUsuario = "";
        
        if (usuarioId != null) {
          try {
            final userDoc = await _firestore.collection("usuarios").doc(usuarioId).get();
            
            if (_disposed) return;
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              nombreUsuario = userData["nombre"] ?? "Sin nombre";
              emailUsuario = userData["correo"] ?? "";
            }
          } catch (e) {
            debugPrint("Error obteniendo usuario: $e");
          }
        }

        final avistamiento = AdminAvistamiento.fromMap(data, doc.id);
        avistamiento.nombreUsuario = nombreUsuario;
        avistamiento.emailUsuario = emailUsuario;
        
        _avistamientos.add(avistamiento);
      }

      if (_disposed) return;

      _cargando = false;
      _safeNotifyListeners();
    } catch (e) {
      if (_disposed) return;
      
      _cargando = false;
      _safeNotifyListeners();
      debugPrint("❌ Error cargando avistamientos: $e");
    }
  }

  // Eliminar reporte (OPTIMIZADO Y CORREGIDO)
  Future<bool> eliminarReporte(String reporteId, String motivo) async {
    if (_disposed) return false;
    
    try {
      // Obtener datos del reporte antes de eliminarlo
      final reporteDoc = await _firestore.collection("reportes_mascotas").doc(reporteId).get();
      
      if (_disposed) return false;
      
      if (!reporteDoc.exists) {
        debugPrint("❌ Reporte no encontrado");
        return false;
      }

      final reporteData = reporteDoc.data()!;
      final usuarioId = reporteData["usuarioId"];

      // Guardar en colección de eliminados
      await _firestore.collection("reportes_eliminados").doc(reporteId).set({
        ...reporteData,
        "motivoEliminacion": motivo,
        "fechaEliminacion": FieldValue.serverTimestamp(),
      });

      if (_disposed) return false;

      // Eliminar de Firebase
      await _firestore.collection("reportes_mascotas").doc(reporteId).delete();

      if (_disposed) return false;

      // Actualizar lista local
      _reportes.removeWhere((r) => r.id == reporteId);
      _safeNotifyListeners();

      // Enviar notificación al usuario (si existe usuarioId)
      if (usuarioId != null && usuarioId.isNotEmpty) {
        try {
          await _firestore.collection("notificaciones").add({
            "usuarioId": usuarioId,
            "titulo": "⚠️ Reporte eliminado",
            "mensaje": "Tu reporte ha sido eliminado por el administrador. Motivo: $motivo",
            "tipo": "eliminacion_reporte",
            "leido": false,
            "fecha": FieldValue.serverTimestamp(),
          });
          debugPrint("✅ Notificación enviada al usuario");
        } catch (e) {
          debugPrint("⚠️ Error enviando notificación: $e");
        }
      }

      return true;
    } catch (e) {
      debugPrint("❌ Error eliminando reporte: $e");
      return false;
    }
  }

  // Eliminar avistamiento (OPTIMIZADO Y CORREGIDO)
  Future<bool> eliminarAvistamiento(String avistamientoId, String motivo) async {
    if (_disposed) return false;
    
    try {
      // Obtener datos del avistamiento antes de eliminarlo
      final avistaDoc = await _firestore.collection("avistamientos").doc(avistamientoId).get();
      
      if (_disposed) return false;
      
      if (!avistaDoc.exists) {
        debugPrint("❌ Avistamiento no encontrado");
        return false;
      }

      final avistaData = avistaDoc.data()!;
      final usuarioId = avistaData["usuarioId"];

      // Guardar en colección de eliminados
      await _firestore.collection("avistamientos_eliminados").doc(avistamientoId).set({
        ...avistaData,
        "motivoEliminacion": motivo,
        "fechaEliminacion": FieldValue.serverTimestamp(),
      });

      if (_disposed) return false;

      // Eliminar de Firebase
      await _firestore.collection("avistamientos").doc(avistamientoId).delete();

      if (_disposed) return false;

      // Actualizar lista local
      _avistamientos.removeWhere((a) => a.id == avistamientoId);
      _safeNotifyListeners();

      // Enviar notificación al usuario (si existe usuarioId)
      if (usuarioId != null && usuarioId.isNotEmpty) {
        try {
          await _firestore.collection("notificaciones").add({
            "usuarioId": usuarioId,
            "titulo": "⚠️ Avistamiento eliminado",
            "mensaje": "Tu avistamiento ha sido eliminado por el administrador. Motivo: $motivo",
            "tipo": "eliminacion_avistamiento",
            "leido": false,
            "fecha": FieldValue.serverTimestamp(),
          });
          debugPrint("✅ Notificación enviada al usuario");
        } catch (e) {
          debugPrint("⚠️ Error enviando notificación: $e");
        }
      }

      return true;
    } catch (e) {
      debugPrint("❌ Error eliminando avistamiento: $e");
      return false;
    }
  }

  // Filtrar reportes
  List<AdminReporte> get reportesFiltrados {
    var resultado = _reportes;

    // Filtrar por estado
    if (_filtroEstado != "TODOS") {
      resultado = resultado.where((r) => r.estado == _filtroEstado).toList();
    }

    // Filtrar por búsqueda
    if (_busqueda.isNotEmpty) {
      resultado = resultado.where((r) {
        return r.nombre.toLowerCase().contains(_busqueda) ||
               r.tipo.toLowerCase().contains(_busqueda) ||
               r.raza.toLowerCase().contains(_busqueda) ||
               r.distrito.toLowerCase().contains(_busqueda) ||
               r.nombreUsuario.toLowerCase().contains(_busqueda);
      }).toList();
    }

    return resultado;
  }

  // Filtrar avistamientos
  List<AdminAvistamiento> get avistamientosFiltrados {
    var resultado = _avistamientos;

    if (_busqueda.isNotEmpty) {
      resultado = resultado.where((a) {
        return a.descripcion.toLowerCase().contains(_busqueda) ||
               a.distrito.toLowerCase().contains(_busqueda) ||
               a.nombreUsuario.toLowerCase().contains(_busqueda);
      }).toList();
    }

    return resultado;
  }
}