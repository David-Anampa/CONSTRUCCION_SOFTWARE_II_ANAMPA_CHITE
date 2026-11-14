// /**
//  * Archivo/Clase : AdminEstadisticas.dart / EstadisticasGenerales, EstadisticasPorMes,
//  *                 EstadisticasPorDia, EstadisticasPorTipo, EstadisticasPorDistrito,
//  *                 EstadisticasPorUbicacion, RangoFechas
//  * Proyecto      : SOSMASCOTA
//  * Autores       : David Anampa, Danilo Chite
//  * Fecha         : 13/11/2026
//  * Descripción   : Contenedores de datos analíticos (DTOs) y rangos de fechas para el
//  *                 tablero de estadísticas del panel de administración.
//  * Se vincula con: - USA: Tipos primitivos y DateTime de Dart Core.
//  *                 - ES USADO POR: AdminEstadisticasVM (AdminEstadisticas_vm.dart) y
//  *                   PantallaAdminEstadisticas (PantallaAdminEstadisticas.dart).
//  * Funcionamiento: Agrupa las métricas consolidadas por período, día de la semana, especie,
//  *                 distrito y ubicación específica para alimentar los gráficos fl_chart.
//  * Requerimiento : RF-17 (Visualizar estadísticas avanzadas y reportes analíticos)
//  */

// modelo/AdminEstadisticas.dart

/// Resumen global de indicadores clave (KPIs) de usuarios, reportes y avistamientos.
class EstadisticasGenerales {
  int totalUsuarios;
  int totalReportes;
  int totalAvistamientos;
  int reportesPerdidos;
  int reportesEncontrados;
  int usuariosActivos;
  int usuariosInactivos;
  
  /// Inicializa los contadores generales en cero por defecto.
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

/// Representa los totales mensuales de reportes, avistamientos y nuevos usuarios.
class EstadisticasPorMes {
  String mes; // "Ene", "Feb", etc
  int reportes;
  int avistamientos;
  int usuarios;
  
  /// Crea un registro de métricas para el [mes] abreviado indicado.
  EstadisticasPorMes({
    required this.mes,
    this.reportes = 0,
    this.avistamientos = 0,
    this.usuarios = 0,
  });
}

/// Representa la frecuencia de reportes agrupada por día de la semana.
class EstadisticasPorDia {
  String dia; // "Lun", "Mar", etc
  int cantidad;
  
  /// Crea un registro de actividad para el [dia] de la semana indicado.
  EstadisticasPorDia({
    required this.dia,
    this.cantidad = 0,
  });
}

/// Representa la distribución absoluta y porcentual de reportes según el tipo de mascota.
class EstadisticasPorTipo {
  String tipo; // "Perro", "Gato"
  int cantidad;
  double porcentaje;
  
  /// Crea un registro estadístico para la especie o [tipo] de mascota.
  EstadisticasPorTipo({
    required this.tipo,
    this.cantidad = 0,
    this.porcentaje = 0.0,
  });
}

/// Concentra el número de reportes y avistamientos registrados en un distrito.
class EstadisticasPorDistrito {
  String distrito;
  int reportes;
  int avistamientos;
  
  /// Crea un acumulador de actividad para el [distrito] especificado.
  EstadisticasPorDistrito({
    required this.distrito,
    this.reportes = 0,
    this.avistamientos = 0,
  });
}

// ✅ NUEVA CLASE PARA UBICACIONES ESPECÍFICAS
/// Concentra el número de reportes y avistamientos en una dirección o zona específica.
class EstadisticasPorUbicacion {
  String ubicacion;
  String distrito;
  int reportes;
  int avistamientos;
  
  /// Crea un acumulador para una [ubicacion] puntual dentro de un [distrito].
  EstadisticasPorUbicacion({
    required this.ubicacion,
    required this.distrito,
    this.reportes = 0,
    this.avistamientos = 0,
  });
}

/// Define un intervalo temporal `[inicio, fin]` para filtrar las consultas analíticas.
class RangoFechas {
  DateTime inicio;
  DateTime fin;
  
  /// Crea un intervalo de fechas explícito entre [inicio] y [fin].
  RangoFechas({
    required this.inicio,
    required this.fin,
  });
  
  /// Construye un rango que abarca los últimos 7 días hasta el instante actual.
  factory RangoFechas.ultimaSemana() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: hoy.subtract(const Duration(days: 7)),
      fin: hoy,
    );
  }
  
  /// Construye un rango desde el mismo día del mes anterior hasta la fecha actual.
  factory RangoFechas.ultimoMes() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year, hoy.month - 1, hoy.day),
      fin: hoy,
    );
  }
  
  /// Construye un rango que abarca los últimos tres meses calendario hasta hoy.
  factory RangoFechas.ultimoTrimestre() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year, hoy.month - 3, hoy.day),
      fin: hoy,
    );
  }
  
  /// Construye un rango que abarca el último año completo hasta la fecha actual.
  factory RangoFechas.ultimoAnio() {
    final hoy = DateTime.now();
    return RangoFechas(
      inicio: DateTime(hoy.year - 1, hoy.month, hoy.day),
      fin: hoy,
    );
  }
}