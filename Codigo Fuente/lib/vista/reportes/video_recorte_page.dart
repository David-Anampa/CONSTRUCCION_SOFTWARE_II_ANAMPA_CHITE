// /**
//  * Archivo/Clase : video_recorte_page.dart / VideoRecortePage, _VideoRecortePageState
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pantalla de recorte de video (máximo 10 segundos) previo a su subida
//  *                 como evidencia multimedia dentro del reporte de mascota perdida.
//  * Se vincula con: - USA: ReporteMascotaVM (reporte_vm.dart), video_trimmer (Trimmer) y Provider.
//  *                 - ES USADO POR: PantallaReporteMascota (pantalla_reporte_mascota.dart).
//  * Funcionamiento: Carga el archivo de video en Trimmer, permite ajustar el intervalo
//  *                 inicio/fin y al guardar sube el clip recortado mediante ReporteMascotaVM.
//  * Requerimiento : RF-04 (Registrar reporte de mascota con evidencia en video)
//  */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';
import '../../vistamodelo/reportes/reporte_vm.dart';

/// Pantalla para recortar clips de video de hasta 10 segundos antes de adjuntarlos al reporte.
class VideoRecortePage extends StatefulWidget {
  final File videoFile;

  /// Crea una instancia de [VideoRecortePage] recibiendo el archivo [videoFile] seleccionado.
  const VideoRecortePage({super.key, required this.videoFile});

  @override
  State<VideoRecortePage> createState() => _VideoRecortePageState();
}

/// Estado de [VideoRecortePage] que controla el [Trimmer] y los límites de recorte.
class _VideoRecortePageState extends State<VideoRecortePage> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 10.0;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _trimmer.loadVideo(videoFile: widget.videoFile);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ReporteMascotaVM>();

    return SafeArea(
      // 👈 evita que el menú o notch tape el contenido
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recortar video"),
          backgroundColor: Colors.teal,
        ),
        body: Column(
          children: [
            Expanded(child: VideoViewer(trimmer: _trimmer)),
            Center(
              child: TrimViewer(
                trimmer: _trimmer,
                viewerHeight: 50.0,
                viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: const Duration(seconds: 10),
                onChangeStart: (value) => _startValue = value,
                onChangeEnd: (value) => _endValue = value,
                onChangePlaybackState: (playing) {},
              ),
            ),
            const SizedBox(height: 20),
            _cargando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text("Guardar clip (≤10s)"),
                    onPressed: () async {
                      setState(() => _cargando = true);

                      await _trimmer.saveTrimmedVideo(
                        startValue: _startValue,
                        endValue: _endValue,
                        onSave: (outputPath) async {
                          if (outputPath != null) {
                            final fileClip = File(outputPath);

                            // Subir a Firebase
                            final url = await vm.subirVideo(fileClip);
                            vm.agregarVideo(url);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Video recortado y guardado ✅"),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                      );

                      setState(() => _cargando = false);
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
