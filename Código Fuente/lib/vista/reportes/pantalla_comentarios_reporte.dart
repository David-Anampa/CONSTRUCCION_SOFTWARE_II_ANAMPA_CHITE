import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../servicios/notificacion_servicio.dart';

/// Pantalla de comentarios asociados a un reporte o avistamiento específico.
/// Los comentarios se guardan en Firestore en:
///   reportes_mascotas/{reporteId}/comentarios  (tipo == 'reporte')
///   avistamientos/{reporteId}/comentarios      (tipo == 'avistamiento')
class PantallaComentariosReporte extends StatefulWidget {
  final String reporteId;
  final String tipo; // 'reporte' | 'avistamiento'
  final String tituloReporte; // nombre de la mascota o descripción

  const PantallaComentariosReporte({
    super.key,
    required this.reporteId,
    required this.tipo,
    required this.tituloReporte,
  });

  @override
  State<PantallaComentariosReporte> createState() =>
      _PantallaComentariosReporteState();
}

class _PantallaComentariosReporteState
    extends State<PantallaComentariosReporte> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  XFile? _imagenSeleccionada;
  bool _enviando = false;
  String? _respondiendo; // ID del comentario al que se responde
  String? _respondiendoAutor;

  CollectionReference get _comentariosRef {
    final colPadre =
        widget.tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';
    return FirebaseFirestore.instance
        .collection(colPadre)
        .doc(widget.reporteId)
        .collection('comentarios');
  }

  // ─────────────────────────────────────────────
  // Seleccionar imagen de galería
  // ─────────────────────────────────────────────
  Future<void> _seleccionarImagen() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imagenSeleccionada = picked);
    }
  }

  // ─────────────────────────────────────────────
  // Subir imagen a Firebase Storage
  // ─────────────────────────────────────────────
  Future<String?> _subirImagen(XFile file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      final ext = file.path.split('.').last;
      final ref = FirebaseStorage.instance
          .ref()
          .child('comentarios_reportes')
          .child('$uid-${DateTime.now().millisecondsSinceEpoch}.$ext');
      await ref.putFile(File(file.path));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Enviar comentario (o respuesta)
  // ─────────────────────────────────────────────
  Future<void> _enviarComentario() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty && _imagenSeleccionada == null) return;

    setState(() => _enviando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Obtener datos del usuario
      final docUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      String autor = 'Anónimo';
      String? fotoPerfil;
      if (docUsuario.exists) {
        final data = docUsuario.data()!;
        autor = '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'.trim();
        if (autor.isEmpty) autor = data['nombre'] ?? 'Anónimo';
        fotoPerfil = data['fotoPerfil'];
      }

      // Subir imagen si hay una
      String? imagenUrl;
      if (_imagenSeleccionada != null) {
        imagenUrl = await _subirImagen(_imagenSeleccionada!);
      }

      final Map<String, dynamic> payload = {
        'texto': texto,
        'autor': autor,
        'fotoPerfil': fotoPerfil,
        'uid': user.uid,
        'fecha': FieldValue.serverTimestamp(),
        'imagenUrl': imagenUrl,
        'likes': <String>[],
      };

      if (_respondiendo != null) {
        // Es una respuesta a un comentario existente
        payload['esRespuesta'] = true;
        payload['respondiendoA'] = _respondiendo;
        payload['respondiendoAAutor'] = _respondiendoAutor;
      }

      await _comentariosRef.add(payload);

      // 🔔 Notificar al creador de la publicación
      try {
        final colPadre = widget.tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';
        final docPost = await FirebaseFirestore.instance.collection(colPadre).doc(widget.reporteId).get();
        if (docPost.exists) {
          final postData = docPost.data();
          final postOwnerId = postData?['usuarioId'];
          final postNombre = postData?['nombre'] ?? postData?['direccion'] ?? 'Publicación';

          if (postOwnerId != null && postOwnerId != user.uid) {
            // Obtener token del dueño
            final docOwner = await FirebaseFirestore.instance.collection('usuarios').doc(postOwnerId).get();
            final token = (docOwner.data()?['token'] ?? docOwner.data()?['fcmToken'] ?? '').toString();

            final titulo = widget.tipo == 'reporte'
                ? 'Nuevo comentario sobre $postNombre'
                : 'Nuevo comentario en tu avistamiento';
            final cuerpo = texto.isNotEmpty ? '$autor: $texto' : '$autor adjuntó una imagen';

            await NotificacionServicio.enviarPushAUsuario(
              token: token,
              titulo: titulo,
              cuerpo: cuerpo,
              usuarioId: postOwnerId,
              tipo: widget.tipo,
            );
          }
        }
      } catch (ne) {
        debugPrint("Error al enviar notificación de comentario: $ne");
      }

      _ctrl.clear();
      setState(() {
        _imagenSeleccionada = null;
        _respondiendo = null;
        _respondiendoAutor = null;
      });

      // Scroll hacia arriba (lista invertida)
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      setState(() => _enviando = false);
    }
  }

  // ─────────────────────────────────────────────
  // Dar / quitar like
  // ─────────────────────────────────────────────
  Future<void> _toggleLike(String docId, List<String> likes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _comentariosRef.doc(docId);
    if (likes.contains(uid)) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  // ─────────────────────────────────────────────
  // Eliminar comentario propio
  // ─────────────────────────────────────────────
  Future<void> _eliminarComentario(String docId, String? imagenUrl) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Seguro que deseas eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      if (imagenUrl != null && imagenUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imagenUrl).delete();
        } catch (_) {}
      }
      await _comentariosRef.doc(docId).delete();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  String _fechaBonita(DateTime? fecha) {
    if (fecha == null) return '';
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer $hora';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comentarios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.tituloReporte,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Lista de comentarios ───
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _comentariosRef
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEstadoVacio();
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final likes = List<String>.from(data['likes'] ?? []);
                    final esMio = data['uid'] == uid;
                    final hasLiked = uid != null && likes.contains(uid);
                    final fecha =
                        (data['fecha'] as Timestamp?)?.toDate();
                    final esRespuesta = data['esRespuesta'] == true;

                    return _buildComentarioCard(
                      docId: doc.id,
                      data: data,
                      likes: likes,
                      esMio: esMio,
                      hasLiked: hasLiked,
                      fecha: fecha,
                      esRespuesta: esRespuesta,
                    );
                  },
                );
              },
            ),
          ),

          // ─── Barra de escritura ───
          _buildBarraEscritura(),
        ],
      ),
    );
  }

  Widget _buildComentarioCard({
    required String docId,
    required Map<String, dynamic> data,
    required List<String> likes,
    required bool esMio,
    required bool hasLiked,
    required DateTime? fecha,
    required bool esRespuesta,
  }) {
    final foto = data['fotoPerfil'];
    final autor = data['autor'] ?? 'Anónimo';
    final texto = data['texto'] ?? '';
    final imagenUrl = data['imagenUrl'] as String?;
    final respondiendoAAutor = data['respondiendoAAutor'] as String?;

    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        left: esRespuesta ? 32 : 0, // sangría para respuestas
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: esRespuesta
            ? Border(
                left: BorderSide(color: Colors.teal.shade300, width: 3),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de respuesta
            if (esRespuesta && respondiendoAAutor != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.reply, size: 14, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      'Responde a $respondiendoAAutor',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.teal),
                    ),
                  ],
                ),
              ),

            // Cabecera: avatar + nombre + fecha + menú
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: (foto != null && foto.isNotEmpty)
                      ? NetworkImage(foto)
                      : null,
                  child: (foto == null || foto.isEmpty)
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        autor,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _fechaBonita(fecha),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (esMio)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.grey, size: 20),
                    onSelected: (v) {
                      if (v == 'eliminar') {
                        _eliminarComentario(docId, data['imagenUrl']);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Texto
            if (texto.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                texto,
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87, height: 1.4),
              ),
            ],

            // Imagen adjunta
            if (imagenUrl != null && imagenUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagenUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ],

            // Acciones: like + responder
            const SizedBox(height: 8),
            Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () => _toggleLike(docId, likes),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          hasLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(hasLiked),
                          color:
                              hasLiked ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${likes.length}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Responder
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _respondiendo = docId;
                      _respondiendoAutor = autor;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                    Future.delayed(
                        const Duration(milliseconds: 100),
                        () => FocusScope.of(context)
                            .requestFocus(FocusNode()));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.reply,
                          color: Colors.teal.shade400, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Responder',
                        style: TextStyle(
                            fontSize: 13, color: Colors.teal.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraEscritura() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de "respondiendo a..."
            if (_respondiendo != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: Colors.teal.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Respondiendo a $_respondiendoAutor',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.teal),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _respondiendo = null;
                        _respondiendoAutor = null;
                      }),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // Vista previa imagen
            if (_imagenSeleccionada != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_imagenSeleccionada!.path),
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _imagenSeleccionada = null),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Campo de texto + botones
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_outlined,
                        color: Colors.teal),
                    onPressed: _seleccionarImagen,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 2),
                      child: TextField(
                        controller: _ctrl,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un comentario...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enviando ? null : _enviarComentario,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _enviando ? Colors.grey : Colors.teal,
                        shape: BoxShape.circle,
                      ),
                      child: _enviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 46,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin comentarios aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡Sé el primero en comentar\nsobre este reporte!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
