import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/reportes/pantalla_mapa_osm.dart';
// ✅ Ruta corregida - el archivo está en lib/vistamodelo/ no en lib/vistamodelo/reportes/
import 'package:sos_mascotas/vistamodelo/reporte_vm.dart';

/// Constantes visuales del wizard de reporte.
///
/// Antes los colores, duraciones y tamaños estaban repetidos como
/// literales sueltos por todo el archivo. Centralizarlos aquí evita
/// "números mágicos" y hace que un cambio de paleta o de tiempos
/// se haga en un solo lugar.
class _ReporteEstilo {
  _ReporteEstilo._();

  // Colores
  static const Color colorPrimario = Color(0xFF6366F1);
  static const Color colorSecundario = Color(0xFF2563EB);
  static const Color colorMapa = Color(0xFF4D9EF6);
  static const Color colorRecompensa = Color(0xFFFFB300);
  static const Color colorRecompensaTexto = Color(0xFFB45309);
  static const Color colorGaleria = Color(0xFF7C3AED);
  static const Color fondoCamara = Color(0xFFEFF6FF);
  static const Color fondoGaleria = Color(0xFFF5F3FF);

  // Estructura del wizard
  static const int totalPasos = 3;

  // Duraciones
  static const Duration duracionAnimacionBarra = Duration(milliseconds: 400);
  static const Duration duracionAnimacionBoton = Duration(milliseconds: 150);
  static const Duration duracionSnackAnalizando = Duration(seconds: 2);

  // Tamaños
  static const double radioBordeCard = 16;
  static const double radioBordeGrande = 20;
  static const double tamanoMiniatura = 80;
  static const double alturaPreviewFotos = 200;
}

/// Selecciona una imagen desde [fuente], la sube con [vm.subirFoto] y
/// la agrega al reporte, mostrando el progreso mediante SnackBars.
///
/// Antes este mismo flujo estaba copiado 3 veces (imagen principal,
/// botón Cámara y botón Galería); ahora es una sola función reutilizada.
Future<void> _seleccionarYSubirFoto(
  BuildContext context,
  ReporteMascotaVM vm,
  ImageSource fuente,
) async {
  final picker = ImagePicker();
  final imagenSeleccionada = await picker.pickImage(source: fuente);
  if (imagenSeleccionada == null) return; // Fail fast: el usuario canceló.

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Analizando imagen... 🧠"),
      backgroundColor: Colors.blueAccent,
      duration: _ReporteEstilo.duracionSnackAnalizando,
    ),
  );

  final fotosAntes = [...vm.fotos];

  try {
    // En Web el picker no da un path de archivo válido, así que se usan bytes.
    final dynamic imagenParaVM = kIsWeb
        ? await imagenSeleccionada.readAsBytes()
        : File(imagenSeleccionada.path);

    final bytes = imagenParaVM is Uint8List
        ? imagenParaVM
        : await (imagenParaVM as File).readAsBytes();

    final previewUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    vm.mostrarFotoTemporal(previewUrl);

    final url = await vm.subirFoto(imagenParaVM);
    vm.limpiarFotoTemporal();
    vm.agregarFoto(url);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Imagen válida detectada y subida correctamente."),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    final mensaje = e.toString().replaceAll("Exception: ", "");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "❌ Foto inválida: $mensaje",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!context.mounted) return;
    vm.limpiarFotoTemporal();
    if (fotosAntes.isEmpty) {
      vm.limpiarFotos();
    }
  }
}

/// Da formato "S/. <monto>" solo si el usuario no lo escribió ya.
String _formatearMonto(String monto) {
  final montoLimpio = monto.trim();
  final yaTieneMoneda = RegExp(r'^S/\.?\s*').hasMatch(montoLimpio);
  return yaTieneMoneda ? montoLimpio : 'S/. $montoLimpio';
}

Widget _imagenDesdeUrl(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (url.startsWith('data:image')) {
    final base64Data = url.split(',').last;
    return Image.memory(
      base64Decode(base64Data),
      width: width,
      height: height,
      fit: fit,
    );
  }

  if (url.startsWith('http')) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
    );
  }

  return Image.file(
    File(url),
    width: width,
    height: height,
    fit: fit,
  );
}

class PantallaReporteMascota extends StatelessWidget {
  const PantallaReporteMascota({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReporteMascotaVM(),
      child: const _WizardReporte(),
    );
  }
}

