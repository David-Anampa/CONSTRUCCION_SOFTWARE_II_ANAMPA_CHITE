// /**
//  * Archivo/Clase : image_background.dart / ImageBackground
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Widget decorativo reutilizable que renderiza una imagen de activo a
//  *                 pantalla completa con una capa oscura semitransparente para mejorar el contraste.
//  * Se vincula con: - USA: flutter/material.dart (Positioned, Stack, Image.asset, Container).
//  *                 - ES USADO POR: Vistas de interfaz de usuario que requieren fondo gráfico
//  *                   atenuado ([POR CONFIRMAR]: disponible como componente visual en lib/widgets/).
//  * Funcionamiento: Expande un Stack mediante Positioned.fill superponiendo un Container
//  *                 negro con opacidad configurable sobre la imagen de fondo.
//  * Requerimiento : Por definir (Componente visual transversal de interfaz de usuario)
//  */

import 'package:flutter/material.dart';

/// Widget de fondo que muestra una imagen de asset cubierta por un filtro oscuro.
class ImageBackground extends StatelessWidget {
  /// Ruta relativa del recurso gráfico dentro de la carpeta `assets/`.
  final String assetPath;

  /// Nivel de opacidad de la máscara negra superpuesta (entre `0.0` y `1.0`).
  final double opacity;

  /// Crea un widget [ImageBackground] con la ruta [assetPath] y [opacity] opcional.
  const ImageBackground({
    super.key,
    required this.assetPath,
    this.opacity = 0.25,
  });

  /// Construye la pila posicionada con la imagen expandida y el filtro de oscurecimiento.
  ///
  /// - Parámetros: [context] contexto de construcción del widget.
  /// - Precondiciones: Debe ubicarse como hijo directo de un widget [Stack].
  /// - Valor de retorno: Widget [Positioned] que cubre toda el área del [Stack] padre.
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
          // Overlay para bajar brillo
          Container(color: Colors.black.withOpacity(opacity)),
        ],
      ),
    );
  }
}
