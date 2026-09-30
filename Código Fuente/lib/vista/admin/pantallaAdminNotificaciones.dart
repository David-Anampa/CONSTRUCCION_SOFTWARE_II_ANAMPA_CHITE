// vista/admin/PantallaAdminNotificaciones.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/admin/AdminNotificaciones_vm.dart';
import '../../modelo/AdminNotificacion.dart';

class PantallaAdminNotificaciones extends StatefulWidget {
  const PantallaAdminNotificaciones({super.key});

  @override
  State<PantallaAdminNotificaciones> createState() => _PantallaAdminNotificacionesState();
}

class _PantallaAdminNotificacionesState extends State<PantallaAdminNotificaciones> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = context.read<AdminNotificacionesVM>();
      vm.cargarUsuarios();
      vm.escucharHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminNotificacionesVM>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.lightBlue[50], // FONDO CELESTE CLARO
        appBar: AppBar(
          title: const Text("Gestión de Notificaciones"),
          backgroundColor: Colors.purple[300], // MORADO MÁS CLARO
          foregroundColor: Colors.white, // LETRAS BLANCAS
          bottom: const TabBar(
            labelColor: Colors.white, // TEXTO SELECCIONADO BLANCO
            unselectedLabelColor: Colors.white70, // TEXTO NO SELECCIONADO
            indicatorColor: Colors.white, // INDICADOR BLANCO
            tabs: [
              Tab(icon: Icon(Icons.send), text: "Enviar"),
              Tab(icon: Icon(Icons.history), text: "Historial"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEnviarTab(vm),
            _buildHistorialTab(vm),
          ],
        ),
      ),
    );
  }

  // 📤 TAB ENVIAR NOTIFICACIÓN
  Widget _buildEnviarTab(AdminNotificacionesVM vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PLANTILLAS (Ahora con campo manual)
          const Text(
            "Crear mensaje",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  "Plantillas rápidas:",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlantillaNotificacion.obtenerPlantillas().map((plantilla) {
              return ActionChip(
                label: Text(plantilla.nombre),
                avatar: Text(plantilla.icono),
                onPressed: () => vm.aplicarPlantilla(plantilla),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // TÍTULO
          TextField(
            controller: vm.tituloController,
            decoration: const InputDecoration(
              labelText: "Título",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // MENSAJE
          TextField(
            controller: vm.mensajeController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Mensaje",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // TIPO DE ENVÍO
          DropdownButtonFormField<String>(
            value: vm.tipoEnvio,
            decoration: const InputDecoration(
              labelText: "Tipo de envío",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            items: const [
              DropdownMenuItem(value: "todos", child: Text("Todos los usuarios")),
              DropdownMenuItem(value: "individual", child: Text("Usuario individual")),
              DropdownMenuItem(value: "grupo", child: Text("Grupo de usuarios")),
            ],
            onChanged: (value) {
              if (value != null) vm.cambiarTipoEnvio(value);
            },
          ),
          
          const SizedBox(height: 16),
          
          // SELECTOR DE USUARIOS
          if (vm.tipoEnvio == "individual")
            _buildSelectorIndividual(vm)
          else if (vm.tipoEnvio == "grupo")
            _buildSelectorGrupo(vm),
          
          const SizedBox(height: 16),
          
          // PRIORIDAD
          DropdownButtonFormField<String>(
            value: vm.prioridad,
            decoration: const InputDecoration(
              labelText: "Prioridad",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: const [
              DropdownMenuItem(value: "alta", child: Text("🔴 Alta")),
              DropdownMenuItem(value: "media", child: Text("🟡 Media")),
              DropdownMenuItem(value: "baja", child: Text("🟢 Baja")),
            ],
            onChanged: (value) {
              if (value != null) vm.cambiarPrioridad(value);
            },
          ),
          
          const SizedBox(height: 24),
          
          // BOTÓN ENVIAR
          ElevatedButton.icon(
            onPressed: vm.enviando
                ? null
                : () async {
                    final resultado = await vm.enviarNotificacion();
                    if (!mounted) return;
                    
                    if (resultado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Notificación enviada correctamente"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final error = vm.validarFormulario();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ ${error ?? 'Error al enviar'}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            icon: vm.enviando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send),
            label: Text(vm.enviando ? "Enviando..." : "Enviar Notificación"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // 👤 SELECTOR INDIVIDUAL CON BUSCADOR
  Widget _buildSelectorIndividual(AdminNotificacionesVM vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador de usuarios
        TextField(
          decoration: const InputDecoration(
            labelText: "Buscar usuario",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            hintText: "Escribe el nombre del usuario...",
          ),
          onChanged: (value) => vm.buscarUsuario(value),
        ),
        const SizedBox(height: 12),
        
        // Usuario seleccionado
        if (vm.usuarioSeleccionado != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    vm.obtenerUsuarioPorId(vm.usuarioSeleccionado!)['nombre']
                        .toString()[0]
                        .toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Usuario seleccionado:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vm.obtenerUsuarioPorId(vm.usuarioSeleccionado!)['nombre'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        vm.obtenerUsuarioPorId(vm.usuarioSeleccionado!)['email'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => vm.seleccionarUsuario(null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Lista de usuarios filtrados
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: vm.usuariosFiltrados.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "No se encontraron usuarios",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = vm.usuariosFiltrados[index];
                    final seleccionado = vm.usuarioSeleccionado == usuario['id'];
                    
                    return ListTile(
                      selected: seleccionado,
                      selectedTileColor: Colors.purple.withOpacity(0.1),
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Text(
                          usuario['nombre'].toString()[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        usuario['nombre'],
                        style: TextStyle(
                          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(usuario['email']),
                      trailing: seleccionado
                          ? const Icon(Icons.check_circle, color: Colors.purple)
                          : null,
                      onTap: () => vm.seleccionarUsuario(usuario['id']),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 👥 SELECTOR GRUPO CON BUSCADOR
  Widget _buildSelectorGrupo(AdminNotificacionesVM vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador de usuarios
        TextField(
          decoration: const InputDecoration(
            labelText: "Buscar usuarios",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            hintText: "Escribe el nombre del usuario...",
          ),
          onChanged: (value) => vm.buscarUsuario(value),
        ),
        const SizedBox(height: 12),
        
        // Usuarios seleccionados
        if (vm.usuariosSeleccionados.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      "Usuarios seleccionados: ${vm.usuariosSeleccionados.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => vm.limpiarSeleccionGrupo(),
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text("Limpiar"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                ...vm.usuariosSeleccionados.map((usuarioId) {
                  final usuario = vm.obtenerUsuarioPorId(usuarioId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple,
                          radius: 16,
                          child: Text(
                            usuario['nombre'].toString()[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario['nombre'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                usuario['email'],
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                          onPressed: () => vm.toggleUsuarioGrupo(usuarioId),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Container con lista de usuarios
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: vm.usuariosFiltrados.isEmpty
              ? const Center(
                  child: Text(
                    "No se encontraron usuarios",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: vm.usuariosFiltrados.length,
                  itemBuilder: (context, index) {
                    final usuario = vm.usuariosFiltrados[index];
                    final seleccionado = vm.usuariosSeleccionados.contains(usuario['id']);
                    
                    return CheckboxListTile(
                      value: seleccionado,
                      title: Text(usuario['nombre']),
                      subtitle: Text(usuario['email']),
                      secondary: CircleAvatar(
                        backgroundColor: seleccionado ? Colors.purple : Colors.grey,
                        child: Text(
                          usuario['nombre'].toString()[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      onChanged: (_) => vm.toggleUsuarioGrupo(usuario['id']),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 📜 TAB HISTORIAL CON BOTONES VER Y EDITAR
  Widget _buildHistorialTab(AdminNotificacionesVM vm) {
    if (vm.historial.isEmpty) {
      return const Center(
        child: Text(
          "No hay notificaciones enviadas aún 📭",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: vm.historial.length,
      itemBuilder: (context, index) {
        final notif = vm.historial[index];
        
        // Formatear fecha
        final fecha = notif.fechaEnvio;
        final hora = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
        final dia = "${fecha.day}/${fecha.month}/${fecha.year}";
        
        // Color según prioridad
        Color colorPrioridad = Colors.grey;
        if (notif.prioridad == "alta") colorPrioridad = Colors.red;
        if (notif.prioridad == "media") colorPrioridad = Colors.orange;
        if (notif.prioridad == "baja") colorPrioridad = Colors.green;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FILA PRINCIPAL CON INFO
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: colorPrioridad,
                      child: Text(
                        notif.totalEnviados.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.titulo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.mensaje,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$dia - $hora | ${notif.tipo.toUpperCase()}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // FILA DE BOTONES: VER Y ELIMINAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // BOTÓN VER
                    TextButton.icon(
                      onPressed: () {
                        _mostrarDetalleNotificacion(context, notif, vm);
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text("Ver"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // BOTÓN ELIMINAR
                    TextButton.icon(
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirmar eliminación"),
                            content: const Text("¿Deseas eliminar esta notificación del historial?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmar == true && notif.id != null) {
                          await vm.eliminarNotificacion(notif.id!);
                        }
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text("Eliminar"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FUNCIÓN PARA MOSTRAR DETALLE COMPLETO DE LA NOTIFICACIÓN
  void _mostrarDetalleNotificacion(BuildContext context, AdminNotificacion notif, AdminNotificacionesVM vm) {
    final fecha = notif.fechaEnvio;
    final hora = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
    final dia = "${fecha.day}/${fecha.month}/${fecha.year}";
    
    // Obtener los destinatarios
    String destinatarios = "";
    if (notif.tipo == "todos") {
      destinatarios = "Todos los usuarios";
    } else if (notif.tipo == "individual" && notif.destinatarioId != null) {
      final usuario = vm.obtenerUsuarioPorId(notif.destinatarioId!);
      destinatarios = usuario['nombre'];
    } else if (notif.tipo == "grupo" && notif.destinatariosIds != null && notif.destinatariosIds!.isNotEmpty) {
      final nombres = notif.destinatariosIds!.map((id) => vm.obtenerUsuarioPorId(id)['nombre']).toList();
      destinatarios = nombres.join(", ");
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.purple),
            const SizedBox(width: 8),
            const Expanded(child: Text("Detalle de Notificación")),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleRow("Título:", notif.titulo, Icons.title),
              const SizedBox(height: 12),
              _buildDetalleRow("Mensaje:", notif.mensaje, Icons.message),
              const SizedBox(height: 12),
              _buildDetalleRow("Fecha:", "$dia a las $hora", Icons.calendar_today),
              const SizedBox(height: 12),
              _buildDetalleRow("Tipo:", notif.tipo.toUpperCase(), Icons.send),
              const SizedBox(height: 12),
              _buildDetalleRow("Prioridad:", notif.prioridad.toUpperCase(), Icons.flag),
              const SizedBox(height: 12),
              _buildDetalleRow("Total enviados:", notif.totalEnviados.toString(), Icons.people),
              const SizedBox(height: 12),
              _buildDetalleRow("Destinatarios:", destinatarios, Icons.person),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String valor, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.purple[300]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AdminNotificacionesVM? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm ??= context.read<AdminNotificacionesVM>();
  }

  @override
  void dispose() {
    _vm?.detenerEscucha();
    super.dispose();
  }
}