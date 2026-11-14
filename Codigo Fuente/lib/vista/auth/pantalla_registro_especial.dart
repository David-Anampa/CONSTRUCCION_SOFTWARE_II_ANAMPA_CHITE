// /**
//  * Archivo/Clase : pantalla_registro_especial.dart / PantallaRegistroEspecial
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pantalla informativa que indica que el módulo de registro para
//  *                 veterinarias y albergues se encuentra en desarrollo.
//  * Se vincula con: - USA: flutter/material.dart.
//  *                 - ES USADO POR: Flujos futuros de registro de colaboradores
//  *                   ([POR CONFIRMAR]: sin ruta activa registrada en app.dart).
//  * Funcionamiento: Renderiza un Scaffold estático con ícono y mensaje informativo.
//  * Requerimiento : Por definir (Funcionalidad futura para veterinarias y albergues)
//  */

import 'package:flutter/material.dart';

/// Vista informativa temporal para el registro de veterinarios y albergues.
class PantallaRegistroEspecial extends StatelessWidget {
  /// Crea una instancia constante de [PantallaRegistroEspecial].
  const PantallaRegistroEspecial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Veterinarios / Albergues")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.build_circle_outlined, size: 80, color: Colors.teal),
              SizedBox(height: 20),
              Text(
                "Esta opción está en desarrollo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Próximamente podrá registrar veterinarias y albergues de animales. "
                "Por el momento, esta función no está disponible.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
