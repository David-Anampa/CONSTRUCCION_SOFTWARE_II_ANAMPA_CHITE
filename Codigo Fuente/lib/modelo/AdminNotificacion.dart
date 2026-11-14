// /**
//  * Archivo/Clase : AdminNotificacion.dart / AdminNotificacion, PlantillaNotificacion
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Modelos para el envío masivo, grupal o individual de notificaciones
//  *                 administrativas y catálogo de plantillas predefinidas.
//  * Se vincula con: - USA: cloud_firestore (Timestamp).
//  *                 - ES USADO POR: AdminNotificacionesVM (AdminNotificaciones_vm.dart) y
//  *                   PantallaAdminNotificaciones (pantallaAdminNotificaciones.dart).
//  * Funcionamiento: Representa el historial almacenado en 'notificaciones_admin' y provee
//  *                 mensajes preconfigurados listos para autocompletar en la consola admin.
//  * Requerimiento : RF-07 (Notificaciones), RF-16 (Gestión administrativa de notificaciones)
//  */

// modelo/AdminNotificacion.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa una campaña o envío de notificación emitido desde el panel de administración.
class AdminNotificacion {
  String? id;
  String titulo;
  String mensaje;
  String tipo; // "todos", "individual", "grupo"
  String? destinatarioId; // Para notificaciones individuales
  List<String>? destinatariosIds; // Para notificaciones grupales
  String prioridad; // "alta", "media", "baja"
  DateTime fechaEnvio;
  bool enviada;
  int totalEnviados;
  String? imagenUrl;
  String? accion; // "abrir_app", "ir_reportes", "ir_perfil", etc.
  Map<String, dynamic>? datos; // Datos adicionales
  
  /// Crea un registro de [AdminNotificacion] asignando la fecha actual si [fechaEnvio] se omite.
  AdminNotificacion({
    this.id,
    required this.titulo,
    required this.mensaje,
    this.tipo = "todos",
    this.destinatarioId,
    this.destinatariosIds,
    this.prioridad = "media",
    DateTime? fechaEnvio,
    this.enviada = false,
    this.totalEnviados = 0,
    this.imagenUrl,
    this.accion,
    this.datos,
  }) : fechaEnvio = fechaEnvio ?? DateTime.now();
  
  // Convertir a Map para Firestore
  /// Serializa la notificación administrativa a un mapa para la colección `notificaciones_admin`.
  ///
  /// - Valor de retorno: `Map<String, dynamic>` con los metadatos del envío.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'destinatarioId': destinatarioId,
      'destinatariosIds': destinatariosIds,
      'prioridad': prioridad,
      'fechaEnvio': fechaEnvio,
      'enviada': enviada,
      'totalEnviados': totalEnviados,
      'imagenUrl': imagenUrl,
      'accion': accion,
      'datos': datos,
    };
  }
  
  // Crear desde Firestore
  /// Reconstruye una instancia de [AdminNotificacion] desde un documento de Firestore.
  ///
  /// - Parámetros: [id] ID del documento; [data] mapa de campos almacenados.
  /// - Valor de retorno: Instancia de [AdminNotificacion].
  factory AdminNotificacion.fromMap(String id, Map<String, dynamic> data) {
    return AdminNotificacion(
      id: id,
      titulo: data['titulo'] ?? '',
      mensaje: data['mensaje'] ?? '',
      tipo: data['tipo'] ?? 'todos',
      destinatarioId: data['destinatarioId'],
      destinatariosIds: data['destinatariosIds'] != null 
          ? List<String>.from(data['destinatariosIds']) 
          : null,
      prioridad: data['prioridad'] ?? 'media',
      fechaEnvio: (data['fechaEnvio'] is Timestamp)
          ? (data['fechaEnvio'] as Timestamp).toDate()
          : DateTime.now(),
      enviada: data['enviada'] ?? false,
      totalEnviados: data['totalEnviados'] ?? 0,
      imagenUrl: data['imagenUrl'],
      accion: data['accion'],
      datos: data['datos'],
    );
  }
}

// Clase para plantillas de notificaciones
/// Modelo de plantilla rápida para autocompletar título y mensaje de notificaciones.
class PlantillaNotificacion {
  String nombre;
  String titulo;
  String mensaje;
  String icono;
  
  /// Crea una plantilla de notificación con su [nombre], [titulo], [mensaje] e [icono].
  PlantillaNotificacion({
    required this.nombre,
    required this.titulo,
    required this.mensaje,
    required this.icono,
  });
  
  /// Retorna el catálogo estático de plantillas predefinidas para el administrador.
  ///
  /// - Valor de retorno: `List<PlantillaNotificacion>` con 5 plantillas de uso frecuente.
  static List<PlantillaNotificacion> obtenerPlantillas() {
    return [
      PlantillaNotificacion(
        nombre: "Mascota Encontrada",
        titulo: "¡Buenas noticias! 🎉",
        mensaje: "Se ha reportado el avistamiento de una mascota que podría ser la tuya.",
        icono: "🐾",
      ),
      PlantillaNotificacion(
        nombre: "Actualización del Sistema",
        titulo: "Actualización Disponible 🔄",
        mensaje: "Hay una nueva versión de la app con mejoras y nuevas funcionalidades.",
        icono: "📱",
      ),
      PlantillaNotificacion(
        nombre: "Recordatorio",
        titulo: "Recuerda actualizar tu reporte 📝",
        mensaje: "¿Ya encontraste a tu mascota? Actualiza el estado de tu reporte.",
        icono: "⏰",
      ),
      PlantillaNotificacion(
        nombre: "Consejo del Día",
        titulo: "Consejo para cuidar a tu mascota 💡",
        mensaje: "Mantén siempre actualizada la información y fotos de tu mascota.",
        icono: "💡",
      ),
      PlantillaNotificacion(
        nombre: "Alerta Importante",
        titulo: "⚠️ Alerta Importante",
        mensaje: "Por favor, revisa tu cuenta para más información.",
        icono: "⚠️",
      ),
    ];
  }
}