// /**
//  * Archivo/Clase : pantalla_registro.dart / PantallaRegistro
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Pantalla de registro para nuevos usuarios comunes con validación de
//  *                 nombre, correo electrónico, teléfono numérico y contraseña mínima.
//  * Se vincula con: - USA: RegistroVM (registro_vm.dart), Provider y Navigator (`/verificaEmail`, `/login`).
//  *                 - ES USADO POR: app.dart (ruta `/registro`), PantallaLogin y pruebas RF-02.
//  * Funcionamiento: Consume RegistroVM, valida los campos del formulario y, si el alta en
//  *                 Firebase resulta exitosa, redirige a la pantalla de verificación de correo.
//  * Requerimiento : RF-02 / REQ02 (Registrar usuario)
//  */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/auth/registro_vm.dart';

/// Pantalla de registro de cuentas nuevas para usuarios de SOS Mascota.
class PantallaRegistro extends StatelessWidget {
  /// Crea una instancia constante de [PantallaRegistro].
  const PantallaRegistro({super.key});

  /// Construye el formulario de registro conectado al proveedor [RegistroVM].
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RegistroVM>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FB), // Fondo azul claro
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: vm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo y encabezados
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFEAF0FB),
                        child: Icon(Icons.pets, size: 40, color: Colors.teal),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Únete a la comunidad SOS Mascota",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nombre (Primer campo visible)
                  TextFormField(
                    controller: vm.nombreCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      labelText: "Nombre completo",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Nombre requerido"
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Correo
                  TextFormField(
                    controller: vm.correoCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v != null && v.contains("@"))
                        ? null
                        : "Correo inválido",
                  ),
                  const SizedBox(height: 12),

                  // Teléfono
                  TextFormField(
                    controller: vm.telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined),
                      labelText: "Teléfono",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => RegExp(r'^[0-9]+$').hasMatch(v ?? '')
                        ? null
                        : "Teléfono inválido",
                  ),
                  const SizedBox(height: 12),

                  // Contraseña
                  TextFormField(
                    controller: vm.claveCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: "Contraseña",
                      helperText: "Mínimo 6 caracteres",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v != null && v.length >= 6)
                        ? null
                        : "Ingrese 6+ caracteres",
                  ),
                  const SizedBox(height: 16),

                  // Botón Registrarse
                  ElevatedButton(
                    onPressed: vm.cargando
                        ? null
                        : () async {
                            final ok = await vm.registrarUsuario();
                            if (!context.mounted) return;
                            if (ok) {
                              Navigator.pushReplacementNamed(
                                context,
                                "/verificaEmail",
                              );
                            } else if (vm.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.error!)),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: vm.cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Registrarse"),
                  ),
                  const SizedBox(height: 16),

                  // Volver a login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tienes una cuenta? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: const Text("Iniciar sesión"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
