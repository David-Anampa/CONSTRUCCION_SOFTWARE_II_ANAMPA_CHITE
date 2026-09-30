import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
}

// Contenido Principal con Tabs
class _ContenidoPrincipal extends StatefulWidget {
  final AdminReportesVM vm;

  const _ContenidoPrincipal({required this.vm});

  @override
  State<_ContenidoPrincipal> createState() => _ContenidoPrincipalState();
}

class _ContenidoPrincipalState extends State<_ContenidoPrincipal> with SingleTickerProviderStateMixin {
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
                final resultado = await vm.eliminarAvistamiento(avistamiento.id, motivo);
                
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