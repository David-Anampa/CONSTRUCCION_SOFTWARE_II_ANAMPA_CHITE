// /**
//  * Archivo/Clase : video_background.dart / VideoBackground, _VideoBackgroundState
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Widget con estado que reproduce en bucle y sin sonido un video local
//  *                 ('assets/Video/video.mp4') como fondo animado de pantalla.
//  * Se vincula con: - USA: flutter/material.dart y video_player (VideoPlayerController, VideoPlayer).
//  *                 - ES USADO POR: Vistas que requieren fondo de video animado
//  *                   ([POR CONFIRMAR]: componente visual disponible en lib/widgets/).
//  * Funcionamiento: Inicializa un VideoPlayerController en initState(), activa el bucle y
//  *                 silencia el audio, renderizando el reproductor ajustado con BoxFit.cover
//  *                 y liberando el controlador nativo en dispose().
//  * Requerimiento : Por definir (Componente visual transversal de interfaz de usuario)
//  */

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget que reproduce un video local en bucle como fondo decorativo.
class VideoBackground extends StatefulWidget {
  /// Crea una instancia constante de [VideoBackground].
  const VideoBackground({super.key});

  /// Crea el estado mutable [_VideoBackgroundState] que administra el controlador de video.
  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

/// Estado interno de [VideoBackground] encargado del ciclo de vida de [VideoPlayerController].
class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  /// Inicializa el controlador de video desde `assets/Video/video.mp4` en bucle y sin volumen.
  ///
  /// - Efectos secundarios: Carga el recurso multimedia en memoria y comienza la reproducción.
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/Video/video.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  /// Libera los recursos nativos del reproductor de video al desmontar el widget.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Construye el reproductor de video a pantalla completa o un contenedor oscuro mientras carga.
  ///
  /// - Parámetros: [context] contexto de construcción del árbol de widgets.
  /// - Precondiciones: Debe usarse dentro de un widget [Stack].
  /// - Valor de retorno: Widget [Positioned] que ocupa todo el espacio disponible.
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: _initialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
                // Capa semitransparente para bajar brillo
                Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ],
            )
          : Container(
              color: Colors.black.withOpacity(0.4),
            ),
    );
  }
}