class _WizardReporte extends StatelessWidget {
  const _WizardReporte();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteMascotaVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                "Reportar Mascota Perdida",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Paso ${vm.paso + 1} de ${_ReporteEstilo.totalPasos}",
                style: const TextStyle(
                  color: _ReporteEstilo.colorPrimario,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Barra de progreso: el ancho relleno crece según el paso actual.
              Container(
                height: 6,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final anchoRelleno =
                        (vm.paso + 1) /
                        _ReporteEstilo.totalPasos *
                        constraints.maxWidth;
                    return AnimatedContainer(
                      duration: _ReporteEstilo.duracionAnimacionBarra,
                      width: anchoRelleno,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            _ReporteEstilo.colorPrimario,
                            _ReporteEstilo.colorSecundario,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: vm.paso,
        children: const [Paso1Mascota(), Paso2Ubicacion(), Paso3Resumen()],
      ),
    );
  }
}

class Paso1Mascota extends StatelessWidget {
  const Paso1Mascota({super.key});

  /// Diálogo de confirmación antes de quitar una foto ya subida.
  Future<void> _mostrarDialogoEliminar(
    BuildContext context,
    ReporteMascotaVM vm,
    String url,
  ) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar foto"),
          content: const Text("¿Estás seguro de que quieres quitar esta foto?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                vm.removerFoto(url);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Foto eliminada.")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteMascotaVM>();
    final bool fotoPrincipalDisponible = vm.fotos.isNotEmpty || vm.fotoTemporal != null;
    final String? fotoActual = vm.fotoTemporal ?? (vm.fotos.isNotEmpty ? vm.fotos.first : null);

