import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../vistamodelo/admin/adminusuario_vm.dart';
import '../../modelo/adminusuario_model.dart';

class PantallaAdminUsuarios extends StatelessWidget {
  const PantallaAdminUsuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminUsuarioVM(),
      child: const _PantallaAdminUsuariosContent(),
    );
  }
}

class _PantallaAdminUsuariosContent extends StatefulWidget {
  const _PantallaAdminUsuariosContent();

  @override
  State<_PantallaAdminUsuariosContent> createState() =>
      _PantallaAdminUsuariosContentState();
}

class _PantallaAdminUsuariosContentState
    extends State<_PantallaAdminUsuariosContent> {
  final TextEditingController _busquedaController = TextEditingController();
  Stream<List<AdminUsuarioModel>>? _usuariosStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recargarStream();
    });
  }

  void _recargarStream() {
    final vistaModelo = Provider.of<AdminUsuarioVM>(context, listen: false);
    setState(() {
      _usuariosStream = vistaModelo.obtenerUsuariosStream();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final vistaModelo = Provider.of<AdminUsuarioVM>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestión de Usuarios',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o teléfono...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A5F), size: 20),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _busquedaController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF1E3A5F).withOpacity(0.15),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: const Color(0xFF1E3A5F).withOpacity(0.15),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (valor) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _usuariosStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<AdminUsuarioModel>>(
                    stream: _usuariosStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 60, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Error: ${snapshot.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _recargarStream,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      var usuarios = snapshot.data ?? [];

                      if (_busquedaController.text.isNotEmpty) {
                        final busqueda =
                            _busquedaController.text.toLowerCase();
                        usuarios = usuarios.where((usuario) {
                          final nombreCompleto =
                              '${usuario.nombre} ${usuario.apellido}'
                                  .toLowerCase();
                          final email = usuario.email.toLowerCase();
                          final telefono = usuario.telefono.toLowerCase();
                          return nombreCompleto.contains(busqueda) ||
                              email.contains(busqueda) ||
                              telefono.contains(busqueda);
                        }).toList();
                      }

                      if (usuarios.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _busquedaController.text.isNotEmpty
                                    ? 'No se encontraron usuarios con "${_busquedaController.text}"'
                                    : 'No hay usuarios registrados',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F).withOpacity(0.06),
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFF1E3A5F),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people,
                                    color: Color(0xFF1E3A5F), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Total: ${usuarios.length} ${usuarios.length == 1 ? 'usuario' : 'usuarios'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A5F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: usuarios.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final usuario = usuarios[index];
                                return _buildUsuarioCard(
                                    context, usuario, vistaModelo);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioCard(
    BuildContext context,
    AdminUsuarioModel usuario,
    AdminUsuarioVM vistaModelo,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1E3A5F).withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _mostrarDetallesUsuario(context, usuario, vistaModelo),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E3A5F),
                        const Color(0xFF2563EB),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      usuario.nombre.isNotEmpty
                          ? usuario.nombre[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${usuario.nombre} ${usuario.apellido}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildBadgeSmall(
                            usuario.activo ? 'Activo' : 'Inactivo',
                            usuario.activo ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              usuario.email,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            usuario.telefono.isEmpty
                                ? 'Sin teléfono'
                                : usuario.telefono,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _formatearFecha(usuario.fechaRegistro),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeSmall(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        texto,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  void _mostrarDetallesUsuario(
    BuildContext context,
    AdminUsuarioModel usuario,
    AdminUsuarioVM vistaModelo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      usuario.nombre.isNotEmpty
                          ? usuario.nombre[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${usuario.nombre} ${usuario.apellido}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        _buildBadgeSmall(usuario.rol, Colors.blue),
                      ],
                    ),
                  ),
                  _buildBadgeSmall(
                    usuario.activo ? 'Activo' : 'Inactivo',
                    usuario.activo ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _infoRow(Icons.email, 'Email', usuario.email),
              _infoRow(Icons.phone, 'Teléfono',
                  usuario.telefono.isEmpty ? 'Sin teléfono' : usuario.telefono),
              _infoRow(Icons.calendar_today, 'Registro',
                  DateFormat('dd/MM/yyyy HH:mm').format(usuario.fechaRegistro)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        usuario.activo ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                      usuario.activo ? Icons.block : Icons.check_circle),
                  label: Text(usuario.activo
                      ? 'Desactivar cuenta'
                      : 'Activar cuenta'),
                  onPressed: () async {
                    Navigator.pop(context);
                    await vistaModelo.cambiarEstadoUsuario(
                        usuario.uid, !usuario.activo);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}