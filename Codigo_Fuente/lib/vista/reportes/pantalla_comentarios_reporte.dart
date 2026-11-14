import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../servicios/notificacion_servicio.dart';
import '../../utils/fecha_utils.dart';

/// Pantalla de comentarios asociados a un reporte o avistamiento específico.
///
/// Los comentarios se almacenan en Firestore como subcolección bajo:
/// - `reportes_mascotas/{reporteId}/comentarios`  (cuando [tipo] == `'reporte'`)
/// - `avistamientos/{reporteId}/comentarios`       (cuando [tipo] == `'avistamiento'`)
///
/// Soporta: envío de texto + imagen, respuestas anidadas, likes y eliminación.
class PantallaComentariosReporte extends StatefulWidget {
  /// ID del documento padre (reporte o avistamiento) en Firestore.
  final String reporteId;

  /// Tipo de publicación: `'reporte'` o `'avistamiento'`.
  final String tipo;

  /// Nombre o descripción corta de la publicación (se muestra en el AppBar).
  final String tituloReporte;

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

  // ─── Constantes de configuración ─────────────────────────────────────────

  /// Ancho máximo en píxeles al que se redimensiona la imagen seleccionada.
  static const int _anchoMaximoImagenPx = 1200;

  /// Calidad JPEG (0–100) aplicada al comprimir la imagen antes de subirla.
  static const int _calidadImagenJpeg = 80;

  // ─── Estado ──────────────────────────────────────────────────────────────

  final TextEditingController _controladorTexto = TextEditingController();
  final ScrollController _controladorScroll = ScrollController();
  final ImagePicker _selectorImagen = ImagePicker();

  XFile? _imagenSeleccionada;
  bool _enviando = false;
  String? _idComentarioRespondido;
  String? _autorComentarioRespondido;

  // ─── Referencia Firestore ─────────────────────────────────────────────────

  /// Nombre de la colección padre según el [tipo] de publicación.
  String get _coleccionPadre =>
      widget.tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';

  /// Referencia a la subcolección de comentarios del documento padre.
  CollectionReference get _comentariosRef =>
      FirebaseFirestore.instance
          .collection(_coleccionPadre)
          .doc(widget.reporteId)
          .collection('comentarios');

  // ─── Selección y subida de imagen ────────────────────────────────────────

  /// Abre la galería y almacena la imagen seleccionada en [_imagenSeleccionada].
  Future<void> _seleccionarImagen() async {
    final imagenElegida = await _selectorImagen.pickImage(
      source: ImageSource.gallery,
      maxWidth: _anchoMaximoImagenPx.toDouble(),
      imageQuality: _calidadImagenJpeg,
    );
    if (imagenElegida != null) {
      setState(() => _imagenSeleccionada = imagenElegida);
    }
  }

  /// Sube [archivoImagen] a Firebase Storage bajo `comentarios_reportes/`.
  ///
  /// Retorna la URL de descarga, o `null` si la subida falla.
  Future<String?> _subirImagen(XFile archivoImagen) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
      final extension = archivoImagen.path.split('.').last;
      final referenciaStorage = FirebaseStorage.instance
          .ref()
          .child('comentarios_reportes')
          .child('$uid-${DateTime.now().millisecondsSinceEpoch}.$extension');

