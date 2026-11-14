// PantallaPerfil.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  String? _fotoUrl;
  bool cargando = true;

  // Modo oscuro local (se alterna con la huella)
  bool _modoOscuro = false;

  // índice por defecto (aseguramos que esté en rango al construir)
  int _currentIndex = 4;

  final List<String> _avataresLocales = [
    "assets/avatars/man.png",
    "assets/avatars/woman.png",
    "assets/avatars/girl.png",
    "assets/avatars/gamer.png",
    "assets/avatars/panda.png",
    "assets/avatars/cat.png",
  ];

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si no hay usuario logueado, hacer fallback (puedes redirigir al login)
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    final uid = user.uid;
    try {
      final doc =
          await FirebaseFirestore.instance.collection("usuarios").doc(uid).get();

      if (doc.exists) {
        final d = doc.data()!;
        _nombreCtrl.text = d["nombre"] ?? "";
        _correoCtrl.text = d["correo"] ?? "";
        _telefonoCtrl.text = d["telefono"] ?? "";
        _fotoUrl = d["fotoPerfil"];
      }
    } catch (e) {
      // manejar error si quieres
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    await FirebaseFirestore.instance.collection("usuarios").doc(uid).update({
      "telefono": _telefonoCtrl.text.trim(),
      "fotoPerfil": _fotoUrl ?? "",
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
  }

  Future<void> _cambiarFoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final ref = FirebaseStorage.instance.ref().child("usuarios/$uid/perfil.jpg");

    try {
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      if (!mounted) return;
      setState(() => _fotoUrl = url);

      await FirebaseFirestore.instance.collection("usuarios").doc(uid).update({
        "fotoPerfil": url,
      });
    } catch (e) {
      // manejar error si quieres
    }
  }

  Future<void> _seleccionarAvatarLocal() async {
    final seleccionado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Selecciona tu avatar"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _avataresLocales.length,
              itemBuilder: (context, index) {
                final avatar = _avataresLocales[index];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, avatar),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(avatar, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (seleccionado != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      setState(() => _fotoUrl = seleccionado);

      await FirebaseFirestore.instance.collection("usuarios").doc(uid).update({
        "fotoPerfil": seleccionado,
      });
    }
  }

  Widget _menuSeleccionAvatar() {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera, color: Colors.teal),
            title: const Text("Tomar foto con cámara"),
            onTap: () => Navigator.pop(context, "camara"),
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.teal),
            title: const Text("Subir foto desde galería"),
            onTap: () => Navigator.pop(context, "galeria"),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions, color: Colors.orange),
            title: const Text("Elegir avatar del sistema"),
            onTap: () => Navigator.pop(context, "avatar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Asegurar currentIndex válido (si acaso)
    final validIndex = (_currentIndex >= 0 && _currentIndex <= 4) ? _currentIndex : 4;

    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF121212) : const Color(0xFFEAF0FB),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          "Mi perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _guardar,
            child: const Text(
              "Guardar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final opcion = await showModalBottomSheet<String>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => _menuSeleccionAvatar(),
                        );

                        if (opcion == "galeria") {
                          await _cambiarFoto(ImageSource.gallery);
                        } else if (opcion == "camara") {
                          await _cambiarFoto(ImageSource.camera);
                        } else if (opcion == "avatar") {
                          await _seleccionarAvatarLocal();
                        }
                      },
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage: _fotoUrl != null
                            ? (_fotoUrl!.startsWith("assets/")
                                ? AssetImage(_fotoUrl!) as ImageProvider
                                : NetworkImage(_fotoUrl!))
                            : null,
                        child: _fotoUrl == null
                            ? const Icon(Icons.pets, color: Colors.teal, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Cambiar foto o avatar",
                        style: TextStyle(color: Colors.teal)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                "Información Personal",
                Column(
                  children: [
                    _buildReadOnlyField("Nombre completo", _nombreCtrl),
                    const SizedBox(height: 12),
                    _buildReadOnlyField("Correo electrónico", _correoCtrl),
                    const SizedBox(height: 12),
                    _buildEditableField("Teléfono", _telefonoCtrl),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                "Seguridad",
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.teal),
                  title: const Text("Cambiar contraseña"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final email = _correoCtrl.text.trim();
                    if (email.isNotEmpty) {
                      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("📧 Enlace enviado a tu correo.")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No hay correo registrado.")),
                      );
                    }
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: validIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) async {
          // Si toca la huella (index 1) => alternar modo oscuro
          if (index == 1) {
            setState(() => _modoOscuro = !_modoOscuro);
            return;
          }

          // acciones para otros índices
          setState(() => _currentIndex = index);

          if (index == 0) {
            Navigator.pushReplacementNamed(context, "/inicio");
          } else if (index == 2) {
            Navigator.pushNamed(context, "/reportarMascota");
          } else if (index == 3) {
            Navigator.pushNamed(context, "/mapa");
          } else if (index == 4) {
            // ya estamos en perfil; no hacemos nada
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 28,
              height: 28,
              child: CustomPaint(
                painter: PawPainter(modoOscuro: _modoOscuro),
              ),
            ),
            label: "Tema",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.add), label: "Reportar"),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _modoOscuro ? Colors.white : Colors.black)),
          const Divider(),
          content,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _modoOscuro ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(color: _modoOscuro ? Colors.white : Colors.black),
    );
  }

  Widget _buildEditableField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: TextStyle(color: _modoOscuro ? Colors.white : Colors.black),
    );
  }
}

// ------------------ PawPainter ------------------

class PawPainter extends CustomPainter {
  final bool modoOscuro;
  PawPainter({required this.modoOscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final mainPadPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(
          size.width * 0.2, size.height * 0.7, size.width * 0.3, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.35, size.height * 0.3, size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.65, size.height * 0.3, size.width * 0.7, size.height * 0.5)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.7, size.width * 0.5, size.height * 0.9)
      ..close();

    // Mitad izquierda
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height));
    paint.color = modoOscuro ? Colors.white : Colors.black;
    canvas.drawPath(mainPadPath, paint);
    canvas.restore();

    // Mitad derecha
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(size.width * 0.5, 0, size.width * 0.5, size.height));
    paint.color = modoOscuro ? Colors.black : Colors.white;
    canvas.drawPath(mainPadPath, paint);
    canvas.restore();

    final toes = [
      Offset(size.width * 0.25, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.75, size.height * 0.2),
    ];

    for (var toe in toes) {
      paint.color = toe.dx < size.width * 0.5
          ? (modoOscuro ? Colors.white : Colors.black)
          : (modoOscuro ? Colors.black : Colors.white);
      canvas.drawOval(
        Rect.fromCenter(center: toe, width: size.width * 0.15, height: size.height * 0.12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PawPainter oldDelegate) =>
      oldDelegate.modoOscuro != modoOscuro;
}