    return Form(
      key: vm.formKeyPaso1,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Foto de tu mascota"),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Miniaturas de las fotos adicionales (todas menos la primera).
                  if (vm.fotos.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...vm.fotos
                              .skip(1)
                              .map(
                                (urlFoto) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      _imagenDesdeUrl(
                                        urlFoto,
                                        width: _ReporteEstilo.tamanoMiniatura,
                                        height: _ReporteEstilo.tamanoMiniatura,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () => _mostrarDialogoEliminar(
                                            context,
                                            vm,
                                            urlFoto,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
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

                  // Card principal: foto grande si existe, o placeholder de cámara.
                  GestureDetector(
                    onLongPress: fotoPrincipalDisponible
                        ? () => _mostrarDialogoEliminar(
                            context,
                            vm,
                            vm.fotos.first,
                          )
                        : null,
                    onTap: () => _seleccionarYSubirFoto(
                      context,
                      vm,
                      ImageSource.gallery,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: fotoPrincipalDisponible ? 0 : 30,
                        horizontal: fotoPrincipalDisponible ? 0 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: fotoPrincipalDisponible
                            ? Colors.transparent
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          _ReporteEstilo.radioBordeCard,
                        ),
                        border: Border.all(
                          color: fotoPrincipalDisponible
                              ? Colors.transparent
                              : Colors.grey[300]!,
                          width: fotoPrincipalDisponible ? 0 : 1.2,
                        ),
                      ),
                      child: fotoPrincipalDisponible
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                _ReporteEstilo.radioBordeCard,
                              ),
                              child: Stack(
                                children: [
                                  _imagenDesdeUrl(
                                    fotoActual!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  if (vm.fotoTemporal != null)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.28),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "INVALIDA",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (vm.fotos.isNotEmpty && vm.fotoTemporal == null)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _mostrarDialogoEliminar(
                                          context,
                                          vm,
                                          vm.fotos.first,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete_forever_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 28,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Agregar foto de tu mascota",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Toca para seleccionar desde galería o cámara",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones secundarios: cámara y galería usan la misma función de subida.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _seleccionarYSubirFoto(
                          context,
                          vm,
                          ImageSource.camera,
                        ),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text("Cámara"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: _ReporteEstilo.colorSecundario,
                          backgroundColor: _ReporteEstilo.fondoCamara,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _seleccionarYSubirFoto(
                          context,
                          vm,
                          ImageSource.gallery,
                        ),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text("Galería"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: _ReporteEstilo.colorGaleria,
                          backgroundColor: _ReporteEstilo.fondoGaleria,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle("Información de la mascota"),
            _input(
              "Nombre de la mascota",
              onChanged: (v) => vm.reporte.nombre = v,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Ingrese el nombre" : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration("Tipo de mascota"),
              value: vm.reporte.tipo.isNotEmpty ? vm.reporte.tipo : null,
              items: const [
                DropdownMenuItem(value: "Perro", child: Text("🐶 Perro")),
                DropdownMenuItem(value: "Gato", child: Text("🐱 Gato")),
                DropdownMenuItem(value: "Otro", child: Text("🐾 Otro")),
              ],
              onChanged: (v) => vm.reporte.tipo = v!,
              validator: (v) =>
                  v == null || v.isEmpty ? "Seleccione un tipo" : null,
            ),
            const SizedBox(height: 12),
            _input(
              "Raza",
              onChanged: (v) => vm.reporte.raza = v,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Ingrese la raza" : null,
            ),
            const SizedBox(height: 12),
            _input(
              "Características especiales",
              maxLines: 3,
              onChanged: (v) => vm.reporte.caracteristicas = v,
            ),
            const SizedBox(height: 24),

            _sectionTitle("🏆 Recompensa de búsqueda (opcional)"),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Si deseas ofrecer una recompensa a quien encuentre tu mascota, completa los campos que desees.",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration:
                        _inputDecoration(
                          "💰 Monto de recompensa (ej. S/. 200)",
                        ).copyWith(
                          prefixIcon: const Icon(
                            Icons.monetization_on_outlined,
                            color: _ReporteEstilo.colorRecompensa,
                          ),
                        ),
                    keyboardType: TextInputType.text,
                    onChanged: (v) => vm.reporte.montoRecompensa = v,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _outlinedNavButton("Atrás", onTap: vm.pasoAnterior),
                _gradientNavButton(
                  "Continuar",
                  onTap: () {
                    if (vm.fotos.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Debes agregar al menos una foto de la mascota",
                          ),
                        ),
                      );
                      return; // Fail fast: sin foto no se avanza de paso.
                    }
                    if (vm.formKeyPaso1.currentState!.validate()) {
                      vm.siguientePaso();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paso 2: ubicación y fecha/hora de la pérdida.
class Paso2Ubicacion extends StatelessWidget {
  const Paso2Ubicacion({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteMascotaVM>();
    final fechaCtrl = TextEditingController(text: vm.reporte.fechaPerdida);
    final horaCtrl = TextEditingController(text: vm.reporte.horaPerdida);
    final direccionCtrl = TextEditingController(text: vm.reporte.direccion);

    return Form(
      key: vm.formKeyPaso2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _sectionTitle("📍 Lugar y momento de pérdida"),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: fechaCtrl,
                    readOnly: true,
                    decoration: _inputDecoration(
                      "Fecha de pérdida",
                    ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha == null)
                        return; // Fail fast: el usuario canceló.

                      vm.reporte.fechaPerdida =
                          "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
                      fechaCtrl.text = vm.reporte.fechaPerdida;
                    },
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Seleccione la fecha" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: horaCtrl,
                    readOnly: true,
                    decoration: _inputDecoration(
                      "Hora aproximada",
                    ).copyWith(suffixIcon: const Icon(Icons.access_time)),
                    onTap: () async {
                      final hora = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (hora == null)
                        return; // Fail fast: el usuario canceló.

                      vm.reporte.horaPerdida =
                          "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
                      horaCtrl.text = vm.reporte.horaPerdida;
                    },
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Seleccione la hora" : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🌍 Seleccionar ubicación en el mapa",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _ReporteEstilo.colorMapa,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Abrir mapa interactivo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _ReporteEstilo.colorMapa,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PantallaMapaOSM(),
                        ),
                      );
                      if (resultado == null)
                        return; // Fail fast: no se seleccionó nada.

                      vm.reporte.direccion =
                          (resultado['direccion'] ?? '') as String;
                      vm.reporte.distrito =
                          (resultado['distrito'] ?? '') as String;
                      vm.reporte.latitud = resultado['lat'] is num
                          ? (resultado['lat'] as num).toDouble()
                          : null;
                      vm.reporte.longitud = resultado['lng'] is num
                          ? (resultado['lng'] as num).toDouble()
                          : null;
                      direccionCtrl.text = vm.reporte.direccion;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (vm.reporte.direccion.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📍 Dirección seleccionada:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vm.reporte.direccion,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        if (vm.reporte.distrito.isNotEmpty)
                          Text(
                            "🏘️ Distrito: ${vm.reporte.distrito}",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: direccionCtrl,
              decoration:
                  _inputDecoration(
                    "Dirección (puedes editar si lo deseas)",
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.map_outlined,
                        color: _ReporteEstilo.colorMapa,
                      ),
                      onPressed: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PantallaMapaOSM(),
                          ),
                        );
                        if (resultado == null)
                          return; // Fail fast: no se seleccionó nada.

                        vm.reporte.direccion = resultado['direccion'] ?? '';
                        vm.reporte.distrito = resultado['distrito'] ?? '';
                        vm.reporte.latitud = resultado['lat'];
                        vm.reporte.longitud = resultado['lng'];
                        direccionCtrl.text = vm.reporte.direccion;
                      },
                    ),
                  ),
              onChanged: (v) => vm.reporte.direccion = v,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Ingrese la dirección" : null,
            ),
            const SizedBox(height: 8),
            if (vm.reporte.distrito.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Distrito: ${vm.reporte.distrito}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            _input(
              "Puntos de referencia",
              onChanged: (v) => vm.reporte.referencia = v,
            ),
            const SizedBox(height: 12),
            _input(
              "¿Cómo se perdió?",
              onChanged: (v) => vm.reporte.circunstancia = v,
              validator: (v) =>
                  (v == null || v.isEmpty) ? "Describa cómo se perdió" : null,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _outlinedNavButton("Atrás", onTap: vm.pasoAnterior),
                _gradientNavButton(
                  "Continuar",
                  onTap: () {
                    if (vm.formKeyPaso2.currentState!.validate()) {
                      vm.siguientePaso();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Paso 3: resumen del reporte y guardado final.
class Paso3Resumen extends StatelessWidget {
  const Paso3Resumen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReporteMascotaVM>();
    final r = vm.reporte;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Resumen del reporte"),
          const SizedBox(height: 10),
          if (r.fotos.isNotEmpty)
            _card(
              child: SizedBox(
                height: _ReporteEstilo.alturaPreviewFotos,
                child: PageView.builder(
                  itemCount: r.fotos.length,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(
                      _ReporteEstilo.radioBordeCard,
                    ),
                    child: _imagenDesdeUrl(r.fotos[i], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _infoRow("🐾 Nombre", r.nombre),
          _infoRow("📌 Tipo", "${r.tipo} • ${r.raza}"),
          _infoRow("📅 Perdido", "${r.fechaPerdida} a las ${r.horaPerdida}"),
          _infoRow("📍 Dirección", r.direccion),
          _infoRow("🧭 Referencia", r.referencia),
          _infoRow("📖 Características especiales", r.caracteristicas),
          if (r.montoRecompensa.isNotEmpty) ...[
            const SizedBox(height: 8),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: _ReporteEstilo.colorRecompensa,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Recompensa de búsqueda",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _ReporteEstilo.colorRecompensaTexto,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoRow("💰 Monto", _formatearMonto(r.montoRecompensa)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _outlinedNavButton("Atrás", onTap: vm.pasoAnterior),
              _gradientNavButton(
                vm.cargando ? "Guardando..." : "Publicar reporte",
                onTap: vm.cargando
                    ? null
                    : () async {
                        final ok = await vm.guardarReporte();
                        if (!ok || !context.mounted) return; // Fail fast.

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Reporte guardado con éxito"),
                          ),
                        );
                        Navigator.pop(context);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
// Widgets de estilo compartidos por los 3 pasos del wizard.
//

Widget _sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  ),
);

Widget _card({required Widget child}) => Card(
  color: Colors.white,
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_ReporteEstilo.radioBordeGrande),
  ),
  child: Padding(padding: const EdgeInsets.all(16), child: child),
);

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.grey[100],
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(_ReporteEstilo.radioBordeCard),
    borderSide: BorderSide(color: Colors.grey[300]!),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(_ReporteEstilo.radioBordeCard),
    borderSide: const BorderSide(color: _ReporteEstilo.colorPrimario, width: 2),
  ),
);

Widget _input(
  String label, {
  required Function(String) onChanged,
  String? Function(String?)? validator,
  int maxLines = 1,
  TextInputType keyboard = TextInputType.text,
}) {
  return TextFormField(
    decoration: _inputDecoration(label),
    maxLines: maxLines,
    keyboardType: keyboard,
    onChanged: onChanged,
    validator: validator,
  );
}

Widget _infoRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(value)),
    ],
  ),
);

Widget _outlinedNavButton(String text, {VoidCallback? onTap}) => OutlinedButton(
  onPressed: onTap,
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.grey[300]!),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_ReporteEstilo.radioBordeCard),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  ),
  child: Text(
    text,
    style: const TextStyle(color: Colors.black87, fontSize: 16),
  ),
);

Widget _gradientNavButton(String text, {VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _ReporteEstilo.duracionAnimacionBoton,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              _ReporteEstilo.colorPrimario,
              _ReporteEstilo.colorSecundario,
            ],
          ),
          borderRadius: BorderRadius.circular(_ReporteEstilo.radioBordeCard),
          boxShadow: [
            BoxShadow(
              color: _ReporteEstilo.colorPrimario.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
