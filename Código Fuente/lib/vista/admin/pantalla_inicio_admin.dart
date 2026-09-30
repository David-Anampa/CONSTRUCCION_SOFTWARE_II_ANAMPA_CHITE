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
      backgroundColor: _modoOscuro ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: _modoOscuro ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.admin_panel_settings,
                color: _modoOscuro ? Colors.white : Colors.red,
                size: 24,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _modoOscuro ? Colors.white : Colors.black,
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
              color: _modoOscuro ? Colors.white : Colors.grey[700],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
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

            const SizedBox(height: 24),
            Text(
              "Gestión Administrativa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _modoOscuro ? Colors.white : Colors.black,
              ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _modoOscuro ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _modoOscuro ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: _modoOscuro ? Colors.grey[400] : Colors.grey,
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
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}