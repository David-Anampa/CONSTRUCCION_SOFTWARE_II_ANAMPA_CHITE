import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/admin/admin_vm.dart';

class PantallaRegistroAdmin extends StatelessWidget {
  const PantallaRegistroAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminVM>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
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
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.red),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Registrar Administrador",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        "Panel de control SOS Mascota",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: vm.dniCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.badge_outlined, color: Colors.red),
                            labelText: "DNI",
                            labelStyle: const TextStyle(color: Colors.red),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Ingrese DNI";
                            }
                            if (v.trim().length < 6) return "DNI inválido";
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: vm.buscandoDni
                            ? null
                            : () async {
                                await vm.buscarYAutocompletarNombre();
                                if (vm.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(vm.error!)),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        child: vm.buscandoDni
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Buscar"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: vm.nombreCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.red),
                      labelText: "Nombre completo",
                      labelStyle: const TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Nombre requerido"
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: vm.correoCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.red),
                      labelText: "Correo electrónico",
                      labelStyle: const TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (v) => (v != null && v.contains("@"))
                        ? null
                        : "Correo inválido",
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: vm.telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.red),
                      labelText: "Teléfono",
                      labelStyle: const TextStyle(color: Colors.red),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (v) => RegExp(r'^[0-9]+$').hasMatch(v ?? '')
                        ? null
                        : "Teléfono inválido",
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: vm.claveCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.red),
                      labelText: "Contraseña",
                      labelStyle: const TextStyle(color: Colors.red),
                      helperText: "Mínimo 6 caracteres",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (v) => (v != null && v.length >= 6)
                        ? null
                        : "Ingrese 6+ caracteres",
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: vm.cargando
                        ? null
                        : () async {
                            final ok = await vm.registrarAdministrador();
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
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: vm.cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Registrar Administrador"),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tienes una cuenta? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: const Text("Iniciar sesión", style: TextStyle(color: Colors.red)),
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