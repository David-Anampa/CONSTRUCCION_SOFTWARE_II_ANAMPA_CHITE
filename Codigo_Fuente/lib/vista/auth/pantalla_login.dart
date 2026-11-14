import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/auth/login_vm.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  late final LoginVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = LoginVM();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginVM>.value(
      value: _vm,
      child: const _PantallaLoginContent(),
    );
  }
}

class _PantallaLoginContent extends StatelessWidget {
  const _PantallaLoginContent();


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0FB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
              const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.pets, size: 40, color: Colors.teal),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "SOS Mascota",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Encuentra a tu mascota perdida",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Tarjeta de Login
              Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: vm.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Iniciar Sesión",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo Correo
                      TextFormField(
                        controller: vm.correoCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: "tu@email.com",
                          labelText: "Correo electrónico",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v != null && v.contains('@')
                            ? null
                            : "Correo inválido",
                      ),
                      const SizedBox(height: 15),

                      // Campo Contraseña
                      TextFormField(
                        controller: vm.claveCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: "********",
                          labelText: "Contraseña",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v != null && v.length >= 6
                            ? null
                            : "Mínimo 6 caracteres",
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/recuperar");
                          },
                          child: const Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón Entrar
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: vm.cargando
                            ? null
                            : () async {
                                final ruta = await vm.loginYDeterminarRuta();
                                if (!context.mounted) return;

                                if (ruta != null) {
                                  Navigator.pushReplacementNamed(context, ruta);
                                } else if (vm.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(vm.error!),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        label: vm.cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Entrar"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Registro Usuario
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes una cuenta? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/registro");
                    },
                    child: const Text("Registrarse"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contacto de Soporte
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withOpacity(0.25)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.support_agent, size: 16, color: Colors.teal),
                        SizedBox(width: 6),
                        Text(
                          "Contacto de Soporte",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          const ClipboardData(text: "chitchitedanilo@gmail.com"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("📋 Correo copiado al portapapeles"),
                            backgroundColor: Colors.teal,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Colors.teal),
                          const SizedBox(width: 4),
                          const Text(
                            "chitchitedanilo@gmail.com",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.teal,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy, size: 13, color: Colors.teal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Toca el correo para copiarlo",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
