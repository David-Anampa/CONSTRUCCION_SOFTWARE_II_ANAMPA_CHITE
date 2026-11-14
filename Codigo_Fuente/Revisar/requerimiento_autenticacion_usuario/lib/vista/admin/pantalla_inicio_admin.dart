import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../servicios/firebase_availability.dart' as fb_avail;

class PantallaInicioAdmin extends StatefulWidget {
  const PantallaInicioAdmin({super.key});

  @override
  State<PantallaInicioAdmin> createState() => _PantallaInicioAdminState();
}

class _PantallaInicioAdminState extends State<PantallaInicioAdmin> {
  bool _modoOscuro = false;
  String _primerNombre = "Admin";
  String? _fotoPerfil;
  bool _datosCargados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosAdmin();
  }

  Future<void> _cargarDatosAdmin() async {
    if (!fb_avail.firebaseAvailable) {
      if (mounted) setState(() => _datosCargados = true);
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data() ?? {};
        final nombreCompleto = data["nombre"] ?? "Admin";
        final palabras = nombreCompleto.toString().trim().split(' ');

        setState(() {
          _primerNombre = palabras.isNotEmpty ? palabras[0] : "Admin";
          _fotoPerfil = data["fotoPerfil"];
          _datosCargados = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _datosCargados = true);
      }
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
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
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/login",
          (_) => false,
        );
      }
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (_fotoPerfil != null && _fotoPerfil!.isNotEmpty)
                  ? (_fotoPerfil!.startsWith("assets/")
                      ? AssetImage(_fotoPerfil!) as ImageProvider
                      : NetworkImage(_fotoPerfil!))
                  : null,
              child: (_fotoPerfil == null || _fotoPerfil!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _datosCargados ? "¡Bienvenido, $_primerNombre!" : "Cargando...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _modoOscuro ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Panel de Administración",
                  style: TextStyle(
                    fontSize: 12,
                    color: _modoOscuro ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
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
              color: _modoOscuro ? Colors.yellow : Colors.orange,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 ESTADÍSTICAS
            _buildStatsSection(),
            
            const SizedBox(height: 24),
            
            // 🎛️ MENU DE ADMINISTRACIÓN
            Text(
              "Gestión Administrativa",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildAdminMenuItem(
              Icons.people,
              "Gestionar Usuarios",
              "Ver y administrar usuarios registrados",
              Colors.blue,
              onTap: () => Navigator.pushNamed(context, "/adminUsuarios"),
            ),
            
            _buildAdminMenuItem(
              Icons.pets,
              "Gestionar Reportes",
              "Ver y moderar reportes de mascotas",
              Colors.orange,
              onTap: () {},
            ),
            
            _buildAdminMenuItem(
              Icons.visibility,
              "Avistamientos",
              "Revisar avistamientos registrados",
              Colors.purple,
              onTap: () {},
            ),
            
            // _buildAdminMenuItem(
            //   Icons.business,
            //   "Colaboradores",
            //   "Gestionar colaboradores del sistema",
            //   Colors.teal,
            //   onTap: () {},
            // ),
            
            _buildAdminMenuItem(
              Icons.analytics,
              "Estadísticas",
              "Ver análisis y reportes",
              Colors.green,
              onTap: () {},
            ),
            
            _buildAdminMenuItem(
              Icons.exit_to_app,
              "Cerrar Sesión",
              "Salir de la cuenta de administrador",
              Colors.red,
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final bool modoPrueba = !fb_avail.firebaseAvailable;

    if (modoPrueba) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(Icons.people, "Usuarios", "0", Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(Icons.pets, "Reportes", "0", Colors.orange),
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('rol', isNotEqualTo: 'admin')
          .snapshots(),
      builder: (context, usuariosSnapshot) {
        final totalUsuarios = usuariosSnapshot.hasData
            ? usuariosSnapshot.data!.docs.length
            : 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reportes_mascotas').snapshots(),
          builder: (context, reportesSnapshot) {
            final totalReportes = reportesSnapshot.hasData
                ? reportesSnapshot.data!.docs.length
                : 0;

            int reportesPerdidos = 0;
            int reportesEncontrados = 0;

            if (reportesSnapshot.hasData) {
              for (var doc in reportesSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final estado = data['estado']?.toString() ?? '';

                if (estado.toLowerCase() == 'perdido') {
                  reportesPerdidos++;
                } else if (estado.toLowerCase() == 'encontrado') {
                  reportesEncontrados++;
                }
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(Icons.people, "Usuarios", "$totalUsuarios", Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.pets, "Reportes", "$totalReportes", Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.search, "Perdidos", "$reportesPerdidos", Colors.red),
                  const SizedBox(width: 12),
                  _buildStatCard(Icons.check_circle, "Encontrados", "$reportesEncontrados", Colors.green),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _modoOscuro ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _modoOscuro ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: _modoOscuro ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: _modoOscuro ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  //             child: Icon(icon, size: 30, color: color),
  //           ),
  //           const SizedBox(height: 12),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 8),
  //             child: Text(
  //               title,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w700,
  //                 color: _modoOscuro ? Colors.white : const Color(0xFF1E293B),
  //                 letterSpacing: 0.2,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}