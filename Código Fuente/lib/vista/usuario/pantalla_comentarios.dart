import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'replies_page.dart';

class PantallaComentarios extends StatefulWidget {
  const PantallaComentarios({super.key});

  @override
  State<PantallaComentarios> createState() => _PantallaComentariosState();
}

class _PantallaComentariosState extends State<PantallaComentarios> {
  final TextEditingController _ctrl = TextEditingController();
  final CollectionReference _comentariosRef = FirebaseFirestore.instance
      .collection('comentarios');
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  XFile? _media;
  String? _mediaPreviewPath;
  bool _enviando = false;

  String _filtro = 'todos';
  String _filtroTiempo = 'todos';
  DateTime? _fechaSeleccionada;
  Set<String> _guardados = {};

  @override
  void initState() {
    super.initState();
    _cargarGuardados();
  }

  Future<void> _cargarGuardados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists && doc.data()!['guardados'] != null) {
      setState(() {
        _guardados = Set<String>.from(doc.data()!['guardados']);
      });
    }
  }

  Future<void> _guardarPersistente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
      'guardados': _guardados.toList(),
    }, SetOptions(merge: true));
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (picked != null) {
        setState(() {
          _media = picked;
          _mediaPreviewPath = picked.path;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<Map<String, String>> _uploadMedia(XFile file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance
        .ref()
        .child('comentarios')
        .child('$uid-${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(File(file.path));
    final url = await ref.getDownloadURL();
    return {'url': url, 'type': 'image'};
  }

  Future<void> _eliminarComentario(String docId, String? mediaUrl) async {
    try {
      final replies = await _comentariosRef
          .doc(docId)
          .collection('respuestas')
          .get();
      for (var doc in replies.docs) {
        await doc.reference.delete();
      }

      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          final ref = await FirebaseStorage.instance.refFromURL(mediaUrl);
          await ref.delete();
        } catch (_) {}
      }

      await _comentariosRef.doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comentario eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty && _media == null) return;
    setState(() => _enviando = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      String autor = 'Anónimo';
      String? fotoPerfil;
      if (docUsuario.exists) {
        final data = docUsuario.data()!;
        autor = "${data['nombre'] ?? ''} ${data['apellido'] ?? ''}".trim();
        fotoPerfil = data['fotoPerfil'];
      }

      String? mediaUrl;
      String? mediaType;
      if (_media != null) {
        final upload = await _uploadMedia(_media!);
        mediaUrl = upload['url'];
        mediaType = upload['type'];
      }

      await _comentariosRef.add({
        'texto': texto,
        'autor': autor,
        'fotoPerfil': fotoPerfil,
        'uid': user.uid,
        'fecha': FieldValue.serverTimestamp(),
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'likes': <String>[],
        'dislikes': <String>[],
        'shares': 0,
      });

      _ctrl.clear();
      setState(() {
        _media = null;
        _mediaPreviewPath = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comentario enviado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _enviando = false);
    }
  }

  Future<void> _toggleReaction(String docId, bool isLike) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final docRef = _comentariosRef.doc(docId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final List likes = List.from(data['likes'] ?? []);
      if (isLike) {
        if (likes.contains(uid)) {
          tx.update(docRef, {
            'likes': FieldValue.arrayRemove([uid]),
          });
        } else {
          tx.update(docRef, {
            'likes': FieldValue.arrayUnion([uid]),
          });
        }
      }
    });
  }

  bool _filtrarPorFecha(DateTime? fecha) {
    if (fecha == null) return true;
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final diff = hoy.difference(dia).inDays;
    switch (_filtroTiempo) {
      case 'hoy':
        return diff == 0;
      case 'ayer':
        return diff == 1;
      case 'anteayer':
        return diff == 2;
      case 'fecha':
        if (_fechaSeleccionada == null) return true;
        final sel = DateTime(
          _fechaSeleccionada!.year,
          _fechaSeleccionada!.month,
          _fechaSeleccionada!.day,
        );
        return sel == dia;
      default:
        return true;
    }
  }

  // 🆕 Método para obtener mis respuestas
  Future<List<Map<String, dynamic>>> _obtenerMisRespuestas() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    List<Map<String, dynamic>> misRespuestas = [];

    // Obtener todos los comentarios
    final todosComentarios = await _comentariosRef.get();

    for (var comentario in todosComentarios.docs) {
      // Obtener respuestas de cada comentario
      final respuestas = await _comentariosRef
          .doc(comentario.id)
          .collection('respuestas')
          .where('uid', isEqualTo: user.uid)
          .get();

      for (var respuesta in respuestas.docs) {
        final respuestaData = respuesta.data();
        final comentarioData = comentario.data() as Map<String, dynamic>;

        misRespuestas.add({
          'id': respuesta.id,
          'parentId': comentario.id,
          'texto': respuestaData['texto'] ?? '',
          'autor': respuestaData['autor'] ?? 'Anónimo',
          'fotoPerfil': respuestaData['fotoPerfil'],
          'fecha': respuestaData['fecha'],
          'mediaUrl': respuestaData['mediaUrl'],
          'mediaType': respuestaData['mediaType'],
          'likes': respuestaData['likes'] ?? [],
          'uid': respuestaData['uid'],
          'parentAutor': comentarioData['autor'] ?? 'Anónimo',
          'esRespuesta': true,
        });
      }
    }

    // Ordenar por fecha descendente
    misRespuestas.sort((a, b) {
      final fechaA = (a['fecha'] as Timestamp?)?.toDate() ?? DateTime(2000);
      final fechaB = (b['fecha'] as Timestamp?)?.toDate() ?? DateTime(2000);
      return fechaB.compareTo(fechaA);
    });

    return misRespuestas;
  }

  List<QueryDocumentSnapshot> _aplicarFiltro(List<QueryDocumentSnapshot> docs) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return docs;
    return docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      final fecha = (data['fecha'] as Timestamp?)?.toDate();
      if (!_filtrarPorFecha(fecha)) return false;
      switch (_filtro) {
        case 'likes':
          return List.from(data['likes'] ?? []).contains(user.uid);
        case 'comentados':
          return data['uid'] == user.uid;
        case 'compartidos':
          return (data['shares'] ?? 0) > 0;
        case 'guardados':
          return _guardados.contains(d.id);
        default:
          return true;
      }
    }).toList();
  }

  Widget _chip(String valor, IconData icon, String texto) {
    final activo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selectedColor: Colors.teal.shade100,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 4),
            Text(texto),
          ],
        ),
        selected: activo,
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 🔹 Filtros
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _filtroTiempo,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'hoy', child: Text('Hoy')),
                    DropdownMenuItem(value: 'ayer', child: Text('Ayer')),
                    DropdownMenuItem(
                      value: 'anteayer',
                      child: Text('Anteayer'),
                    ),
                    DropdownMenuItem(
                      value: 'fecha',
                      child: Text('Elegir otra fecha'),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == 'fecha') {
                      final f = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (f != null) {
                        setState(() {
                          _filtroTiempo = 'fecha';
                          _fechaSeleccionada = f;
                        });
                      }
                    } else if (v != null) {
                      setState(() => _filtroTiempo = v);
                    }
                  },
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip('todos', Icons.all_inclusive, 'Todos'),
                      _chip('likes', Icons.favorite, 'Likes'),
                      _chip('comentados', Icons.comment, 'Mis comentarios'),
                      _chip(
                        'respuestas',
                        Icons.reply,
                        'Mis respuestas',
                      ), // 🆕 Nuevo chip
                      _chip('compartidos', Icons.share, 'Compartidos'),
                      _chip('guardados', Icons.bookmark, 'Guardados'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Lista de comentarios o respuestas
          Expanded(
            child: _filtro == 'respuestas'
                ? FutureBuilder<List<Map<String, dynamic>>>(
                    future: _obtenerMisRespuestas(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No has respondido a ningún comentario.'),
                        );
                      }

                      final respuestas = snapshot.data!;
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: respuestas.length,
                        itemBuilder: (context, i) {
                          final resp = respuestas[i];
                          return RespuestaTile(
                            respuestaId: resp['id'],
                            parentId: resp['parentId'],
                            texto: resp['texto'],
                            autor: resp['autor'],
                            fotoPerfil: resp['fotoPerfil'],
                            fecha: (resp['fecha'] as Timestamp?)?.toDate(),
                            mediaUrl: resp['mediaUrl'],
                            mediaType: resp['mediaType'],
                            likes: List<String>.from(resp['likes'] ?? []),
                            parentAutor: resp['parentAutor'],
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    // ✅ Sin orderBy para evitar requerir índice compuesto.
                    // Ordenamos client-side.
                    stream: _comentariosRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        final err = snapshot.error.toString();
                        final esPermisos =
                            err.contains('PERMISSION_DENIED') ||
                            err.contains('permission-denied');
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  esPermisos
                                      ? Icons.lock_outline
                                      : Icons.cloud_off,
                                  color: Colors.orange,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  esPermisos
                                      ? 'Sin permisos para leer comentarios'
                                      : 'Error al cargar comentarios',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Verifica tu conexión e intenta de nuevo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Ordenar client-side por fecha descendente
                      final allDocs = snapshot.data!.docs.toList()
                        ..sort((a, b) {
                          final ta =
                              (a.data() as Map<String, dynamic>)['fecha']
                                  as Timestamp?;
                          final tb =
                              (b.data() as Map<String, dynamic>)['fecha']
                                  as Timestamp?;
                          if (ta == null && tb == null) return 0;
                          if (ta == null) return 1;
                          if (tb == null) return -1;
                          return tb.compareTo(ta);
                        });
                      final docs = _aplicarFiltro(allDocs);
                      if (docs.isEmpty) {
                        return const Center(child: Text('Sin resultados.'));
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final data = d.data() as Map<String, dynamic>;
                          final esMio = data['uid'] == user?.uid;
                          return CommentTile(
                            docId: d.id,
                            texto: data['texto'] ?? '',
                            autor: data['autor'] ?? 'Anónimo',
                            fotoPerfil: data['fotoPerfil'],
                            fecha: (data['fecha'] as Timestamp?)?.toDate(),
                            mediaUrl: data['mediaUrl'],
                            mediaType: data['mediaType'],
                            likes: List<String>.from(data['likes'] ?? []),
                            dislikes: List<String>.from(data['dislikes'] ?? []),
                            shares: data['shares'] ?? 0,
                            onLike: () => _toggleReaction(d.id, true),
                            onComment: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RepliesPage(
                                  parentCommentId: d.id,
                                  parentAuthor: data['autor'],
                                ),
                              ),
                            ),
                            onShare: () async {
                              await Share.share(data['texto'] ?? '');
                              _comentariosRef.doc(d.id).update({
                                'shares': FieldValue.increment(1),
                              });
                            },
                            onGuardar: () {
                              setState(() {
                                if (_guardados.contains(d.id)) {
                                  _guardados.remove(d.id);
                                } else {
                                  _guardados.add(d.id);
                                }
                                _guardarPersistente();
                              });
                            },
                            guardado: _guardados.contains(d.id),
                            esMio: esMio,
                            onEliminar: () =>
                                _eliminarComentario(d.id, data['mediaUrl']),
                          );
                        },
                      );
                    },
                  ),
          ),

          // 🔹 Barra inferior (comentar) - SOLO SI NO ESTÁ EN "RESPUESTAS"
          if (_filtro != 'respuestas')
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, color: Colors.teal),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _ctrl,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Escribe un comentario...',
                              border: InputBorder.none,
                            ),
                          ),
                          if (_mediaPreviewPath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Image.file(
                                File(_mediaPreviewPath!),
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _enviando
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.teal),
                            onPressed: _enviarComentario,
                          ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* -------------------- CommentTile -------------------- */
class CommentTile extends StatelessWidget {
  final String docId;
  final String texto;
  final String autor;
  final String? fotoPerfil;
  final DateTime? fecha;
  final String? mediaUrl;
  final String? mediaType;
  final List<String> likes;
  final List<String> dislikes;
  final int shares;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final Future<void> Function()? onShare;
  final VoidCallback onGuardar;
  final bool guardado;
  final bool esMio;
  final VoidCallback onEliminar;

  const CommentTile({
    super.key,
    required this.docId,
    required this.texto,
    required this.autor,
    this.fotoPerfil,
    required this.fecha,
    this.mediaUrl,
    this.mediaType,
    required this.likes,
    required this.dislikes,
    required this.shares,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onGuardar,
    required this.guardado,
    required this.esMio,
    required this.onEliminar,
  });

  String _fechaBonita(DateTime? fecha) {
    if (fecha == null) return '';
    final hoy = DateTime.now();
    final diff = hoy
        .difference(DateTime(fecha.year, fecha.month, fecha.day))
        .inDays;
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Hoy $hora';
    if (diff == 1) return 'Ayer $hora';
    if (diff == 2) return 'Anteayer $hora';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasLiked =
        FirebaseAuth.instance.currentUser != null &&
        likes.contains(FirebaseAuth.instance.currentUser!.uid);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (fotoPerfil != null && fotoPerfil!.isNotEmpty)
                      ? NetworkImage(fotoPerfil!)
                      : null,
                  backgroundColor: Colors.teal,
                  child: (fotoPerfil == null || fotoPerfil!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    autor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (fecha != null)
                  Text(
                    _fechaBonita(fecha),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                if (esMio)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      if (v == 'eliminar') onEliminar();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
              ],
            ),
            if (texto.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(texto, style: const TextStyle(fontSize: 14)),
            ],
            if (mediaUrl != null && mediaType == 'image') ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(mediaUrl!, height: 180, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 6),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comentarios')
                  .doc(docId)
                  .collection('respuestas')
                  .snapshots(),
              builder: (context, snap) {
                final repliesCount = snap.data?.docs.length ?? 0;
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        hasLiked ? Icons.favorite : Icons.favorite_border,
                        color: hasLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: onLike,
                    ),
                    Text('${likes.length}'),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.comment,
                        color: Colors.lightBlueAccent,
                      ),
                      onPressed: onComment,
                    ),
                    Text('$repliesCount'),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.green),
                      onPressed: onShare,
                    ),
                    Text('$shares'),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        guardado ? Icons.bookmark : Icons.bookmark_border,
                        color: guardado ? Colors.amber : Colors.grey,
                      ),
                      onPressed: onGuardar,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- 🆕 RespuestaTile (SOLO VISTA) -------------------- */
