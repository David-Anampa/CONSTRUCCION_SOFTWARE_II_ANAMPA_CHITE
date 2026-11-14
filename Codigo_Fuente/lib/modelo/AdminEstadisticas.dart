// modelo/AdminEstadisticas.dart

class EstadisticasGenerales {
  int totalUsuarios;
  int totalReportes;
  int totalAvistamientos;
  int reportesPerdidos;
  int reportesEncontrados;
  int usuariosActivos;
  int usuariosInactivos;
  
  EstadisticasGenerales({
    this.totalUsuarios = 0,
    this.totalReportes = 0,
    this.totalAvistamientos = 0,
    this.reportesPerdidos = 0,
    this.reportesEncontrados = 0,
    this.usuariosActivos = 0,
    this.usuariosInactivos = 0,
  });
}

class EstadisticasPorMes {
  String mes; // "Ene", "Feb", etc
  int reportes;
  int avistamientos;
  int usuarios;
  
  EstadisticasPorMes({
    required this.mes,
    this.reportes = 0,
    this.avistamientos = 0,
    this.usuarios = 0,
  });
}

class EstadisticasPorDia {
  String dia; // "Lun", "Mar", etc
  int cantidad;
  
  EstadisticasPorDia({
    required this.dia,
    this.cantidad = 0,
  });
}

class EstadisticasPorTipo {
  String tipo; // "Perro", "Gato"
  int cantidad;
  double porcentaje;
  
  EstadisticasPorTipo({
    required this.tipo,
    this.cantidad = 0,
    this.porcentaje = 0.0,
  });
}

class EstadisticasPorDistrito {
  String distrito;
  int reportes;
  int avistamientos;
  
  EstadisticasPorDistrito({
    required this.distrito,
    this.reportes = 0,
    this.avistamientos = 0,
  });
}

// ✅ NUEVA CLASE PARA UBICACIONES ESPECÍFICAS
class EstadisticasPorUbicacion {
  String ubicacion;
  String distrito;
  int reportes;
  int avistamientos;
  
  EstadisticasPorUbicacion({
    required this.ubicacion,
    required this.distrito,
    this.reportes = 0,
    this.avistamientos = 0,
  });
}

class RangoFechas {
  DateTime inicio;
  DateTime fin;
  
  RangoFechas({
    required this.inicio,
    required this.fin,
  });
  
  factory RangoFechas.ultimaSemana() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: hoy.subtract(const Duration(days: 7)),
      fin: hoy,
    );
  }
  
  factory RangoFechas.ultimoMes() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year, hoy.month - 1, hoy.day),
      fin: hoy,
    );
  }
  
  factory RangoFechas.ultimoTrimestre() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year, hoy.month - 3, hoy.day),
      fin: hoy,
    );
  }
  
  factory RangoFechas.ultimoAnio() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year - 1, hoy.month, hoy.day),
      fin: hoy,
    );
  }
}