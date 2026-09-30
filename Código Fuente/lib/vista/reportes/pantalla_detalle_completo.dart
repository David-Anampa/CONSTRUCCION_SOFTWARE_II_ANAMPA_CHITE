import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/pantalla_chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pantalla_comentarios_reporte.dart';

class PantallaDetalleCompleto extends StatefulWidget {
  final Map<String, dynamic> data;
  final String tipo;

  const PantallaDetalleCompleto({
    super.key,
    required this.data,
    required this.tipo,
  });

  @override
  State<PantallaDetalleCompleto> createState() =>
      _PantallaDetalleCompletoState();
}

class _PantallaDetalleCompletoState extends State<PantallaDetalleCompleto> {
  Map<String, dynamic>? usuarioData;
  bool cargandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    try {
      final usuarioId = widget.data["usuarioId"];
      if (usuarioId == null) return;
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(usuarioId)
          .get();
      if (doc.exists) {
        setState(() {
          usuarioData = doc.data();
        });
      }
    } catch (e) {
      debugPrint("Error cargando usuario: $e");
    } finally {
      setState(() => cargandoUsuario = false);
    }
  }

  Future<void> _abrirEnMapa(double lat, double lng) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir el mapa';
    }
  }

  Future<void> _abrirChat() async {
    final user = FirebaseAuth.instance.currentUser!;
    final publicadorId = widget.data["usuarioId"];
    final reporteId = widget.data["id"];
    final tipo = widget.tipo;

    if (publicadorId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No puedes chatear contigo mismo.")),
      );
      return;
    }

    final chatExistente = await FirebaseFirestore.instance
        .collection("chats")
        .where("publicadorId", isEqualTo: publicadorId)
        .where("usuarioId", isEqualTo: user.uid)
        .where("reporteId", isEqualTo: reporteId)
        .limit(1)
        .get();

    String chatId;
    if (chatExistente.docs.isNotEmpty) {
      chatId = chatExistente.docs.first.id;
    } else {
      final nuevoChat = await FirebaseFirestore.instance
          .collection("chats")
          .add({
            "reporteId": reporteId,
            "tipo": tipo,
            "publicadorId": publicadorId,
            "usuarioId": user.uid,
            "usuarios": [publicadorId, user.uid],
            "fechaInicio": FieldValue.serverTimestamp(),
          });
      chatId = nuevoChat.id;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaChat(
            chatId: chatId,
            reporteId: reporteId,
            tipo: tipo,
            publicadorId: publicadorId,
            usuarioId: user.uid,
          ),
        ),
      );
    }
  }

  Color _colorPorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case "PERDIDO":
        return Colors.red.shade600;
      case "AVISTADO":
        return Colors.green.shade600;
      case "ENCONTRADO":
        return Colors.teal.shade600;
      case "CONFIRMADO":
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _abrirImagenCompleta(String urlImagen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaImagenCompleta(
          imagenUrl: urlImagen,
          titulo: widget.data["nombre"] ?? "Mascota",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final esReporte = widget.tipo == "reporte";

    // 📅 Campos dinámicos según tipo
    final fecha = esReporte
        ? data["fechaPerdida"] ?? "-"
        : data["fechaAvistamiento"] ?? "-";

    final hora = esReporte
        ? data["horaPerdida"] ?? "-"
        : data["horaAvistamiento"] ?? "-";

    final descripcion = esReporte
        ? (data["detalles"]?.toString().isNotEmpty == true
              ? data["detalles"]
              : data["caracteristicas"] ?? "Sin detalles adicionales.")
        : (data["descripcion"]?.toString().isNotEmpty == true
              ? data["descripcion"]
              : "Sin detalles adicionales.");

    final fotos = (data["fotos"] ?? []) as List;
    final urlFoto = esReporte
        ? (fotos.isNotEmpty ? fotos.first : null)
        : (data["foto"] ?? "");
    final int recompensaCoins = data["recompensaPataCoins"] ?? 50;

    // ✅ Estado dinámico
    final estado = (data["estado"] ?? (esReporte ? "PERDIDO" : "AVISTADO"))
        .toString()
        .toUpperCase();
    final colorEstado = _colorPorEstado(estado);

    final bool deshabilitarChat =
        estado == "ENCONTRADO" || estado == "CONFIRMADO";

    // 🏷️ Título dinámico
    final tituloAppBar = esReporte
        ? "Detalle del Reporte"
        : "Detalle del Avistamiento";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaComentariosReporte(
              reporteId: data['id'] ?? '',
              tipo: widget.tipo,
              tituloReporte: data['nombre'] ??
                  data['direccion'] ??
                  'Reporte',
            ),
          ),
        ),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Comentarios',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tituloAppBar,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Imagen principal con clic para ampliar
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    if (urlFoto != null && urlFoto.isNotEmpty) {
                      _abrirImagenCompleta(urlFoto);
                    }
                  },
                  child: Hero(
                    tag: urlFoto ?? 'no-image',
                    child: urlFoto != null && urlFoto.isNotEmpty
                        ? Image.network(
                            urlFoto,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 280,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.pets,
                              size: 100,
                              color: Colors.teal,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🐶 Detalle general
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["nombre"] ?? "Mascota sin nombre",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${data["tipo"] ?? "Desconocido"} • ${data["raza"] ?? "Sin raza"}",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniInfo("Fecha", fecha, Icons.event),
                      _miniInfo("Hora", hora, Icons.access_time),
                      _miniInfo(
                        "Distrito",
                        data["distrito"] ?? "-",
                        Icons.location_city,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Descripción",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // 📍 Última ubicación
                  const Text(
                    "Última ubicación conocida",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Colors.teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data["direccion"] ?? "Ubicación no especificada",
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (data["latitud"] != null && data["longitud"] != null)
                    ElevatedButton.icon(
                      onPressed: () => _abrirEnMapa(
                        (data["latitud"] as num).toDouble(),
                        (data["longitud"] as num).toDouble(),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("Ver en Google Maps"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 25),

                  // 🪙 Recompensa en PataCoins
                  if (esReporte)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Recompensa ofrecida por la app",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "+$recompensaCoins 🪙",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 25),

                  // 🏆 Recompensa del dueño (solo si existe)
                  if (esReporte) ...[
                    _buildRecompensaDueno(data),
                  ],

                  const SizedBox(height: 30),

                  // 👤 Información de contacto
                  const Text(
                    "Información de contacto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  if (cargandoUsuario)
                    const Center(child: CircularProgressIndicator())
                  else if (usuarioData != null)
                    _buildContacto(usuarioData!, deshabilitarChat)
                  else
                    const Text(
                      "No se encontró la información del publicador.",
                      style: TextStyle(color: Colors.redAccent),
                    ),

                  // 🔎 Avistamientos relacionados
                  if (esReporte) ...[
                    const SizedBox(height: 40),
                    const Text(
                      "Avistamientos relacionados",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("avistamientos")
                          .where("reporteId", isEqualTo: data["id"])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Text(
                            "No hay avistamientos relacionados aún.",
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        return Column(
                          children: docs.map((doc) {
                            final a = doc.data() as Map<String, dynamic>;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PantallaDetalleCompleto(
                                        data: a,
                                        tipo: "avistamiento",
                                      ),
                                    ),
                                  );
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    a["foto"] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.pets,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  a["descripcion"] ?? "Sin descripción",
                                ),
                                subtitle: Text(
                                  a["direccion"] ?? "Sin dirección",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.map_outlined,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    final lat = (a["latitud"] as num?)
                                        ?.toDouble();
                                    final lng = (a["longitud"] as num?)
                                        ?.toDouble();
                                    if (lat != null && lng != null) {
                                      final Uri uri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                      );
                                      launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],

                  // ─── 💬 Sección comentarios del reporte ───
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaComentariosReporte(
                              reporteId: data['id'] ?? '',
                              tipo: widget.tipo,
                              tituloReporte: data['nombre'] ??
                                  data['direccion'] ??
                                  'Reporte',
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.open_in_new,
                            size: 16, color: Colors.teal),
                        label: const Text(
                          'Ver todos',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildVistaComentarios(data),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista previa de los últimos 3 comentarios del reporte
  Widget _buildVistaComentarios(Map<String, dynamic> data) {
    final colPadre =
        widget.tipo == 'reporte' ? 'reportes_mascotas' : 'avistamientos';
    final reporteId = data['id'] ?? '';

    if (reporteId.isEmpty) {
      return const Text(
        'ID de reporte no disponible.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(colPadre)
          .doc(reporteId)
          .collection('comentarios')
          .orderBy('fecha', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaComentariosReporte(
                  reporteId: reporteId,
                  tipo: widget.tipo,
                  tituloReporte: data['nombre'] ?? data['direccion'] ?? 'Reporte',
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_comment_outlined, color: Colors.teal),
                  SizedBox(width: 10),
                  Text(
                    'Sé el primero en comentar',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: [
            ...docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final foto = d['fotoPerfil'];
              final autor = d['autor'] ?? 'Anónimo';
              final texto = d['texto'] ?? '';
              final fecha = (d['fecha'] as Timestamp?)?.toDate();
              final likes = (d['likes'] as List?)?.length ?? 0;

              String fechaTexto = '';
              if (fecha != null) {
                final diff = DateTime.now().difference(fecha);
                if (diff.inMinutes < 60) {
                  fechaTexto = 'Hace ${diff.inMinutes} min';
                } else if (diff.inHours < 24) {
                  fechaTexto = 'Hace ${diff.inHours} h';
                } else {
                  fechaTexto = '${fecha.day}/${fecha.month}/${fecha.year}';
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.teal.shade100,
                      backgroundImage: (foto != null && foto.isNotEmpty)
                          ? NetworkImage(foto)
                          : null,
                      child: (foto == null || foto.isEmpty)
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                autor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                fechaTexto,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          if (texto.isNotEmpty) ...[  
                            const SizedBox(height: 3),
                            Text(
                              texto,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (likes > 0) ...[  
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.favorite,
                                    color: Colors.red, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '$likes',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (docs.length >= 3)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaComentariosReporte(
                      reporteId: reporteId,
                      tipo: widget.tipo,
                      tituloReporte:
                          data['nombre'] ?? data['direccion'] ?? 'Reporte',
                    ),
                  ),
                ),
                child: const Text(
                  'Ver todos los comentarios →',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Bloque de recompensa personal ofrecida por el dueño
  Widget _buildRecompensaDueno(Map<String, dynamic> data) {
    final rawMonto = (data["montoRecompensa"] ?? "").toString().trim();

    // Si no hay monto, no mostramos nada
    if (rawMonto.isEmpty) return const SizedBox.shrink();

    String monto = rawMonto;
    if (!monto.startsWith(RegExp(r'^S/\.?\s*'))) {
      monto = 'S/. $monto';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB300), size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recompensa de búsqueda",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  monto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.teal, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContacto(Map<String, dynamic> user, bool deshabilitarChat) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final nombre = user["nombre"] ?? "Usuario desconocido";
    final foto = user["fotoPerfil"];
    final correo = user["correo"] ?? "";
    final usuarioId = widget.data["usuarioId"];
    final esPropietario = usuarioId == currentUser?.uid;

    ImageProvider? imagen;
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith("assets/")) {
        imagen = AssetImage(foto);
      } else if (foto.startsWith("http")) {
        imagen = NetworkImage(foto);
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.teal.shade50,
            backgroundImage: imagen,
            child: imagen == null
                ? const Icon(Icons.person, color: Colors.teal, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(correo, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (!esPropietario)
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Contactar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: _abrirChat,
            ),
        ],
      ),
    );
  }
}

// 🖼️ Pantalla para ver la imagen en tamaño completo
class PantallaImagenCompleta extends StatelessWidget {
  final String imagenUrl;
  final String titulo;

  const PantallaImagenCompleta({
    super.key,
    required this.imagenUrl,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Hero(
        tag: imagenUrl,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          child: Center(
            child: Image.network(
              imagenUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'Error al cargar la imagen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
