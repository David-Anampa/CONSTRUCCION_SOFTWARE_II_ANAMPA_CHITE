import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../reportes/pantalla_detalle_completo.dart';
import '../../servicios/notificacion_servicio.dart';

class PantallaChat extends StatefulWidget {
  final String chatId;
  final String reporteId;
  final String tipo;
  final String publicadorId;
  final String usuarioId;

  const PantallaChat({
    super.key,
    required this.chatId,
    required this.reporteId,
    required this.tipo,
    required this.publicadorId,
    required this.usuarioId,
  });

  @override
  State<PantallaChat> createState() => _PantallaChatState();
}

class _PantallaChatState extends State<PantallaChat> {
  final TextEditingController _mensajeCtrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _reporteData;
  Map<String, dynamic>? _usuarioPublicador;
  Map<String, dynamic>? _usuarioActual;
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _marcarMensajesComoLeidos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([_cargarInfoReporte(), _cargarUsuarios()]);
  }

  Future<void> _cargarInfoReporte() async {
    try {
      final col =
          widget.tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';
      final doc = await FirebaseFirestore.instance
          .collection(col)
          .doc(widget.reporteId)
          .get();
      if (doc.exists) {
        setState(() => _reporteData = doc.data());
      }
    } catch (e) {
      debugPrint('Error cargando reporte: $e');
    }
  }

  Future<void> _cargarUsuarios() async {
    try {
      final docPub = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.publicadorId)
          .get();
      final docAct = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.usuarioId)
          .get();

      setState(() {
        _usuarioPublicador = docPub.exists ? docPub.data() : null;
        _usuarioActual = docAct.exists ? docAct.data() : null;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando usuarios: $e');
      setState(() => _cargando = false);
    }
  }

  /// Marca todos los mensajes del otro usuario como leídos
  Future<void> _marcarMensajesComoLeidos() async {
    final uidActual = _auth.currentUser?.uid;
    if (uidActual == null) return;

    final mensajes = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('mensajes')
        .where('emisorId', isNotEqualTo: uidActual)
        .where('leido', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in mensajes.docs) {
      batch.update(doc.reference, {'leido': true});
    }
    await batch.commit();
  }

  ImageProvider? _obtenerAvatar(String usuarioId) {
    final data = usuarioId == widget.publicadorId
        ? _usuarioPublicador
        : _usuarioActual;
    if (data == null) return null;
    final foto = data['fotoPerfil'];
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith('assets/')) return AssetImage(foto);
      if (foto.startsWith('http')) return NetworkImage(foto);
    }
    return null;
  }

  String _obtenerNombre(String usuarioId) {
    final data = usuarioId == widget.publicadorId
        ? _usuarioPublicador
        : _usuarioActual;
    return data?['nombre'] ?? 'Usuario';
  }

  Future<void> _enviarMensaje() async {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    _mensajeCtrl.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('mensajes')
        .add({
          'emisorId': _auth.currentUser!.uid,
          'texto': texto,
          'fechaEnvio': FieldValue.serverTimestamp(),
          'leido': false,
        });

    // 🔔 Notificar al otro usuario del chat
    try {
      final uidActual = _auth.currentUser!.uid;
      final otroUsuarioId = uidActual == widget.publicadorId
          ? widget.usuarioId
          : widget.publicadorId;
      final emisorNombre = _obtenerNombre(uidActual);
      final otroUsuarioData = otroUsuarioId == widget.publicadorId
          ? _usuarioPublicador
          : _usuarioActual;
      final token = (otroUsuarioData?['token'] ?? otroUsuarioData?['fcmToken'] ?? '').toString();

      await NotificacionServicio.enviarPushAUsuario(
        token: token,
        titulo: 'Nuevo mensaje de $emisorNombre',
        cuerpo: texto,
        usuarioId: otroUsuarioId,
        tipo: 'chat',
      );
    } catch (ne) {
      debugPrint("Error al enviar notificación de chat: $ne");
    }

    setState(() => _enviando = false);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatearHora(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final ahora = DateTime.now();
    final diff = ahora.difference(dt);

    final hora =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (diff.inDays == 0) return hora;
    if (diff.inDays == 1) return 'Ayer $hora';
    return '${dt.day}/${dt.month} $hora';
  }

  @override
  Widget build(BuildContext context) {
    final uidActual = _auth.currentUser!.uid;

    final titulo = _cargando
        ? 'Cargando...'
        : _reporteData == null
        ? 'Chat'
        : widget.tipo == 'reporte'
        ? (_reporteData!['nombre'] ?? 'Mascota')
        : (_reporteData!['direccion'] ?? 'Avistamiento');

    final otroUsuarioId = uidActual == widget.publicadorId
        ? widget.usuarioId
        : widget.publicadorId;
    final avatarOtroUsuario = _obtenerAvatar(otroUsuarioId);
    final nombreOtroUsuario = _obtenerNombre(otroUsuarioId);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        titleSpacing: 0,
        title: InkWell(
          onTap: _reporteData == null
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaDetalleCompleto(
                        data: _reporteData!,
                        tipo: widget.tipo,
                      ),
                    ),
                  ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: avatarOtroUsuario,
                child: avatarOtroUsuario == null
                    ? const Icon(Icons.person, color: Colors.teal)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreOtroUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.white70, size: 22),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 💬 Lista de mensajes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('mensajes')
                    .orderBy('fechaEnvio', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final mensajes = snapshot.data!.docs;

                  if (mensajes.isEmpty) {
                    return _buildEstadoVacioChat();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: mensajes.length,
                    itemBuilder: (context, i) {
                      final data =
                          mensajes[i].data() as Map<String, dynamic>;
                      final emisorId = data['emisorId'];
                      final esMio = emisorId == uidActual;
                      final avatarEmisor = _obtenerAvatar(emisorId);
                      final timestamp = data['fechaEnvio'] as Timestamp?;
                      final leido = data['leido'] as bool? ?? false;

                      // Mostrar separador de fecha si el día cambia
                      bool mostrarFecha = false;
                      if (i < mensajes.length - 1) {
                        final anterior = mensajes[i + 1].data()
                            as Map<String, dynamic>;
                        final tsAnterior =
                            anterior['fechaEnvio'] as Timestamp?;
                        if (timestamp != null && tsAnterior != null) {
                          final dt = timestamp.toDate();
                          final dtAnt = tsAnterior.toDate();
                          mostrarFecha = dt.day != dtAnt.day ||
                              dt.month != dtAnt.month;
                        }
                      } else {
                        mostrarFecha = true;
                      }

                      return Column(
                        children: [
                          if (mostrarFecha && timestamp != null)
                            _buildSeparadorFecha(timestamp.toDate()),
                          _buildBurbujaMensaje(
                            data: data,
                            esMio: esMio,
                            avatarEmisor: avatarEmisor,
                            timestamp: timestamp,
                            leido: leido,
                            uidActual: uidActual,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // 🧾 Campo de texto + botón enviar
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mensajeCtrl,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _enviarMensaje(),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _enviando ? null : _enviarMensaje,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(11),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoVacioChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Inicia la conversación!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escribe un mensaje para contactar\ncon el publicador del reporte',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparadorFecha(DateTime fecha) {
    final ahora = DateTime.now();
    String texto;
    if (fecha.day == ahora.day &&
        fecha.month == ahora.month &&
        fecha.year == ahora.year) {
      texto = 'Hoy';
    } else if (fecha.day == ahora.subtract(const Duration(days: 1)).day) {
      texto = 'Ayer';
    } else {
      texto = '${fecha.day}/${fecha.month}/${fecha.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              texto,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildBurbujaMensaje({
    required Map<String, dynamic> data,
    required bool esMio,
    required ImageProvider? avatarEmisor,
    required Timestamp? timestamp,
    required bool leido,
    required String uidActual,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del otro usuario
          if (!esMio) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.teal.shade50,
              backgroundImage: avatarEmisor,
              child: avatarEmisor == null
                  ? const Icon(Icons.person, color: Colors.teal, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],

          // Burbuja + timestamp
          Column(
            crossAxisAlignment:
                esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: esMio
                        ? const LinearGradient(
                            colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : const LinearGradient(
                            colors: [Colors.white, Color(0xFFF5F5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(esMio ? 18 : 4),
                      bottomRight: Radius.circular(esMio ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    data['texto'] ?? '',
                    style: TextStyle(
                      color: esMio ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatearHora(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  // Indicador de leído (solo en los propios mensajes)
                  if (esMio) ...[
                    const SizedBox(width: 4),
                    Icon(
                      leido ? Icons.done_all : Icons.done,
                      size: 14,
                      color: leido ? Colors.teal : Colors.grey.shade400,
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Avatar propio
          if (esMio) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.teal.shade50,
              backgroundImage: avatarEmisor,
              child: avatarEmisor == null
                  ? const Icon(Icons.person, color: Colors.teal, size: 16)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}