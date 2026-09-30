// vistamodelo/admin/AdminNotificaciones_vm.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/AdminNotificacion.dart';

class AdminNotificacionesVM extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _cargando = false;
  bool get cargando => _cargando;
  
  bool _enviando = false;
  bool get enviando => _enviando;
  
  // Controladores de texto
  final tituloController = TextEditingController();
  final mensajeController = TextEditingController();
  
  // Opciones de envío
  String _tipoEnvio = "todos"; // todos, individual, grupo
  String get tipoEnvio => _tipoEnvio;
  
  String _prioridad = "media"; // alta, media, baja
  String get prioridad => _prioridad;
  
  String? _usuarioSeleccionado;
  String? get usuarioSeleccionado => _usuarioSeleccionado;
  
  List<String> _usuariosSeleccionados = [];
  List<String> get usuariosSeleccionados => _usuariosSeleccionados;
  
  // Lista de usuarios disponibles
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> get usuarios => _usuarios;
  
  // Lista de usuarios filtrados para búsqueda
  List<Map<String, dynamic>> _usuariosFiltrados = [];
  List<Map<String, dynamic>> get usuariosFiltrados => _usuariosFiltrados;
  
  // Texto de búsqueda
  String _textoBusqueda = "";
  String get textoBusqueda => _textoBusqueda;
  
  // Historial de notificaciones
  List<AdminNotificacion> _historial = [];
  List<AdminNotificacion> get historial => _historial;
  
  // Estadísticas
  int _totalEnviadas = 0;
  int get totalEnviadas => _totalEnviadas;
  
  StreamSubscription? _subsHistorial;
  
  @override
  void dispose() {
    tituloController.dispose();
    mensajeController.dispose();
    _subsHistorial?.cancel();
    super.dispose();
  }
  
  // 📋 CARGAR USUARIOS
  Future<void> cargarUsuarios() async {
    try {
      _cargando = true;
      notifyListeners();
      
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', isNotEqualTo: 'admin')
          .get();
      
      _usuarios = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'] ?? 'Sin nombre',
          'email': data['email'] ?? '',
          'token': data['fcmToken'], // Token para notificaciones push
        };
      }).toList();
      
      // Inicializar usuarios filtrados con todos los usuarios
      _usuariosFiltrados = List.from(_usuarios);
      
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _cargando = false;
      _usuarios = [];
      _usuariosFiltrados = [];
      notifyListeners();
      debugPrint("❌ Error cargando usuarios: $e");
    }
  }
  
  // 🔍 BUSCAR USUARIO
  void buscarUsuario(String texto) {
    _textoBusqueda = texto.toLowerCase();
    
    if (_textoBusqueda.isEmpty) {
      // Si no hay búsqueda, mostrar todos
      _usuariosFiltrados = List.from(_usuarios);
    } else {
      // Filtrar por nombre o email
      _usuariosFiltrados = _usuarios.where((usuario) {
        final nombre = usuario['nombre'].toString().toLowerCase();
        final email = usuario['email'].toString().toLowerCase();
        return nombre.contains(_textoBusqueda) || email.contains(_textoBusqueda);
      }).toList();
    }
    
    notifyListeners();
  }
  
  // 🔎 OBTENER USUARIO POR ID
  Map<String, dynamic> obtenerUsuarioPorId(String usuarioId) {
    try {
      return _usuarios.firstWhere(
        (usuario) => usuario['id'] == usuarioId,
        orElse: () => {
          'id': usuarioId,
          'nombre': 'Usuario no encontrado',
          'email': '',
          'token': null,
        },
      );
    } catch (e) {
      return {
        'id': usuarioId,
        'nombre': 'Usuario no encontrado',
        'email': '',
        'token': null,
      };
    }
  }
  
  // 🧹 LIMPIAR SELECCIÓN DE GRUPO
  void limpiarSeleccionGrupo() {
    _usuariosSeleccionados.clear();
    notifyListeners();
  }
  
  // 📜 CARGAR HISTORIAL EN TIEMPO REAL
  void escucharHistorial() {
    _subsHistorial?.cancel();
    
    _subsHistorial = _firestore
        .collection('notificaciones_admin')
        .orderBy('fechaEnvio', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _historial = snapshot.docs
          .map((doc) => AdminNotificacion.fromMap(doc.id, doc.data()))
          .toList();
      
      // Calcular total enviadas
      _totalEnviadas = _historial.where((n) => n.enviada).length;
      
      notifyListeners();
    }, onError: (e) {
      debugPrint("❌ Error escuchando historial: $e");
      _historial = [];
      _totalEnviadas = 0;
      notifyListeners();
    });
  }
  
  // 🔄 CAMBIAR TIPO DE ENVÍO
  void cambiarTipoEnvio(String tipo) {
    _tipoEnvio = tipo;
    _usuarioSeleccionado = null;
    _usuariosSeleccionados.clear();
    _textoBusqueda = "";
    _usuariosFiltrados = List.from(_usuarios); // Resetear filtro
    notifyListeners();
  }
  
  // 🔄 CAMBIAR PRIORIDAD
  void cambiarPrioridad(String prioridad) {
    _prioridad = prioridad;
    notifyListeners();
  }
  
  // 👤 SELECCIONAR USUARIO INDIVIDUAL
  void seleccionarUsuario(String? usuarioId) {
    _usuarioSeleccionado = usuarioId;
    notifyListeners();
  }
  
  // 👥 TOGGLE USUARIO EN GRUPO
  void toggleUsuarioGrupo(String usuarioId) {
    if (_usuariosSeleccionados.contains(usuarioId)) {
      _usuariosSeleccionados.remove(usuarioId);
    } else {
      _usuariosSeleccionados.add(usuarioId);
    }
    notifyListeners();
  }
  
  // 📝 APLICAR PLANTILLA
  void aplicarPlantilla(PlantillaNotificacion plantilla) {
    tituloController.text = plantilla.titulo;
    mensajeController.text = plantilla.mensaje;
    notifyListeners();
  }
  
  // ✅ VALIDAR FORMULARIO
  String? validarFormulario() {
    if (tituloController.text.trim().isEmpty) {
      return "El título es obligatorio";
    }
    if (mensajeController.text.trim().isEmpty) {
      return "El mensaje es obligatorio";
    }
    if (_tipoEnvio == "individual" && _usuarioSeleccionado == null) {
      return "Selecciona un usuario";
    }
    if (_tipoEnvio == "grupo" && _usuariosSeleccionados.isEmpty) {
      return "Selecciona al menos un usuario";
    }
    return null;
  }
  
  // 📤 ENVIAR NOTIFICACIÓN
  Future<bool> enviarNotificacion() async {
    final error = validarFormulario();
    if (error != null) {
      debugPrint("❌ Error de validación: $error");
      return false;
    }
    
    try {
      _enviando = true;
      notifyListeners();
      
      // Crear notificación admin
      final notificacionAdmin = AdminNotificacion(
        titulo: tituloController.text.trim(),
        mensaje: mensajeController.text.trim(),
        tipo: _tipoEnvio,
        destinatarioId: _usuarioSeleccionado,
        destinatariosIds: _tipoEnvio == "grupo" ? _usuariosSeleccionados : null,
        prioridad: _prioridad,
        enviada: true,
        totalEnviados: _calcularTotalDestinatarios(),
      );
      
      // Guardar en colección admin
      await _firestore.collection('notificaciones_admin').add(notificacionAdmin.toMap());
      
      // Crear notificaciones individuales para cada usuario
      await _crearNotificacionesUsuarios(notificacionAdmin);
      
      // Limpiar formulario
      tituloController.clear();
      mensajeController.clear();
      _usuarioSeleccionado = null;
      _usuariosSeleccionados.clear();
      
      _enviando = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _enviando = false;
      notifyListeners();
      debugPrint("❌ Error enviando notificación: $e");
      return false;
    }
  }
  
  // 📊 CALCULAR TOTAL DESTINATARIOS
  int _calcularTotalDestinatarios() {
    switch (_tipoEnvio) {
      case "todos":
        return _usuarios.length;
      case "individual":
        return 1;
      case "grupo":
        return _usuariosSeleccionados.length;
      default:
        return 0;
    }
  }
  
  // 📲 CREAR NOTIFICACIONES PARA USUARIOS
  Future<void> _crearNotificacionesUsuarios(AdminNotificacion notificacion) async {
    try {
      final batch = _firestore.batch();
      List<String> destinatarios = [];
      
      // Determinar destinatarios según el tipo
      switch (notificacion.tipo) {
        case "todos":
          destinatarios = _usuarios.map((u) => u['id'] as String).toList();
          break;
        case "individual":
          if (notificacion.destinatarioId != null) {
            destinatarios = [notificacion.destinatarioId!];
          }
          break;
        case "grupo":
          destinatarios = notificacion.destinatariosIds ?? [];
          break;
      }
      
      // Crear una notificación para cada usuario
      for (String usuarioId in destinatarios) {
        final docRef = _firestore.collection('notificaciones').doc();
        batch.set(docRef, {
          'titulo': notificacion.titulo,
          'mensaje': notificacion.mensaje,
          'usuarioId': usuarioId,
          'tipo': notificacion.tipo,
          'leido': false,
          'fecha': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint("✅ ${destinatarios.length} notificaciones creadas");
      
    } catch (e) {
      debugPrint("❌ Error creando notificaciones de usuarios: $e");
    }
  }
  
  // 🗑️ ELIMINAR NOTIFICACIÓN DEL HISTORIAL
  Future<void> eliminarNotificacion(String notificacionId) async {
    try {
      await _firestore.collection('notificaciones_admin').doc(notificacionId).delete();
    } catch (e) {
      debugPrint("❌ Error eliminando notificación: $e");
    }
  }
  
  // 🚫 Detener escucha
  void detenerEscucha() {
    _subsHistorial?.cancel();
    _subsHistorial = null;
  }
}