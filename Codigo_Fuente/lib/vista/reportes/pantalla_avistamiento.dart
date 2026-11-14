import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/reportes/pantalla_mapa_osm.dart';
import 'package:sos_mascotas/vistamodelo/reportes/avistamiento_vm.dart';

// [WIDGETS AUXILIARES (SE MANTIENEN IGUAL)]
// _sectionTitle, _card, _inputDecoration, _input, etc. deben estar definidos
// en el archivo para que compile, pero no se repiten aquí por concisión.

class PantallaAvistamiento extends StatelessWidget {
  const PantallaAvistamiento({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvistamientoVM(),
      child: const _FormularioAvistamiento(),
    );
  }
}

class _FormularioAvistamiento extends StatefulWidget {
  const _FormularioAvistamiento();

  @override
  State<_FormularioAvistamiento> createState() =>
      _FormularioAvistamientoState();
}

class _FormularioAvistamientoState extends State<_FormularioAvistamiento> {
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController direccionCtrl;
  late TextEditingController fechaCtrl;
  late TextEditingController horaCtrl;
  late TextEditingController descripcionCtrl;

  // 🛑 SOLO ALMACENAMOS LA RUTA DEL ARCHIVO TEMPORAL PARA LA VISTA PREVIA
  File? fotoSeleccionada;

  @override
  void initState() {
    super.initState();
    direccionCtrl = TextEditingController();
    fechaCtrl = TextEditingController();
    horaCtrl = TextEditingController();
    descripcionCtrl = TextEditingController();
  }

  // 🟢 Diálogo para confirmar la eliminación de la foto (Adaptado del Paso1Mascota)
  Future<void> _mostrarDialogoEliminar(
    BuildContext context,
    AvistamientoVM vm,
    File file, // Usamos File ya que la vista usa el objeto local para preview
  ) async {
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
                // 🛑 Lógica para limpiar la foto en el VM y el estado local
                vm.avistamiento.foto = ""; // Limpia la URL en el VM
                setState(() {
                  fotoSeleccionada = null; // Limpia la imagen local
                });
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

  // 📸 Lógica unificada para seleccionar y subir foto
  Future<void> _seleccionarYSubirFoto(
    BuildContext context,
    AvistamientoVM vm,
    ImageSource source,
  ) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);

