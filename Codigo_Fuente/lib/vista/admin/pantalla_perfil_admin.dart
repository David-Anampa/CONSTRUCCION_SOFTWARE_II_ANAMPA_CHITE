import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PantallaPerfilAdmin extends StatefulWidget {
  const PantallaPerfilAdmin({super.key});

  @override
  State<PantallaPerfilAdmin> createState() => _PantallaPerfilAdminState();
}

class _PantallaPerfilAdminState extends State<PantallaPerfilAdmin> {
  bool _modoOscuro = false;
  File? _imagenPerfil;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosAdmin();
  }

  Future<void> _cargarDatosAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Si los apellidos están guardados por separado
        String apellidos = data['apellido'] ?? '';
        
        // Si los apellidos están dentro del campo 'nombre', los separamos
        String nombreCompleto = data['nombre'] ?? '';
        if (apellidos.isEmpty && nombreCompleto.isNotEmpty) {
          // Separar nombre y apellidos
          List<String> partes = nombreCompleto.split(' ');
          if (partes.length > 2) {
            // Si hay más de 2 palabras, las primeras 2 son nombres y el resto apellidos
            _nombreController.text = '${partes[0]} ${partes[1]}';
            _apellidoController.text = partes.sublist(2).join(' ');
          } else if (partes.length == 2) {
            // Si hay 2 palabras, la primera es nombre y la segunda apellido
            _nombreController.text = partes[0];
            _apellidoController.text = partes[1];
          } else {
            // Si solo hay 1 palabra, todo es nombre
            _nombreController.text = nombreCompleto;
          }
        } else {
          _nombreController.text = nombreCompleto;
          _apellidoController.text = apellidos;
        }
        
        setState(() {
          _telefonoController.text = data['telefono'] ?? '';
          _correoController.text = user.email ?? '';
          _cargando = false;
        });
      }
    }
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (imagen != null) {
      setState(() {
        _imagenPerfil = File(imagen.path);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen seleccionada correctamente')),
        );
      }
    }
  }

  Future<void> _guardarCambios() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'nombre': _nombreController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF0F172A) : const Color(0xFFF1F5FB),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E293B) : const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Perfil - Admin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _modoOscuro = !_modoOscuro;
              });
            },
            icon: Icon(
              _modoOscuro ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Sección de foto de perfil
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E3A5F).withOpacity(0.08),
                          border: Border.all(
                            color: const Color(0xFF1E3A5F),
                            width: 3,
                          ),
                        ),
                        child: _imagenPerfil != null
                            ? ClipOval(
                                child: Image.file(
                                  _imagenPerfil!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.admin_panel_settings,
                                size: 60,
                                color: Color(0xFF1E3A5F),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _seleccionarImagen,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Badge de Administrador
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A5F).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'ADMINISTRADOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Cambiar foto de avatar',
                    style: TextStyle(
                      color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Información Personal
                  _buildSeccionTitulo('Información Personal'),
                  const SizedBox(height: 16),

                  _buildCampoTexto(
                    controller: _nombreController,
                    label: 'Nombre Completo',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

                  _buildCampoTexto(
                    controller: _apellidoController,
                    label: 'Apellidos',
                    icon: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 16),

                  _buildCampoTexto(
                    controller: _correoController,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    enabled: false,
                  ),

                  const SizedBox(height: 16),

                  _buildCampoTexto(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 30),

                  // Seguridad
                  _buildSeccionTitulo('Seguridad'),
                  const SizedBox(height: 16),

                  _buildOpcionPerfil(
                    icon: Icons.lock_outline,
                    titulo: 'Cambiar contraseña',
                    onTap: () {
                      _mostrarDialogCambiarContrasena();
                    },
                  ),

                  const SizedBox(height: 30),

                  // Botón Guardar Cambios
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF1E3A5F).withOpacity(0.4),
                      ),
                      label: const Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón Cerrar Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, "/login");
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _modoOscuro ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _modoOscuro
              ? Colors.white12
              : const Color(0xFF1E3A5F).withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _modoOscuro ? Colors.white : const Color(0xFF1E293B),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF1E3A5F),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionPerfil({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _modoOscuro ? Colors.white : Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: _modoOscuro ? Colors.grey[400] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogCambiarContrasena() {
    final contrasenaActualController = TextEditingController();
    final contrasenaNuevaController = TextEditingController();
    final contrasenaConfirmarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            color: _modoOscuro ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contrasenaActualController,
              obscureText: true,
              style: TextStyle(
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                labelStyle: TextStyle(
                  color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contrasenaNuevaController,
              obscureText: true,
              style: TextStyle(
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                labelStyle: TextStyle(
                  color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contrasenaConfirmarController,
              obscureText: true,
              style: TextStyle(
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                labelStyle: TextStyle(
                  color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: _modoOscuro ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contrasenaNuevaController.text == contrasenaConfirmarController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contraseña actualizada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Las contraseñas no coinciden'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }
}