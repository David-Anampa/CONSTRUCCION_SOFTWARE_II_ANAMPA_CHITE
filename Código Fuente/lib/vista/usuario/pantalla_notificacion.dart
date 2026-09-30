import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../vistamodelo/notificacion/notificacion_vm.dart';
import '../../modelo/notificacion.dart';

class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones> {
  NotificacionVM? _vm;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vm = context.read<NotificacionVM>();
      vm.escucharNotificaciones();
      await vm.marcarTodasComoLeidas();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm ??= context.read<NotificacionVM>();
  }

  @override
  void dispose() {
    _vm?.detenerEscucha();
    super.dispose();
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '--';
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reporte':
        return Icons.pets;
      case 'avistamiento':
        return Icons.visibility;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'reporte':
        return Colors.purple;
      case 'avistamiento':
        return Colors.orange;
      case 'chat':
        return Colors.blue;
      case 'admin':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificacionVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Notificaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (vm.noLeidas > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vm.noLeidas}',
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (vm.noLeidas > 0)
            TextButton.icon(
              onPressed: () async {
                await vm.marcarTodasComoLeidas();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todas marcadas como leídas ✓'),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Leer todas',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: vm.notificaciones.isEmpty
          ? _buildEstadoVacio()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: vm.notificaciones.length,
              itemBuilder: (context, index) {
                final Notificacion n = vm.notificaciones[index];
                return _buildTarjetaNotificacion(context, n, vm);
              },
            ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 52,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí aparecerán las alertas de\nmascotas perdidas y avistamientos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaNotificacion(
    BuildContext context,
    Notificacion n,
    NotificacionVM vm,
  ) {
    final esNoLeida = !n.leido;
    final color = _colorPorTipo(n.tipo);
    final icono = _iconoPorTipo(n.tipo);

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        await vm.eliminarNotificacion(n.id);
      },
      child: GestureDetector(
        onTap: () async {
          if (esNoLeida) {
            await vm.marcarComoLeida(n.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: esNoLeida ? Colors.teal.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: esNoLeida
                ? Border.all(color: Colors.teal.shade200, width: 1.5)
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono con color según tipo
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: color, size: 24),
                ),
                const SizedBox(width: 14),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.titulo,
                              style: TextStyle(
                                fontWeight: esNoLeida
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (esNoLeida)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.mensaje,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatearFecha(n.fecha),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (esNoLeida) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => vm.marcarComoLeida(n.id),
                              child: Text(
                                'Marcar como leída',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
