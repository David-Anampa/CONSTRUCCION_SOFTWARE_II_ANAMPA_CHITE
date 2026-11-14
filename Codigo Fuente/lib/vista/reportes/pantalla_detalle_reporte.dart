// /**
//  * Archivo/Clase : pantalla_detalle_reporte.dart / PantallaDetalleReporte
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Visor fotográfico a pantalla completa con transición Hero y zoom
//  *                 interactivo (InteractiveViewer) para inspeccionar imágenes de reportes.
//  * Se vincula con: - USA: flutter/material.dart (Hero, InteractiveViewer, Image.network).
//  *                 - ES USADO POR: Vistas de detalle que muestran fotografías ampliables
//  *                   ([POR CONFIRMAR]: verificar si aún tiene llamadas activas).
//  * Funcionamiento: Renderiza un Scaffold de fondo negro centrado en la imagen remota.
//  * Requerimiento : RF-10 (Visualizar detalle fotográfico de reportes)
//  */

import 'package:flutter/material.dart';

/// Visor de imagen en pantalla completa con soporte de zoom táctil y animación [Hero].
class PantallaDetalleReporte extends StatelessWidget {
  final String imagenUrl;
  final String titulo;

  /// Crea una instancia de [PantallaDetalleReporte] para mostrar [imagenUrl] con [titulo].
  const PantallaDetalleReporte({
    super.key,
    required this.imagenUrl,
    required this.titulo,
  });

  /// Construye el visor centrado con [InteractiveViewer] y estado de carga.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Hero(
          tag: imagenUrl,
          child: InteractiveViewer(
            child: Image.network(
              imagenUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
