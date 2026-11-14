import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';
import 'package:sos_mascotas/vista/chat/pantalla_chats_activos.dart';


class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _currentIndex = 0;
  bool _modoOscuro = false;

  // ✅ Guardamos los datos del usuario en variables locales
  String _primerNombre = "Usuario";
  String? _fotoPerfil;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // ✅ Cargamos una sola vez, sin stream
  Future<void> _cargarDatosUsuario() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (!mounted) return; // ✅ Verificar que el widget sigue activo

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final nombreCompleto = data["nombre"] ?? "Usuario";
        final palabras = nombreCompleto.toString().trim().split(' ');

        setState(() {
          _primerNombre = palabras.isNotEmpty ? palabras[0] : "Usuario";
          _fotoPerfil = data["fotoPerfil"];
          _datosCargados = true;
        });
      }
    } catch (e) {
      // Si falla (ej: ya cerró sesión), no hacer nada
      if (mounted) {
        setState(() => _datosCargados = true);
      }
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _modoOscuro
            ? const Color(0xFF2D2D2D)
            : Colors.white,
        title: Text(
          "Cerrar Sesión",
          style: TextStyle(
            color: _modoOscuro ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          "¿Deseas cerrar sesión?",
          style: TextStyle(
            color: _modoOscuro ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Cerrar Sesión"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // ✅ Navegar ANTES de cerrar sesión para evitar que los streams
      // intenten leer Firestore sin permisos
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login",
          (_) => false,
        );
      }
      // ✅ Cerrar sesión DESPUÉS de navegar
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _modoOscuro
          ? const Color(0xFF121212)
          : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        // ✅ Reemplazamos StreamBuilder por variables locales
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/perfil"),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (_fotoPerfil != null &&
                        _fotoPerfil!.isNotEmpty)
                    ? (_fotoPerfil!.startsWith("assets/")
                          ? AssetImage(_fotoPerfil!) as ImageProvider
                          : NetworkImage(_fotoPerfil!))
                    : null,
                child: (_fotoPerfil == null || _fotoPerfil!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.teal)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _datosCargados ? "¡Hola, $_primerNombre!" : "Cargando...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _modoOscuro ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Ayudemos a encontrar mascotas",
                  style: TextStyle(
                    fontSize: 12,
                    color: _modoOscuro
                        ? Colors.grey.shade400
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Consumer<NotificacionVM>(
            builder: (context, vm, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.teal),
                    onPressed: () async {
                      Navigator.pushNamed(context, "/notificaciones");
                      await vm.marcarTodasComoLeidas();
                    },
                  ),
                  if (vm.noLeidas > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${vm.noLeidas}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: TextStyle(
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Buscar mascotas perdidas...",
                hintStyle: TextStyle(
                  color: _modoOscuro ? Colors.grey.shade500 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
                ),
                filled: true,
                fillColor:
                    _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Acciones Rápidas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    Icons.add_circle,
                    "Reportar Mascota",
                    Colors.purple,
                    onTap: () =>
                        Navigator.pushNamed(context, "/reportarMascota"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.visibility,
                    "Registrar Avistamiento",
                    Colors.orange,
                    onTap: () =>
                        Navigator.pushNamed(context, "/avistamiento"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    Icons.map,
                    "Mapa Interactivo",
                    Colors.teal,
                    onTap: () => Navigator.pushNamed(context, "/mapa"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Menú Principal",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              Icons.pets,
              "Ver Mascotas Reportadas",
              "Explora todos los reportes",
              onTap: () => Navigator.pushNamed(context, "/verReportes"),
            ),
            _buildMenuItem(
              Icons.assignment,
              "Mis Reportes",
              "Gestiona tus publicaciones",
              onTap: () => Navigator.pushNamed(context, "/misReportes"),
            ),
            _buildMenuItem(
              Icons.chat,
              "Chats",
              "Conversaciones activas",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PantallaChatsActivos()),
              ),
            ),
            _buildMenuItem(
              Icons.person,
              "Mi Perfil",
              "Configuración de cuenta",
              onTap: () => Navigator.pushNamed(context, "/perfil"),
            ),
            _buildMenuItem(
              Icons.comment,
              "Comentarios",
              "Lee y comparte experiencias",
              onTap: () => Navigator.pushNamed(context, "/comentarios"),
            ),
            _buildMenuItem(
              Icons.exit_to_app,
              "Cerrar Sesión",
              "Salir de tu cuenta actual",
              onTap: _cerrarSesion, // ✅ Función separada y corregida
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor:
            _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            setState(() => _modoOscuro = !_modoOscuro);
            return;
          }
          if (index == 3) {
            Navigator.pushNamed(context, "/mapa");
            return;
          }
          if (index == 4) {
            Navigator.pushNamed(context, "/perfil");
            return;
          }
          setState(() => _currentIndex = index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child:
                  CustomPaint(painter: PawPainter(modoOscuro: _modoOscuro)),
            ),
            label: "Tema",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Reportar",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.map), label: "Mapa"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Card(
      color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _modoOscuro ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class PawPainter extends CustomPainter {
  final bool modoOscuro;
  PawPainter({required this.modoOscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final mainPadPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.7,
          size.width * 0.3, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.3,
          size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.3,
          size.width * 0.7, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.7,
          size.width * 0.5, size.height * 0.9)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * 0.5, size.height));
    paint.color = modoOscuro ? Colors.white : Colors.black;
    canvas.drawPath(mainPadPath, paint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        size.width * 0.5, 0, size.width * 0.5, size.height));
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
        Rect.fromCenter(
            center: toe,
            width: size.width * 0.15,
            height: size.height * 0.12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PawPainter oldDelegate) =>
      oldDelegate.modoOscuro != modoOscuro;
}