    try {
      // 1. Muestra mensaje de análisis
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Analizando imagen... 🧠"),
          backgroundColor: Colors.blueAccent,
          duration: Duration(seconds: 2),
        ),
      );

      // 2. Subir y validar (vm.subirFoto lanza excepción si falla TFLite)
      final url = await vm.subirFoto(file);

      // 3. Si es exitoso, actualizar el estado local y el VM
      vm.avistamiento.foto = url;
      setState(() {
        fotoSeleccionada =
            file; // 🟢 Usamos el File local para mostrar la imagen
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Imagen válida y subida correctamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.redAccent,
        ),
      );
      // ⚠️ Si falla, fotoSeleccionada sigue siendo null/antiguo valor.
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AvistamientoVM>();

    // 🛑 Condición central: ¿Hay una foto en el estado local?
    final bool fotoPrincipalDisponible = fotoSeleccionada != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Registrar Avistamiento",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 FOTO(S)
              _sectionTitle("📸 Foto del avistamiento"),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🖼️ CONTENEDOR PRINCIPAL DE FOTO
                    GestureDetector(
                      // 🛑 LongPress para eliminar la foto actual
                      onLongPress: fotoPrincipalDisponible
                          ? () => _mostrarDialogoEliminar(
                              context,
                              vm,
                              fotoSeleccionada!,
                            )
                          : null,

                      // Tap para seleccionar/reemplazar foto
                      onTap: () => _seleccionarYSubirFoto(
                        context,
                        vm,
                        ImageSource.gallery,
                      ),

                      child: Container(
                        width: double.infinity,
                        // Ajustar padding y decoración al estilo de ReporteMascota
                        padding: EdgeInsets.symmetric(
                          vertical: fotoPrincipalDisponible ? 0 : 30,
                          horizontal: fotoPrincipalDisponible ? 0 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: fotoPrincipalDisponible
                              ? Colors.transparent
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: fotoPrincipalDisponible
                                ? Colors.transparent
                                : Colors.grey[300]!,
                            width: fotoPrincipalDisponible ? 0 : 1.2,
                          ),
                        ),

                        child: fotoPrincipalDisponible
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    // Imagen Grande (Base, usa BoxFit.fitWidth para evitar recortes)
                                    Image.file(
                                      fotoSeleccionada!,
                                      width: double.infinity,
                                      fit:
                                          BoxFit.fitWidth, // 🎯 Ajuste al ancho
                                    ),
                                    // Botón de Cierre VISIBLE para la imagen principal
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _mostrarDialogoEliminar(
                                          context,
                                          vm,
                                          fotoSeleccionada!,
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
                                // Placeholder si no hay foto
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
                                    "Agregar foto del avistamiento",
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

                    // Botones cámara y galería
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cámara (foto)
                        ElevatedButton.icon(
                          onPressed: vm.cargando
                              ? null
                              : () => _seleccionarYSubirFoto(
                                  context,
                                  vm,
                                  ImageSource.camera,
                                ),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text("Cámara"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            backgroundColor: const Color(0xFFFFF3E0),
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
                        // Galería (foto)
                        ElevatedButton.icon(
                          onPressed: vm.cargando
                              ? null
                              : () => _seleccionarYSubirFoto(
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
                            foregroundColor: Colors.orange.shade700,
                            backgroundColor: const Color(0xFFFFF8E1),
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

              const SizedBox(height: 20),

              // 📍 DIRECCIÓN
              _sectionTitle("📍 Ubicación del avistamiento"),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: direccionCtrl,
                      readOnly: true,
                      decoration: _inputDecoration("Seleccionar desde el mapa")
                          .copyWith(
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.map_outlined,
                                color: Colors.orange,
                              ),
                              onPressed: () async {
                                final resultado = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaMapaOSM(),
                                  ),
                                );
                                if (resultado != null) {
                                  vm.actualizarUbicacion(
                                    direccion: resultado['direccion'] ?? '',
                                    distrito: resultado['distrito'] ?? '',
                                    latitud: resultado['lat'],
                                    longitud: resultado['lng'],
                                  );
                                  direccionCtrl.text =
                                      resultado['direccion'] ?? '';
                                }
                              },
                            ),
                          ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Seleccione una ubicación"
                          : null,
                    ),
                    const SizedBox(height: 8),
                    if (vm.avistamiento.distrito.isNotEmpty)
                      Text(
                        "Distrito: ${vm.avistamiento.distrito}",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📅 FECHA y HORA
              _sectionTitle("🕓 Fecha y hora del avistamiento"),
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: fechaCtrl,
                        readOnly: true,
                        decoration: _inputDecoration("Fecha").copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                        ),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (fecha != null) {
                            vm.avistamiento.fechaAvistamiento =
                                "${fecha.day}/${fecha.month}/${fecha.year}";
                            fechaCtrl.text = vm.avistamiento.fechaAvistamiento;
                          }
                        },
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Seleccione fecha"
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: horaCtrl,
                        readOnly: true,
                        decoration: _inputDecoration("Hora").copyWith(
                          suffixIcon: const Icon(
                            Icons.access_time,
                            color: Colors.orange,
                          ),
                        ),
                        onTap: () async {
                          final hora = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (hora != null) {
                            vm.avistamiento.horaAvistamiento =
                                "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
                            horaCtrl.text = vm.avistamiento.horaAvistamiento;
                          }
                        },
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Seleccione hora" : null,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📝 DESCRIPCIÓN
              _sectionTitle("📝 Descripción del avistamiento"),
              _card(
                child: TextFormField(
                  controller: descripcionCtrl,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    "Ejemplo: perro marrón pequeño, se encontraba cerca del parque, parecía desorientado...",
                  ),
                  onChanged: (v) => vm.setDescripcion(v),
                  validator: (v) => (v == null || v.isEmpty)
                      ? "Ingrese una descripción"
                      : null,
                ),
              ),

              const SizedBox(height: 30),

              // 🔘 BOTÓN GUARDAR
              Center(
                child: GestureDetector(
                  onTap: vm.cargando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          if (vm.avistamiento.foto.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Debes subir una foto antes de guardar.",
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final ok = await vm.guardarAvistamiento();
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "✅ Avistamiento guardado correctamente.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: vm.cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Guardar Avistamiento",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🎨 Widgets auxiliares
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
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  child: Padding(padding: const EdgeInsets.all(16), child: child),
);

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  filled: true,
  fillColor: Colors.grey[100],
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: Colors.grey[300]!),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
  ),
);
