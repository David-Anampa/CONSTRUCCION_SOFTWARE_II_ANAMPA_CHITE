import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pantalla_chat.dart';

class PantallaChatsActivos extends StatefulWidget {
  const PantallaChatsActivos({super.key});

  @override
  State<PantallaChatsActivos> createState() => _PantallaChatsActivosState();
}

class _PantallaChatsActivosState extends State<PantallaChatsActivos> {
  final List<String> avataresDefault = [
    'assets/avatars/cat.png',
    'assets/avatars/dog.png',
    'assets/avatars/bear.png',
  ];

  final Map<String, String> avatarAsignado = {};

  String obtenerAvatar(String userId) {
    if (!avatarAsignado.containsKey(userId)) {
      final random = Random();
      avatarAsignado[userId] =
          avataresDefault[random.nextInt(avataresDefault.length)];
    }
    return avatarAsignado[userId]!;
  }

  String _formatearHora(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final ahora = DateTime.now();
    final diff = ahora.difference(dt);

    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    // ✅ Sin orderBy para evitar requerir índice compuesto en arrayContains + orderBy.
    // Ordenamos client-side.
    final chatsRef = FirebaseFirestore.instance
        .collection('chats')
        .where('usuarios', arrayContains: currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Chats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Error al cargar chats',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifica tu conexión e intenta de nuevo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ordenar client-side por fechaInicio descendente
          final chats = (snapshot.data?.docs ?? [])..sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final tsA = dataA['fechaInicio'] as Timestamp?;
            final tsB = dataB['fechaInicio'] as Timestamp?;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          if (chats.isEmpty) {
            return _buildEstadoVacio();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final chat = chats[i];
              final data = chat.data() as Map<String, dynamic>;

              final isPublicador = data['publicadorId'] == currentUser.uid;
              final otherUserId =
                  isPublicador ? data['usuarioId'] : data['publicadorId'];
              final tipo = data['tipo'] ?? 'reporte';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox(height: 80);
                  }

                  final userData =
                      userSnap.data!.data() as Map<String, dynamic>? ?? {};
                  final nombre = userData['nombre'] ?? 'Usuario';
                  final fotoPerfil = userData['fotoPerfil'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chat.id)
                        .collection('mensajes')
                        .orderBy('fechaEnvio', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, msgSnap) {
                      String ultimoMensaje = '';
                      Timestamp? fechaUltimo;
                      bool hayMensaje = false;

                      if (msgSnap.hasData && msgSnap.data!.docs.isNotEmpty) {
                        final msg = msgSnap.data!.docs.first.data()
                            as Map<String, dynamic>;
                        ultimoMensaje = msg['texto'] ?? '';
                        fechaUltimo = msg['fechaEnvio'] as Timestamp?;
                        hayMensaje = true;
                      }

                      // Contar mensajes no leídos del otro usuario
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chat.id)
                            .collection('mensajes')
                            .where('emisorId', isEqualTo: otherUserId)
                            .where('leido', isEqualTo: false)
                            .snapshots(),
                        builder: (context, unreadSnap) {
                          final noLeidos =
                              unreadSnap.data?.docs.length ?? 0;

                          return _buildChatTile(
                            context: context,
                            chatId: chat.id,
                            data: data,
                            nombre: nombre,
                            fotoPerfil: fotoPerfil,
                            otherUserId: otherUserId,
                            tipo: tipo,
                            ultimoMensaje: ultimoMensaje,
                            fechaUltimo: fechaUltimo,
                            hayMensaje: hayMensaje,
                            noLeidos: noLeidos,
                            currentUid: currentUser.uid,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String chatId,
    required Map<String, dynamic> data,
    required String nombre,
    required dynamic fotoPerfil,
    required String otherUserId,
    required String tipo,
    required String ultimoMensaje,
    required Timestamp? fechaUltimo,
    required bool hayMensaje,
    required int noLeidos,
    required String currentUid,
  }) {
    ImageProvider? avatarImage;
    if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
      avatarImage = NetworkImage(fotoPerfil);
    } else {
      avatarImage = AssetImage(obtenerAvatar(otherUserId));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.teal.shade100,
              backgroundImage: avatarImage,
            ),
            // Badge de tipo (reporte / avistamiento)
            Positioned(
              bottom: -2,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: tipo == 'reporte' ? Colors.purple : Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  tipo == 'reporte' ? Icons.pets : Icons.visibility,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          nombre,
          style: TextStyle(
            fontWeight: noLeidos > 0 ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          hayMensaje
              ? ultimoMensaje
              : 'Chat sobre ${tipo == "reporte" ? "reporte" : "avistamiento"}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: noLeidos > 0 ? Colors.black87 : Colors.grey,
            fontWeight:
                noLeidos > 0 ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatearHora(fechaUltimo),
              style: TextStyle(
                fontSize: 12,
                color: noLeidos > 0 ? Colors.teal : Colors.grey,
                fontWeight:
                    noLeidos > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (noLeidos > 0) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$noLeidos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaChat(
              chatId: chatId,
              reporteId: data['reporteId'],
              tipo: tipo,
              publicadorId: data['publicadorId'],
              usuarioId: data['usuarioId'],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 56,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin conversaciones aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Cuando contactes al dueño de una mascota,\nla conversación aparecerá aquí',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
