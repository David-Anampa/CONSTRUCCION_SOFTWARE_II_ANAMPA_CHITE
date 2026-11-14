import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../vistamodelo/admin/AdminReportes_vm.dart';
import '../../modelo/AdminReporte.dart';

class PantallaAdminReporte extends StatelessWidget {
  const PantallaAdminReporte({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminReportesVM()..cargarReportes()..cargarAvistamientos(),
      child: const _ContenidoGestionReportes(),
    );
  }
}

class _ContenidoGestionReportes extends StatelessWidget {
  const _ContenidoGestionReportes();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminReportesVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gestionar Reportes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          // Botón exportar PDF completo
          IconButton(
            tooltip: "Exportar todo a PDF",
            icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
            onPressed: vm.cargando
                ? null
                : () => _exportarPDFCompleto(context, vm),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Estadísticas rápidas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat("Total", "${vm.totalReportes}", Colors.blue),
                      _buildMiniStat("Perdidos", "${vm.reportesPerdidos}", Colors.red),
                      _buildMiniStat("Encontrados", "${vm.reportesEncontrados}", Colors.green),
                      _buildMiniStat("Avistamientos", "${vm.totalAvistamientos}", Colors.purple),
                    ],
                  ),
                ),

                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: vm.actualizarBusqueda,
                    decoration: InputDecoration(
                      hintText: "Buscar por nombre, raza, distrito...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : _ContenidoPrincipal(vm: vm),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // GENERACIÓN DEL PDF COMPLETO DE ADMINISTRADOR
  // ─────────────────────────────────────────────────────────
  Future<void> _exportarPDFCompleto(
      BuildContext context, AdminReportesVM vm) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Generando PDF...", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final file = await _generarPDFAdmin(vm);
      if (context.mounted) Navigator.pop(context); // cerrar loading

      if (file != null && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.orange),
                SizedBox(width: 8),
                Text("PDF generado ✅"),
              ],
            ),
            content: const Text("El reporte completo fue generado exitosamente. ¿Qué deseas hacer?"),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Ver"),
                onPressed: () {
                  OpenFilex.open(file.path);
                  Navigator.pop(context);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("Compartir"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: "Reporte completo SOS Mascotas - Admin",
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error al generar PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> _generarPDFAdmin(AdminReportesVM vm) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final fechaGen =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final reportes = vm.reportes;
    final avistamientos = vm.avistamientos;

    // ── PÁGINA 1: PORTADA + ESTADÍSTICAS ───────────────────
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado principal
              pw.Container(
                width: PdfPageFormat.a4.width,
                padding: const pw.EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "SOS MASCOTAS",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 30,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      "Reporte General de Administración",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Generado: $fechaGen",
                      style: pw.TextStyle(
                        color: PdfColors.orange100,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Sección estadísticas
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "RESUMEN ESTADÍSTICO",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                        letterSpacing: 1.5,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(color: PdfColors.orange, thickness: 2),
                    pw.SizedBox(height: 16),

                    // Tarjetas de estadísticas en fila
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _statCard("Total Reportes", "${reportes.length}", PdfColors.blue800),
                        _statCard("Perdidos", "${vm.reportesPerdidos}", PdfColors.red800),
                        _statCard("Encontrados", "${vm.reportesEncontrados}", PdfColors.green800),
                        _statCard("Avistamientos", "${avistamientos.length}", PdfColors.purple800),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Barra visual de proporciones
                    if (reportes.isNotEmpty) ...[
                      pw.Text(
                        "Distribución por estado:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _barraEstado("PERDIDO", vm.reportesPerdidos, reportes.length, PdfColors.red),
                      pw.SizedBox(height: 6),
                      _barraEstado("ENCONTRADO", vm.reportesEncontrados, reportes.length, PdfColors.green),
                      pw.SizedBox(height: 6),
                      _barraEstado(
                        "OTROS",
                        reportes.length - vm.reportesPerdidos - vm.reportesEncontrados,
                        reportes.length,
                        PdfColors.grey,
                      ),
                    ],
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Text(
                    "SOS Mascotas - Administración  |  Página 1",
                    style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // ── PÁGINAS DE REPORTES ─────────────────────────────────
    // Descargamos imágenes de los primeros N reportes para no tardar demasiado
    const maxFotos = 20;
    final reportesConFoto = <Map<String, dynamic>>[];

    for (int i = 0; i < reportes.length; i++) {
      final r = reportes[i];
      pw.MemoryImage? img;
      if (i < maxFotos && r.fotos.isNotEmpty) {
        try {
          final res = await http
              .get(Uri.parse(r.fotos.first))
              .timeout(const Duration(seconds: 10));
          if (res.statusCode == 200) img = pw.MemoryImage(res.bodyBytes);
        } catch (_) {}
      }
      reportesConFoto.add({"reporte": r, "img": img});
    }

    // Añadir página de lista de reportes (tabla)
    if (reportes.isNotEmpty) {
      // Encabezado de sección + tabla paginada
      final chunks = _chunkList(reportesConFoto, 12);
      for (int pageIdx = 0; pageIdx < chunks.length; pageIdx++) {
        final chunk = chunks[pageIdx];
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(28),
            build: (pw.Context ctx) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _seccionHeader(
                    "LISTADO DE REPORTES",
                    "Total: ${reportes.length}  |  Página ${pageIdx + 2}",
                    PdfColors.blue800,
                  ),
                  pw.SizedBox(height: 12),
                  // Tabla
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2.5),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(1.5),
                      3: const pw.FlexColumnWidth(2),
                      4: const pw.FlexColumnWidth(1.2),
                      5: const pw.FlexColumnWidth(2.5),
                    },
                    children: [
                      // Cabecera
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                        children: [
                          _celdaHeader("Nombre"),
                          _celdaHeader("Tipo"),
                          _celdaHeader("Raza"),
                          _celdaHeader("Distrito"),
                          _celdaHeader("Estado"),
                          _celdaHeader("Usuario"),
                        ],
                      ),
                      // Filas de datos
                      ...chunk.map((item) {
                        final r = item["reporte"] as AdminReporte;
                        final esImpar = chunk.indexOf(item) % 2 == 1;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: esImpar ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            _celdaDato(r.nombre.isEmpty ? "-" : r.nombre),
                            _celdaDato(r.tipo.isEmpty ? "-" : r.tipo),
                            _celdaDato(r.raza.isEmpty ? "-" : r.raza),
                            _celdaDato(r.distrito.isEmpty ? "-" : r.distrito),
                            _celdaDatoColor(
                              r.estado,
                              r.estado == "PERDIDO"
                                  ? PdfColors.red700
                                  : r.estado == "ENCONTRADO"
                                      ? PdfColors.green700
                                      : PdfColors.grey700,
                            ),
                            _celdaDato(r.nombreUsuario.isEmpty ? "-" : r.nombreUsuario),
                          ],
                        );
                      }),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Divider(color: PdfColors.grey300),
                  pw.Center(
                    child: pw.Text(
                      "SOS Mascotas - Administración",
                      style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    // ── PÁGINAS DE AVISTAMIENTOS ────────────────────────────
    if (avistamientos.isNotEmpty) {
      final chunksAv = _chunkList(avistamientos, 14);
      for (int pageIdx = 0; pageIdx < chunksAv.length; pageIdx++) {
        final chunk = chunksAv[pageIdx];
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(28),
            build: (pw.Context ctx) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _seccionHeader(
                    "LISTADO DE AVISTAMIENTOS",
                    "Total: ${avistamientos.length}",
                    PdfColors.purple800,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.purple800),
                        children: [
                          _celdaHeader("Descripción"),
                          _celdaHeader("Distrito"),
                          _celdaHeader("Fecha"),
                          _celdaHeader("Usuario"),
                        ],
                      ),
                      ...chunk.map((a) {
                        final esImpar = chunk.indexOf(a) % 2 == 1;
                        final desc = a.descripcion.length > 60
                            ? "${a.descripcion.substring(0, 60)}..."
                            : a.descripcion;
                        return pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: esImpar ? PdfColors.grey50 : PdfColors.white,
                          ),
                          children: [
                            _celdaDato(desc.isEmpty ? "-" : desc),
                            _celdaDato(a.distrito.isEmpty ? "-" : a.distrito),
                            _celdaDato(a.fechaAvistamiento.isEmpty ? "-" : a.fechaAvistamiento),
                            _celdaDato(a.nombreUsuario.isEmpty ? "-" : a.nombreUsuario),
                          ],
                        );
                      }),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Divider(color: PdfColors.grey300),
                  pw.Center(
                    child: pw.Text(
                      "SOS Mascotas - Administración",
                      style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    // ── PÁGINA FINAL: FICHAS INDIVIDUALES con foto (primeros 10) ──
    final conFoto = reportesConFoto
        .where((e) => e["img"] != null)
        .take(10)
        .toList();

    for (final item in conFoto) {
      final r = item["reporte"] as AdminReporte;
      final img = item["img"] as pw.MemoryImage;

      // Intentar descargar mapa
      pw.MemoryImage? mapaImg;
      if (r.latitud != null && r.longitud != null) {
        try {
          final zoom = 15;
          final x = ((r.longitud! + 180) / 360 * (1 << zoom)).floor();
          final y = ((1 -
                          log(tan(r.latitud! * pi / 180) +
                                  1 / cos(r.latitud! * pi / 180)) /
                              pi) /
                      2 *
                      (1 << zoom))
              .floor();
          final tileUrl = "https://tile.openstreetmap.org/$zoom/$x/$y.png";
          final mapRes = await http
              .get(Uri.parse(tileUrl), headers: {'User-Agent': 'SOS Mascotas/1.0'})
              .timeout(const Duration(seconds: 10));
          if (mapRes.statusCode == 200) mapaImg = pw.MemoryImage(mapRes.bodyBytes);
        } catch (_) {}
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Encabezado ficha
                  pw.Container(
                    width: PdfPageFormat.a4.width,
                    padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.orange,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(8),
                        topRight: pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "SOS MASCOTAS - Ficha de Reporte",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Generado: $fechaGen",
                          style: pw.TextStyle(color: PdfColors.orange100, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.all(20),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Foto
                        pw.ClipRRect(
                          horizontalRadius: 8,
                          verticalRadius: 8,
                          child: pw.Image(img, width: 150, height: 130, fit: pw.BoxFit.cover),
                        ),
                        pw.SizedBox(width: 20),
                        // Info
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _fichaFila("Nombre", r.nombre),
                              _fichaFila("Tipo", r.tipo),
                              _fichaFila("Raza", r.raza),
                              _fichaFila("Estado", r.estado),
                              _fichaFila("Fecha", r.fechaPerdida),
                              _fichaFila("Distrito", r.distrito),
                              _fichaFila("Dirección", r.direccion),
                              _fichaFila("Usuario", r.nombreUsuario),
                              if (r.emailUsuario.isNotEmpty)
                                _fichaFila("Email", r.emailUsuario),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mapa si existe
                  if (mapaImg != null) ...[
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Ubicación:",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange,
                              fontSize: 12,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(mapaImg, width: PdfPageFormat.a4.width, height: 160, fit: pw.BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                  ],

                  pw.Spacer(),
                  pw.Divider(color: PdfColors.orange, thickness: 1),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Text(
                        "SOS Mascotas - Unidos por los animales perdidos",
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/admin_reportes_${now.day}-${now.month}-${now.year}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── Helpers PDF ────────────────────────────────────────────

  pw.Widget _statCard(String label, String value, PdfColor color) {
    return pw.Container(
      width: 110,
      padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _barraEstado(String label, int valor, int total, PdfColor color) {
    final pct = total == 0 ? 0.0 : valor / total;
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(label,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        ),
        pw.Expanded(
          child: pw.Container(
            height: 14,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              children: [
                if (pct > 0.0)
                  pw.Expanded(
                    flex: (pct * 1000).toInt(),
                    child: pw.Container(
                      height: 14,
                      decoration: pw.BoxDecoration(
                        color: color,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ),
                if (pct < 1.0)
                  pw.Expanded(
                    flex: ((1.0 - pct) * 1000).toInt(),
                    child: pw.SizedBox(),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text("$valor (${(pct * 100).toStringAsFixed(1)}%)",
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _seccionHeader(String titulo, String subtitulo, PdfColor color) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(titulo,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold)),
          pw.Text(subtitulo,
              style: pw.TextStyle(color: PdfColors.grey300, fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _celdaHeader(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
            color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
      ),
    );
  }

  pw.Widget _celdaDato(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(texto,
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
    );
  }

  pw.Widget _celdaDatoColor(String texto, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(texto,
          style: pw.TextStyle(
              fontSize: 8, color: color, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _fichaFila(String label, String valor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange,
                  fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              valor.isNotEmpty ? valor : "-",
              style: pw.TextStyle(color: PdfColors.grey800, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  List<List<T>> _chunkList<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
}

// ─────────────────────────────────────────────────────────────
// Contenido Principal con Tabs
// ─────────────────────────────────────────────────────────────
class _ContenidoPrincipal extends StatefulWidget {
  final AdminReportesVM vm;

  const _ContenidoPrincipal({required this.vm});

  @override
  State<_ContenidoPrincipal> createState() => _ContenidoPrincipalState();
}

class _ContenidoPrincipalState extends State<_ContenidoPrincipal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: const [
              Tab(
                icon: Icon(Icons.pets),
                text: "Reportes",
              ),
              Tab(
                icon: Icon(Icons.visibility),
                text: "Avistamientos",
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ListaReportes(vm: widget.vm),
              _ListaAvistamientos(vm: widget.vm),
            ],
          ),
        ),
      ],
    );
  }
}

// Lista de Reportes
class _ListaReportes extends StatelessWidget {
  final AdminReportesVM vm;

  const _ListaReportes({required this.vm});

  @override
  Widget build(BuildContext context) {
    final reportes = vm.reportesFiltrados;

    if (reportes.isEmpty) {
      return const Center(
        child: Text(
          "No hay reportes para mostrar",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Filtros de estado
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFiltroChip("TODOS", vm),
              _buildFiltroChip("PERDIDO", vm),
              _buildFiltroChip("ENCONTRADO", vm),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: vm.cargarReportes,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reportes.length,
              itemBuilder: (context, i) {
                final reporte = reportes[i];
                return _TarjetaReporte(reporte: reporte, vm: vm);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroChip(String estado, AdminReportesVM vm) {
    final seleccionado = vm.filtroEstado == estado;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(estado),
        selected: seleccionado,
        onSelected: (_) => vm.cambiarFiltro(estado),
        selectedColor: Colors.orange.shade100,
        checkmarkColor: Colors.orange,
      ),
    );
  }
}

// Tarjeta de Reporte
class _TarjetaReporte extends StatelessWidget {
  final AdminReporte reporte;
  final AdminReportesVM vm;

  const _TarjetaReporte({required this.reporte, required this.vm});

  Color _colorEstado(String estado) {
    switch (estado) {
      case "PERDIDO": return Colors.red;
      case "ENCONTRADO": return Colors.green;
      case "AVISTADO": return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = _colorEstado(reporte.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: reporte.fotos.isNotEmpty
              ? Image.network(
                  reporte.fotos.first,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.pets, color: Colors.grey),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                reporte.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorEstado),
              ),
              child: Text(
                reporte.estado,
                style: TextStyle(
                  color: colorEstado,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("${reporte.tipo} • ${reporte.raza}"),
            const SizedBox(height: 4),
            Text("📍 ${reporte.distrito} • ${reporte.fechaPerdida}"),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reporte.nombreUsuario,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _mostrarDialogoEliminar(context),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    final motivoCtrl = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Eliminar reporte"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Estás seguro de eliminar este reporte?"),
            const SizedBox(height: 16),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(
                labelText: "Motivo de eliminación",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final motivo = motivoCtrl.text.trim();

              if (motivo.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text("Debe ingresar un motivo")),
                );
                return;
              }

              Navigator.pop(dialogContext);

              try {
                final resultado = await vm.eliminarReporte(reporte.id, motivo);

                if (resultado) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("🗑️ Reporte eliminado exitosamente"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("❌ Error al eliminar el reporte"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}

// Lista de Avistamientos
class _ListaAvistamientos extends StatelessWidget {
  final AdminReportesVM vm;

  const _ListaAvistamientos({required this.vm});

  @override
  Widget build(BuildContext context) {
    final avistamientos = vm.avistamientosFiltrados;

    if (avistamientos.isEmpty) {
      return const Center(
        child: Text(
          "No hay avistamientos para mostrar",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.cargarAvistamientos,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: avistamientos.length,
        itemBuilder: (context, i) {
          final avistamiento = avistamientos[i];
          return _TarjetaAvistamiento(avistamiento: avistamiento, vm: vm);
        },
      ),
    );
  }
}

// Tarjeta de Avistamiento
class _TarjetaAvistamiento extends StatelessWidget {
  final AdminAvistamiento avistamiento;
  final AdminReportesVM vm;

  const _TarjetaAvistamiento({required this.avistamiento, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: avistamiento.foto.isNotEmpty
              ? Image.network(
                  avistamiento.foto,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.visibility, color: Colors.grey),
                ),
        ),
        title: Text(
          avistamiento.descripcion.length > 40
              ? "${avistamiento.descripcion.substring(0, 40)}..."
              : avistamiento.descripcion,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("📍 ${avistamiento.distrito} • ${avistamiento.fechaAvistamiento}"),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    avistamiento.nombreUsuario,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            if (avistamiento.reporteId != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link, size: 12, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "Vinculado a reporte",
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _mostrarDialogoEliminar(context),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    final motivoCtrl = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Eliminar avistamiento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("¿Estás seguro de eliminar este avistamiento?"),
            const SizedBox(height: 16),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(
                labelText: "Motivo de eliminación",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final motivo = motivoCtrl.text.trim();

              if (motivo.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text("Debe ingresar un motivo")),
                );
                return;
              }

              Navigator.pop(dialogContext);

              try {
                final resultado =
                    await vm.eliminarAvistamiento(avistamiento.id, motivo);

                if (resultado) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("🗑️ Avistamiento eliminado exitosamente"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("❌ Error al eliminar el avistamiento"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}