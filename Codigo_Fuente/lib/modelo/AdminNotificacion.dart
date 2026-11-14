// modelo/AdminNotificacion.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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
class PlantillaNotificacion {
  String nombre;
  String titulo;
  String mensaje;
  String icono;
  
  PlantillaNotificacion({
    required this.nombre,
    required this.titulo,
    required this.mensaje,
    required this.icono,
  });
  
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