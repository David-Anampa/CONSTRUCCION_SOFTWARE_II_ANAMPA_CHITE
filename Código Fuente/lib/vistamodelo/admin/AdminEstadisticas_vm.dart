// vistamodelo/admin/AdminEstadisticas_vm.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelo/AdminEstadisticas.dart';

class AdminEstadisticasVM extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _disposed =
      false; // ✅ Guard para evitar notifyListeners después de dispose

  bool _cargando = false;
  bool get cargando => _cargando;

  EstadisticasGenerales _estadisticasGenerales = EstadisticasGenerales();
  EstadisticasGenerales get estadisticasGenerales => _estadisticasGenerales;

  List<EstadisticasPorMes> _estadisticasMensuales = [];
  List<EstadisticasPorMes> get estadisticasMensuales => _estadisticasMensuales;

  List<EstadisticasPorDia> _estadisticasPorDia = [];
  List<EstadisticasPorDia> get estadisticasPorDia => _estadisticasPorDia;

  List<EstadisticasPorTipo> _estadisticasPorTipoMascota = [];
  List<EstadisticasPorTipo> get estadisticasPorTipoMascota =>
      _estadisticasPorTipoMascota;

  List<EstadisticasPorDistrito> _estadisticasPorDistrito = [];
  List<EstadisticasPorDistrito> get estadisticasPorDistrito =>
      _estadisticasPorDistrito;

  List<EstadisticasPorUbicacion> _estadisticasPorUbicacion = [];
  List<EstadisticasPorUbicacion> get estadisticasPorUbicacion =>
      _estadisticasPorUbicacion;

  RangoFechas _rangoFechas = RangoFechas.ultimoMes();
  RangoFechas get rangoFechas => _rangoFechas;

  String _filtroResumen = "general";
  String get filtroResumen => _filtroResumen;

  // ✅ Override dispose para marcar como disposed
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ✅ Método seguro que verifica antes de notificar
  void _notificarSiActivo() {
    if (!_disposed) notifyListeners();
  }

  Future<void> cargarEstadisticas() async {
    try {
      _cargando = true;
      _notificarSiActivo();

      await Future.wait([
        _cargarEstadisticasGenerales(),
        _cargarEstadisticasMensuales(),
        _cargarEstadisticasPorDia(),
        _cargarEstadisticasPorTipo(),
        _cargarEstadisticasPorDistrito(),
        _cargarEstadisticasPorUbicacion(),
      ]);

      _cargando = false;
      _notificarSiActivo();
    } catch (e) {
      _cargando = false;
      _notificarSiActivo();
      debugPrint("❌ Error cargando estadísticas: $e");
    }
  }

  Future<void> _cargarEstadisticasGenerales() async {
    try {
      final usuariosSnapshot = await _firestore
          .collection("usuarios")
          .where("rol", isNotEqualTo: "admin")
          .get();
      final totalUsuarios = usuariosSnapshot.docs.length;

      final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
      final usuariosActivos = usuariosSnapshot.docs.where((doc) {
        final data = doc.data();
        if (data["fechaRegistro"] != null) {
          final fecha = (data["fechaRegistro"] as Timestamp).toDate();
          return fecha.isAfter(hace30Dias);
        }
        return false;
      }).length;

      final reportesSnapshot = await _firestore
          .collection("reportes_mascotas")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      int reportesPerdidos = 0;
      int reportesEncontrados = 0;

      for (var doc in reportesSnapshot.docs) {
        final estado = (doc.data()["estado"] ?? "").toString().toUpperCase();
        if (estado == "PERDIDO") {
          reportesPerdidos++;
        } else if (estado == "ENCONTRADO") {
          reportesEncontrados++;
        }
      }

      final avistamientosSnapshot = await _firestore
          .collection("avistamientos")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      if (_disposed) return; // ✅ Verificar antes de asignar

      _estadisticasGenerales = EstadisticasGenerales(
        totalUsuarios: totalUsuarios,
        usuariosActivos: usuariosActivos,
        usuariosInactivos: totalUsuarios - usuariosActivos,
        totalReportes: reportesSnapshot.docs.length,
        reportesPerdidos: reportesPerdidos,
        reportesEncontrados: reportesEncontrados,
        totalAvistamientos: avistamientosSnapshot.docs.length,
      );
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas generales: $e");
    }
  }

  Future<void> _cargarEstadisticasMensuales() async {
    try {
      final List<EstadisticasPorMes> resultado = [];
      final ahora = DateTime.now();

      for (int i = 5; i >= 0; i--) {
        final mes = DateTime(ahora.year, ahora.month - i, 1);
        final siguienteMes = DateTime(ahora.year, ahora.month - i + 1, 1);

        final reportes = await _firestore
            .collection("reportes_mascotas")
            .where("fechaRegistro", isGreaterThanOrEqualTo: mes)
            .where("fechaRegistro", isLessThan: siguienteMes)
            .get();

        final avistamientos = await _firestore
            .collection("avistamientos")
            .where("fechaRegistro", isGreaterThanOrEqualTo: mes)
            .where("fechaRegistro", isLessThan: siguienteMes)
            .get();

        final usuarios = await _firestore
            .collection("usuarios")
            .where("fechaRegistro", isGreaterThanOrEqualTo: mes)
            .where("fechaRegistro", isLessThan: siguienteMes)
            .get();

        resultado.add(
          EstadisticasPorMes(
            mes: _obtenerNombreMes(mes.month),
            reportes: reportes.docs.length,
            avistamientos: avistamientos.docs.length,
            usuarios: usuarios.docs.length,
          ),
        );
      }

      if (_disposed) return; // ✅ Verificar antes de asignar
      _estadisticasMensuales = resultado;
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas mensuales: $e");
    }
  }

  Future<void> _cargarEstadisticasPorDia() async {
    try {
      final diasSemana = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"];
      final contadores = List<int>.filled(7, 0);

      final reportes = await _firestore
          .collection("reportes_mascotas")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      for (var doc in reportes.docs) {
        final fecha = (doc.data()["fechaRegistro"] as Timestamp).toDate();
        contadores[fecha.weekday - 1]++;
      }

      if (_disposed) return; // ✅ Verificar antes de asignar
      _estadisticasPorDia = List.generate(
        7,
        (i) => EstadisticasPorDia(dia: diasSemana[i], cantidad: contadores[i]),
      );
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas por día: $e");
    }
  }

  Future<void> _cargarEstadisticasPorTipo() async {
    try {
      final reportes = await _firestore
          .collection("reportes_mascotas")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      final Map<String, int> contadores = {};
      for (var doc in reportes.docs) {
        final tipo = doc.data()["tipo"] ?? "Otro";
        contadores[tipo] = (contadores[tipo] ?? 0) + 1;
      }

      final total = reportes.docs.length;
      final resultado = contadores.entries.map((entry) {
        return EstadisticasPorTipo(
          tipo: entry.key,
          cantidad: entry.value,
          porcentaje: total > 0 ? (entry.value / total * 100) : 0.0,
        );
      }).toList()..sort((a, b) => b.cantidad.compareTo(a.cantidad));

      if (_disposed) return; // ✅ Verificar antes de asignar
      _estadisticasPorTipoMascota = resultado;
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas por tipo: $e");
    }
  }

  Future<void> _cargarEstadisticasPorDistrito() async {
    try {
      final reportes = await _firestore
          .collection("reportes_mascotas")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      final avistamientos = await _firestore
          .collection("avistamientos")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      final Map<String, EstadisticasPorDistrito> distritos = {};

      for (var doc in reportes.docs) {
        final distrito = doc.data()["distrito"] ?? "Sin distrito";
        distritos[distrito] ??= EstadisticasPorDistrito(distrito: distrito);
        distritos[distrito]!.reportes++;
      }

      for (var doc in avistamientos.docs) {
        final distrito = doc.data()["distrito"] ?? "Sin distrito";
        distritos[distrito] ??= EstadisticasPorDistrito(distrito: distrito);
        distritos[distrito]!.avistamientos++;
      }

      var resultado = distritos.values.toList()
        ..sort(
          (a, b) => (b.reportes + b.avistamientos).compareTo(
            a.reportes + a.avistamientos,
          ),
        );

      if (resultado.length > 10) resultado = resultado.sublist(0, 10);

      if (_disposed) return; // ✅ Verificar antes de asignar
      _estadisticasPorDistrito = resultado;
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas por distrito: $e");
    }
  }

  Future<void> _cargarEstadisticasPorUbicacion() async {
    try {
      final reportes = await _firestore
          .collection("reportes_mascotas")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      final avistamientos = await _firestore
          .collection("avistamientos")
          .where("fechaRegistro", isGreaterThanOrEqualTo: _rangoFechas.inicio)
          .where("fechaRegistro", isLessThanOrEqualTo: _rangoFechas.fin)
          .get();

      final Map<String, EstadisticasPorUbicacion> ubicaciones = {};

      for (var doc in reportes.docs) {
        final data = doc.data();
        final ubicacion =
            data["ubicacion"] ?? data["direccion"] ?? "Sin ubicación";
        final distrito = data["distrito"] ?? "Sin distrito";
        if (ubicacion == "Sin ubicación") continue;
        final key = "$distrito|$ubicacion";
        ubicaciones[key] ??= EstadisticasPorUbicacion(
          ubicacion: ubicacion,
          distrito: distrito,
        );
        ubicaciones[key]!.reportes++;
      }

      for (var doc in avistamientos.docs) {
        final data = doc.data();
        final ubicacion =
            data["ubicacion"] ?? data["direccion"] ?? "Sin ubicación";
        final distrito = data["distrito"] ?? "Sin distrito";
        if (ubicacion == "Sin ubicación") continue;
        final key = "$distrito|$ubicacion";
        ubicaciones[key] ??= EstadisticasPorUbicacion(
          ubicacion: ubicacion,
          distrito: distrito,
        );
        ubicaciones[key]!.avistamientos++;
      }

      var resultado = ubicaciones.values.toList()
        ..sort(
          (a, b) => (b.reportes + b.avistamientos).compareTo(
            a.reportes + a.avistamientos,
          ),
        );

      if (resultado.length > 10) resultado = resultado.sublist(0, 10);

      if (_disposed) return; // ✅ Verificar antes de asignar
      _estadisticasPorUbicacion = resultado;
    } catch (e) {
      debugPrint("❌ Error cargando estadísticas por ubicación: $e");
    }
  }

  void cambiarRangoFechas(String periodo) {
    switch (periodo) {
      case "semana":
        _rangoFechas = RangoFechas.ultimaSemana();
        break;
      case "mes":
        _rangoFechas = RangoFechas.ultimoMes();
        break;
      case "trimestre":
        _rangoFechas = RangoFechas.ultimoTrimestre();
        break;
      case "anio":
        _rangoFechas = RangoFechas.ultimoAnio();
        break;
    }
    cargarEstadisticas();
  }

  void cambiarRangoPersonalizado(DateTime inicio, DateTime fin) {
    _rangoFechas = RangoFechas(inicio: inicio, fin: fin);
    cargarEstadisticas();
  }

  void cambiarFiltroResumen(String filtro) {
    _filtroResumen = filtro;
    _notificarSiActivo();
  }

  String generarResumen() {
    switch (_filtroResumen) {
      case "general":
        return _generarResumenGeneral();
      case "usuarios":
        return _generarResumenUsuarios();
      case "reportes":
        return _generarResumenReportes();
      case "avistamientos":
        return _generarResumenAvistamientos();
      case "ubicaciones":
        return _generarResumenUbicaciones();
      default:
        return "Selecciona un tipo de resumen";
    }
  }

  String _generarResumenGeneral() {
    final periodoTexto = _obtenerTextoPeriodo();
    return """
📊 RESUMEN GENERAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 PERÍODO: $periodoTexto
   ${_formatearFecha(_rangoFechas.inicio)} - ${_formatearFecha(_rangoFechas.fin)}

👥 USUARIOS
• Total de usuarios registrados: ${_estadisticasGenerales.totalUsuarios}
• Usuarios activos (últimos 30 días): ${_estadisticasGenerales.usuariosActivos}
• Usuarios inactivos: ${_estadisticasGenerales.usuariosInactivos}

🐾 REPORTES
• Total de reportes: ${_estadisticasGenerales.totalReportes}
• Mascotas perdidas: ${_estadisticasGenerales.reportesPerdidos}
• Mascotas encontradas: ${_estadisticasGenerales.reportesEncontrados}

👁️ AVISTAMIENTOS
• Total de avistamientos: ${_estadisticasGenerales.totalAvistamientos}

📈 TENDENCIA
• Día con más actividad: ${_estadisticasPorDia.isNotEmpty ? _estadisticasPorDia.reduce((a, b) => a.cantidad > b.cantidad ? a : b).dia : "N/A"}
• Tipo de mascota más reportado: ${_estadisticasPorTipoMascota.isNotEmpty ? _estadisticasPorTipoMascota.first.tipo : "N/A"}
• Distrito con más reportes: ${_estadisticasPorDistrito.isNotEmpty ? _estadisticasPorDistrito.first.distrito : "N/A"}
    """;
  }

  String _generarResumenUsuarios() {
    final tasaActividad = _estadisticasGenerales.totalUsuarios > 0
        ? (_estadisticasGenerales.usuariosActivos /
                  _estadisticasGenerales.totalUsuarios *
                  100)
              .toStringAsFixed(1)
        : "0.0";
    return """
👥 RESUMEN DE USUARIOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 ESTADÍSTICAS GENERALES
• Total de usuarios: ${_estadisticasGenerales.totalUsuarios}
• Usuarios activos: ${_estadisticasGenerales.usuariosActivos}
• Usuarios inactivos: ${_estadisticasGenerales.usuariosInactivos}
• Tasa de actividad: $tasaActividad%

📈 CRECIMIENTO MENSUAL
${_estadisticasMensuales.map((e) => "• ${e.mes}: +${e.usuarios} usuarios").join("\n")}

💡 CONCLUSIÓN
El sistema cuenta con ${_estadisticasGenerales.totalUsuarios} usuarios registrados, de los cuales ${_estadisticasGenerales.usuariosActivos} han estado activos en los últimos 30 días.
    """;
  }

  String _generarResumenReportes() {
    final tasaExito = _estadisticasGenerales.totalReportes > 0
        ? (_estadisticasGenerales.reportesEncontrados /
                  _estadisticasGenerales.totalReportes *
                  100)
              .toStringAsFixed(1)
        : "0.0";
    return """
🐾 RESUMEN DE REPORTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 ESTADÍSTICAS GENERALES
• Total de reportes: ${_estadisticasGenerales.totalReportes}
• Mascotas perdidas: ${_estadisticasGenerales.reportesPerdidos}
• Mascotas encontradas: ${_estadisticasGenerales.reportesEncontrados}
• Tasa de éxito: $tasaExito%

🐶 POR TIPO DE MASCOTA
${_estadisticasPorTipoMascota.map((e) => "• ${e.tipo}: ${e.cantidad} (${e.porcentaje.toStringAsFixed(1)}%)").join("\n")}

📅 DÍAS CON MÁS REPORTES
${_estadisticasPorDia.map((e) => "• ${e.dia}: ${e.cantidad} reportes").join("\n")}

💡 CONCLUSIÓN
Se han reportado ${_estadisticasGenerales.totalReportes} mascotas, con una tasa de recuperación del $tasaExito%. El tipo más reportado es ${_estadisticasPorTipoMascota.isNotEmpty ? _estadisticasPorTipoMascota.first.tipo : "N/A"}.
    """;
  }

  String _generarResumenAvistamientos() {
    final promedioPorDia = (_estadisticasGenerales.totalAvistamientos / 7)
        .toStringAsFixed(1);
    return """
👁️ RESUMEN DE AVISTAMIENTOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 ESTADÍSTICAS GENERALES
• Total de avistamientos: ${_estadisticasGenerales.totalAvistamientos}
• Promedio por día: $promedioPorDia

📍 TOP 5 DISTRITOS CON MÁS AVISTAMIENTOS
${_estadisticasPorDistrito.take(5).map((e) => "• ${e.distrito}: ${e.avistamientos} avistamientos").join("\n")}

📈 TENDENCIA MENSUAL
${_estadisticasMensuales.map((e) => "• ${e.mes}: ${e.avistamientos} avistamientos").join("\n")}

💡 CONCLUSIÓN
Se han registrado ${_estadisticasGenerales.totalAvistamientos} avistamientos. El distrito con más es ${_estadisticasPorDistrito.isNotEmpty ? _estadisticasPorDistrito.first.distrito : "N/A"}.
    """;
  }

  String _generarResumenUbicaciones() {
    return """
📍 RESUMEN POR UBICACIONES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏆 TOP 10 DISTRITOS MÁS ACTIVOS
${_estadisticasPorDistrito.map((e) => "• ${e.distrito}:\n  - Reportes: ${e.reportes}\n  - Avistamientos: ${e.avistamientos}\n  - Total: ${e.reportes + e.avistamientos}").join("\n")}

💡 CONCLUSIÓN
El distrito con más actividad es ${_estadisticasPorDistrito.isNotEmpty ? _estadisticasPorDistrito.first.distrito : "N/A"} con ${_estadisticasPorDistrito.isNotEmpty ? _estadisticasPorDistrito.first.reportes + _estadisticasPorDistrito.first.avistamientos : 0} registros en total.
    """;
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return meses[mes];
  }

  String _obtenerTextoPeriodo() {
    final dias = _rangoFechas.fin.difference(_rangoFechas.inicio).inDays;
    if (dias <= 7) return "Última Semana";
    if (dias <= 31) return "Último Mes";
    if (dias <= 93) return "Último Trimestre";
    return "Último Año";
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }
}
