import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../reportes/pantalla_detalle_completo.dart';

class PantallaVerReportes extends StatefulWidget {
  const PantallaVerReportes({super.key});

  @override
  State<PantallaVerReportes> createState() => _PantallaVerReportesState();
}

class _PantallaVerReportesState extends State<PantallaVerReportes> {
  // ✅ Sin orderBy para evitar índice compuesto. Se ordena client-side.
  final _reportesRef = FirebaseFirestore.instance
      .collection("reportes_mascotas");

  final _avistamientosRef = FirebaseFirestore.instance
      .collection("avistamientos");

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: const Text(
            "Mascotas Reportadas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.pets), text: "Perdidas"),
              Tab(icon: Icon(Icons.visibility), text: "Avistamientos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ListaReportes(stream: _reportesRef.snapshots(), tipo: "reporte"),
            _ListaReportes(
              stream: _avistamientosRef.snapshots(),
              tipo: "avistamiento",
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaReportes extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final String tipo;

  const _ListaReportes({required this.stream, required this.tipo});

  Color _colorPorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case "PERDIDO":
        return Colors.red;
      case "AVISTADO":
        return Colors.green;
      case "ENCONTRADO":
        return Colors.teal;
      case "CONFIRMADO":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
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
                  Text(
                    tipo == "reporte"
                        ? "Error al cargar reportes"
                        : "Error al cargar avistamientos",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Verifica tu conexión e intenta de nuevo.",
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

        // Ordenar client-side por fechaRegistro descendente
        final docs = (snapshot.data?.docs ?? [])..sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final tsA = dataA['fechaRegistro'] as Timestamp?;
          final tsB = dataB['fechaRegistro'] as Timestamp?;
          if (tsA == null && tsB == null) return 0;
          if (tsA == null) return 1;
          if (tsB == null) return -1;
          return tsB.compareTo(tsA);
        });

        if (docs.isEmpty) {
          return Center(
            child: Text(
              tipo == "reporte"
                  ? "No hay mascotas perdidas 🐶"
                  : "No hay avistamientos recientes 🐱",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final fotos = (data["fotos"] ?? []) as List;
            final urlFoto = tipo == "reporte"
                ? (fotos.isNotEmpty ? fotos.first : null)
                : (data["foto"] ?? "");
            data["id"] = docs[i].id;

            final nombre = data["nombre"] ?? "Mascota sin nombre";
            final raza = data["raza"] ?? "Sin raza";
            final direccion = data["direccion"] ?? "Zona no especificada";
            final descripcion =
                data["detalles"] ??
                data["caracteristicas"] ??
                data["descripcion"] ??
                "Sin descripción.";
            final fecha = tipo == "reporte"
                ? data["fechaPerdida"] ?? "-"
                : data["fechaAvistamiento"] ?? "-";
            final hora = tipo == "reporte"
                ? data["horaPerdida"] ?? "-"
                : data["horaAvistamiento"] ?? "-";

            // ✅ Leer estado real desde Firestore (por defecto “PERDIDO” o “AVISTADO”)
            final estado =
                (data["estado"] ?? (tipo == "reporte" ? "PERDIDO" : "AVISTADO"))
                    .toString()
                    .toUpperCase();
            final colorEstado = _colorPorEstado(estado);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PantallaDetalleCompleto(data: data, tipo: tipo),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📸 Imagen
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (urlFoto != null && urlFoto.isNotEmpty)
                            ? Image.network(
                                urlFoto,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.teal.shade50,
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.teal,
                                  size: 40,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),

                      // 🐶 Detalles
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre y etiqueta de estado
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorEstado.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorEstado),
                                  ),
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      color: colorEstado,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),
                            Text(
                              "${data["tipo"] ?? "Mascota"} • $raza",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  color: Colors.teal,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "$direccion • $fecha $hora",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(
                              descripcion.length > 70
                                  ? "${descripcion.substring(0, 70)}..."
                                  : descripcion,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 10),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PantallaDetalleCompleto(
                                      data: data,
                                      tipo: tipo,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                color: Colors.teal,
                                size: 18,
                              ),
                              label: const Text(
                                "Ver más",
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
