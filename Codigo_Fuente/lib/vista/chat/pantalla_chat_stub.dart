import 'package:flutter/material.dart';

/// RF-08: Comunicar usuarios coincidentes
///
/// Esta pantalla es un stub/placeholder intencional.
/// La funcionalidad de chat está FUERA DE ALCANCE para SOSMascota v1.0
/// según el Informe de Pruebas Planificadas del curso Construcción de Software I.
///
/// NO está conectada a ningún backend de chat real.
/// Será implementada en la versión 2.0 del sistema.
class PantallaChatStub extends StatelessWidget {
  const PantallaChatStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono decorativo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D9EF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 60,
                  color: Color(0xFF4D9EF6),
                ),
              ),

              const SizedBox(height: 32),

              // Badge "Próximamente"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D9EF6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRÓXIMAMENTE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4D9EF6),
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Título
              const Text(
                'Chat con usuarios',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Descripción
              const Text(
                'La comunicación directa entre usuarios estará disponible en la próxima versión de SOSMascota.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Nota técnica (RF-08)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Color(0xFF856404),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'RF-08: Funcionalidad fuera de alcance — v1.0\n'
                        'Planificada para SOSMascota v2.0.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF856404),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botón deshabilitado
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null, // DESHABILITADO intencionalmente
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Iniciar conversación'),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón de volver
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(
                    color: Color(0xFF4D9EF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