      await referenciaStorage.putFile(File(archivoImagen.path));
      return await referenciaStorage.getDownloadURL();
    } catch (error) {
      debugPrint('Error subiendo imagen de comentario: $error');
      return null;
    }
  }

  // ─── Envío de comentario ──────────────────────────────────────────────────

  /// Envía un comentario (o respuesta) con texto e imagen opcional.
  ///
  /// Notifica al dueño de la publicación si no es el mismo usuario.
  Future<void> _enviarComentario() async {
    final textoLimpio = _controladorTexto.text.trim();
    if (textoLimpio.isEmpty && _imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario o adjunta una imagen.'),
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final usuarioActual = FirebaseAuth.instance.currentUser;
      if (usuarioActual == null) return;

      final documentoUsuario = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioActual.uid)
          .get();

      String nombreAutor = 'Anónimo';
      String? urlFotoPerfil;
      if (documentoUsuario.exists) {
        final datosUsuario = documentoUsuario.data()!;
        final nombreCompleto =
            '${datosUsuario['nombre'] ?? ''} ${datosUsuario['apellido'] ?? ''}'
                .trim();
        nombreAutor = nombreCompleto.isNotEmpty
            ? nombreCompleto
            : datosUsuario['nombre'] ?? 'Anónimo';
        urlFotoPerfil = datosUsuario['fotoPerfil'];
      }

      String? urlImagenAdjunta;
      if (_imagenSeleccionada != null) {
        urlImagenAdjunta = await _subirImagen(_imagenSeleccionada!);
      }

      final Map<String, dynamic> datosComentario = {
        'texto': textoLimpio,
        'autor': nombreAutor,
        'fotoPerfil': urlFotoPerfil,
        'uid': usuarioActual.uid,
        'fecha': FieldValue.serverTimestamp(),
        'imagenUrl': urlImagenAdjunta,
        'likes': <String>[],
      };

      if (_idComentarioRespondido != null) {
        datosComentario['esRespuesta'] = true;
        datosComentario['respondiendoA'] = _idComentarioRespondido;
        datosComentario['respondiendoAAutor'] = _autorComentarioRespondido;
      }

      await _comentariosRef.add(datosComentario);
      await _notificarDuenioPublicacion(
        usuarioActual: usuarioActual,
        nombreAutor: nombreAutor,
        textoComentario: textoLimpio,
      );

      _controladorTexto.clear();
      setState(() {
        _imagenSeleccionada = null;
        _idComentarioRespondido = null;
        _autorComentarioRespondido = null;
      });

      if (_controladorScroll.hasClients) {
        _controladorScroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $error')),
        );
      }
    } finally {
      setState(() => _enviando = false);
    }
  }

  /// Envía una notificación push al dueño de la publicación si es distinto
  /// del [usuarioActual] que comentó.
  Future<void> _notificarDuenioPublicacion({
    required User usuarioActual,
    required String nombreAutor,
    required String textoComentario,
  }) async {
    try {
      final documentoPublicacion = await FirebaseFirestore.instance
          .collection(_coleccionPadre)
          .doc(widget.reporteId)
          .get();

      if (!documentoPublicacion.exists) return;

      final datosPublicacion = documentoPublicacion.data();
      final idDuenioPublicacion = datosPublicacion?['usuarioId'] as String?;
      final nombrePublicacion =
          datosPublicacion?['nombre'] ??
          datosPublicacion?['direccion'] ??
          'Publicación';

      if (idDuenioPublicacion == null ||
          idDuenioPublicacion == usuarioActual.uid) {
        return;
      }

      final documentoDuenio = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(idDuenioPublicacion)
          .get();

      final tokenNotificacion =
          (documentoDuenio.data()?['token'] ??
           documentoDuenio.data()?['fcmToken'] ??
           '')
              .toString();

      final tituloNotificacion = widget.tipo == 'reporte'
          ? 'Nuevo comentario sobre $nombrePublicacion'
          : 'Nuevo comentario en tu avistamiento';

      final cuerpoNotificacion = textoComentario.isNotEmpty
          ? '$nombreAutor: $textoComentario'
          : '$nombreAutor adjuntó una imagen';

      await NotificacionServicio.enviarPushAUsuario(
        token: tokenNotificacion,
        titulo: tituloNotificacion,
        cuerpo: cuerpoNotificacion,
        usuarioId: idDuenioPublicacion,
        tipo: widget.tipo,
      );
    } catch (error) {
      debugPrint("Error al enviar notificación de comentario: $error");
    }
  }

  // ─── Like ─────────────────────────────────────────────────────────────────

  /// Alterna el like del usuario actual en el comentario con [idDocumento].
  ///
  /// Si el usuario ya dio like, lo quita; de lo contrario, lo agrega.
  Future<void> _toggleLike(
    String idDocumento,
    List<String> likesActuales,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final referenciaDocumento = _comentariosRef.doc(idDocumento);
    if (likesActuales.contains(uid)) {
      await referenciaDocumento.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await referenciaDocumento.update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  // ─── Eliminar ─────────────────────────────────────────────────────────────

  /// Muestra confirmación y elimina el comentario con [idDocumento].
  ///
  /// Si el comentario tenía [urlImagenAdjunta], también la elimina de Storage.
  Future<void> _eliminarComentario(
    String idDocumento,
    String? urlImagenAdjunta,
  ) async {
    final confirmado = await showDialog<bool>(
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
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      if (urlImagenAdjunta != null && urlImagenAdjunta.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .refFromURL(urlImagenAdjunta)
              .delete();
        } catch (_) {}
      }
      await _comentariosRef.doc(idDocumento).delete();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $error')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final idUsuarioActual = FirebaseAuth.instance.currentUser?.uid;

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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _comentariosRef
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, instantanea) {
                if (instantanea.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!instantanea.hasData ||
                    instantanea.data!.docs.isEmpty) {
                  return _buildEstadoVacio();
                }

                final documentos = instantanea.data!.docs;

                return ListView.builder(
                  controller: _controladorScroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: documentos.length,
                  itemBuilder: (context, indice) {
                    final documento = documentos[indice];
                    final datosComentario =
                        documento.data() as Map<String, dynamic>;
                    final likes = List<String>.from(
                      datosComentario['likes'] ?? [],
                    );
                    final esMioEsteComentario =
                        datosComentario['uid'] == idUsuarioActual;
                    final usuarioDioLike = idUsuarioActual != null &&
                        likes.contains(idUsuarioActual);
                    final fechaComentario =
                        (datosComentario['fecha'] as Timestamp?)?.toDate();
                    final esRespuesta =
                        datosComentario['esRespuesta'] == true;

                    return _buildTarjetaComentario(
                      idDocumento: documento.id,
                      datosComentario: datosComentario,
                      likes: likes,
                      esMio: esMioEsteComentario,
                      usuarioDioLike: usuarioDioLike,
                      fecha: fechaComentario,
                      esRespuesta: esRespuesta,
                    );
                  },
                );
              },
            ),
          ),
          _buildBarraEscritura(),
        ],
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  /// Construye la tarjeta visual de un comentario individual.
  Widget _buildTarjetaComentario({
    required String idDocumento,
    required Map<String, dynamic> datosComentario,
    required List<String> likes,
    required bool esMio,
    required bool usuarioDioLike,
    required DateTime? fecha,
    required bool esRespuesta,
  }) {
    final urlFotoPerfil = datosComentario['fotoPerfil'] as String?;
    final nombreAutor = datosComentario['autor'] ?? 'Anónimo';
    final textoComentario = datosComentario['texto'] ?? '';
    final urlImagenAdjunta = datosComentario['imagenUrl'] as String?;
    final autorRespondido =
        datosComentario['respondiendoAAutor'] as String?;

    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        left: esRespuesta ? 32 : 0,
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
            if (esRespuesta && autorRespondido != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      'Responde a $autorRespondido',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.teal),
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
                  backgroundImage:
                      (urlFotoPerfil != null && urlFotoPerfil.isNotEmpty)
                          ? NetworkImage(urlFotoPerfil)
                          : null,
                  child: (urlFotoPerfil == null || urlFotoPerfil.isEmpty)
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
                        nombreAutor as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        FechaUtils.formatearTiempoRelativo(fecha),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (esMio)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: Colors.grey, size: 20),
                    onSelected: (opcion) {
                      if (opcion == 'eliminar') {
                        _eliminarComentario(
                          idDocumento,
                          datosComentario['imagenUrl'] as String?,
                        );
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

            if (textoComentario.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                textoComentario as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],

            if (urlImagenAdjunta != null && urlImagenAdjunta.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  urlImagenAdjunta,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(idDocumento, likes),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          usuarioDioLike
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(usuarioDioLike),
                          color:
                              usuarioDioLike ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${likes.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _idComentarioRespondido = idDocumento;
                      _autorComentarioRespondido = nombreAutor as String;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.reply, color: Colors.teal.shade400, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Responder',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade600,
                        ),
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

  /// Construye la barra inferior para escribir y enviar comentarios.
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
            if (_idComentarioRespondido != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.teal.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Respondiendo a $_autorComentarioRespondido',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.teal),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _idComentarioRespondido = null;
                        _autorComentarioRespondido = null;
                      }),
                      child:
                          const Icon(Icons.close, size: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),

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
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_outlined, color: Colors.teal),
                    onPressed: _seleccionarImagen,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 2,
                      ),
                      child: TextField(
                        controller: _controladorTexto,
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
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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

  /// Pantalla vacía que se muestra cuando no hay comentarios aún.
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
