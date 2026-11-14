import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'pantalla_adminusuarios.dart';
import 'pantalla_perfil_admin.dart';
import 'pantallaAdminReporte.dart';
import 'PantallaAdminEstadisticas.dart';
import 'PantallaAdminNotificaciones.dart';
import '../../vistamodelo/admin/AdminNotificaciones_vm.dart';

class PantallaInicioAdmin extends StatefulWidget {
  const PantallaInicioAdmin({super.key});

  @override
  State<PantallaInicioAdmin> createState() => _PantallaInicioAdminState();
}

class _PantallaInicioAdminState extends State<PantallaInicioAdmin> {
  bool _modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _modoOscuro ? const Color(0xFF0F172A) : const Color(0xFFF1F5FB),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E293B) : const Color(0xFF1E3A5F),
        elevation: 0,
        toolbarHeight: 72,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                String textoAdmin = "Bienvenido Admin";
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final nombre = data['nombre'] ?? '';
                  
                  // Solo tomar el primer nombre
                  if (nombre.isNotEmpty) {
                    String primerNombre = nombre.split(' ').first;
                    textoAdmin = 'Bienvenido Admin: $primerNombre';
                  }
                }
                return Text(
                  textoAdmin,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                );
              },
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
              color: Colors.white70,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
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

                    // Contar reportes por estado
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

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('avistamientos').snapshots(),
                      builder: (context, avistamientosSnapshot) {
                        final totalAvistamientos = avistamientosSnapshot.hasData
                            ? avistamientosSnapshot.data!.docs.length
                            : 0;

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('colaboradores').snapshots(),
                          builder: (context, colaboradoresSnapshot) {
                            final totalColaboradores = (colaboradoresSnapshot.hasData
                                    ? colaboradoresSnapshot.data!.docs.length
                                    : 0) + 2;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.people, "Usuarios", "$totalUsuarios", Colors.blue),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.pets, "Reportes", "$totalReportes", Colors.orange),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.visibility, "Avistamientos", "$totalAvistamientos", Colors.purple),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.business, "Colaboradores", "$totalColaboradores", Colors.teal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.search,
                                          "Perdidos",
                                          "$reportesPerdidos",
                                          Colors.red),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                          Icons.check_circle, "Encontrados", "$reportesEncontrados", Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 28),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Gestión Administrativa",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _modoOscuro ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard(Icons.people_alt, "Gestionar\nUsuarios", Colors.blue, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaAdminUsuarios(),
                    ),
                  );
                }),
                _buildMenuCard(Icons.report, "Gestionar\nReportes", Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaAdminReporte(),
                    ),
                  );
                }),
                _buildMenuCard(Icons.notifications, "Enviar\nNotificaciones", Colors.purple, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        create: (_) => AdminNotificacionesVM(),
                        child: const PantallaAdminNotificaciones(),
                      ),
                    ),
                  );
                }),
                _buildMenuCard(Icons.analytics, "Estadísticas\nAvanzadas", Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaAdminEstadisticas(),
                    ),
                  );
                }),

                _buildMenuCard(Icons.person, "Ver Perfil", Colors.grey, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaPerfilAdmin(),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF1E293B) : Colors.white,
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

  Widget _buildMenuCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _modoOscuro ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _modoOscuro ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}