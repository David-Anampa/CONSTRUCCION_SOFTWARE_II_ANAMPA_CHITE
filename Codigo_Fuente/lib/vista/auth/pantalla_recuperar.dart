import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/auth/recuperar_vm.dart';

class PantallaRecuperar extends StatelessWidget {
  const PantallaRecuperar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecuperarVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: vm.enviado
                ? _buildExito(context, vm)
                : _buildFormulario(context, vm),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 📬 Estado: correo enviado exitosamente
  // ─────────────────────────────────────────────
  Widget _buildExito(BuildContext context, RecuperarVM vm) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos un enlace de recuperación a:\n${vm.correoCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisa tu bandeja de entrada y sigue las instrucciones. Si no lo ves, revisa el spam.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 32),

        // Botón volver al login
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Volver al inicio de sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ),
        const SizedBox(height: 16),

        // Botón intentar con otro correo
        TextButton(
          onPressed: vm.reiniciar,
          child: const Text(
            'Intentar con otro correo',
            style: TextStyle(color: Colors.teal),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 📝 Estado: formulario de recuperación
  // ─────────────────────────────────────────────
  Widget _buildFormulario(BuildContext context, RecuperarVM vm) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Ícono
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset, size: 48, color: Colors.teal),
        ),
        const SizedBox(height: 20),

        const Text(
          'Recuperar contraseña',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 32),

        // Tarjeta del formulario
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: vm.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de correo
                TextFormField(
                  controller: vm.correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                    labelText: 'Correo electrónico',
                    hintText: 'tu@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    // Validación con RegExp
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),

                // Mensaje de error (si existe)
                if (vm.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Botón enviar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed:
                      vm.enviando ? null : () => vm.enviarCorreo(context),
                  child: vm.enviando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Enviar enlace de recuperación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Volver al login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Recordaste tu contraseña? ',
              style: TextStyle(color: Colors.grey),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