class RespuestaTile extends StatelessWidget {
  final String respuestaId;
  final String parentId;
  final String texto;
  final String autor;
  final String? fotoPerfil;
  final DateTime? fecha;
  final String? mediaUrl;
  final String? mediaType;
  final List<String> likes;
  final String parentAutor;

  const RespuestaTile({
    super.key,
    required this.respuestaId,
    required this.parentId,
    required this.texto,
    required this.autor,
    this.fotoPerfil,
    required this.fecha,
    this.mediaUrl,
    this.mediaType,
    required this.likes,
    required this.parentAutor,
  });

  String _fechaBonita(DateTime? fecha) {
    if (fecha == null) return '';
    final hoy = DateTime.now();
    final diff = hoy
        .difference(DateTime(fecha.year, fecha.month, fecha.day))
        .inDays;
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Hoy $hora';
    if (diff == 1) return 'Ayer $hora';
    if (diff == 2) return 'Anteayer $hora';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasLiked =
        FirebaseAuth.instance.currentUser != null &&
        likes.contains(FirebaseAuth.instance.currentUser!.uid);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de que es una respuesta
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.reply, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Respondiste a $parentAutor',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      (fotoPerfil != null && fotoPerfil!.isNotEmpty)
                      ? NetworkImage(fotoPerfil!)
                      : null,
                  backgroundColor: Colors.teal,
                  child: (fotoPerfil == null || fotoPerfil!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    autor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (fecha != null)
                  Text(
                    _fechaBonita(fecha),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            if (texto.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(texto, style: const TextStyle(fontSize: 14)),
            ],
            if (mediaUrl != null && mediaType == 'image') ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(mediaUrl!, height: 180, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  hasLiked ? Icons.favorite : Icons.favorite_border,
                  color: hasLiked ? Colors.red : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('${likes.length}'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RepliesPage(
                          parentCommentId: parentId,
                          parentAuthor: parentAutor,
                        ),
                      ),
                    );
                  },
                  child: const Text('Ver POST'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
