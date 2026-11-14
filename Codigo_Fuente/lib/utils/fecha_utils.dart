/// Utilidades estáticas para el formateo de fechas en formato
/// relativo al momento actual, reutilizables en toda la aplicación.
class FechaUtils {
  // Clase de utilidad — no instanciable.
  FechaUtils._();

  static const int _minutosEnUnaHora = 60;
  static const int _horasEnUnDia = 24;
  static const int _diasEnUnaSemana = 7;

  /// Formatea [fecha] como texto relativo al instante actual.
  ///
  /// Ejemplos de retorno:
  /// - `'Ahora'` si ocurrió hace menos de un minuto.
  /// - `'Hace 5 min'` si ocurrió hace menos de una hora.
  /// - `'Hace 2 h'` si ocurrió hace menos de un día.
  /// - `'Ayer 14:30'` si ocurrió el día anterior.
  /// - `'Hace 3 días'` si ocurrió hace menos de una semana.
  /// - `'22/8/2026'` para fechas más antiguas.
  ///
  /// Retorna una cadena vacía si [fecha] es `null`.
  static String formatearTiempoRelativo(DateTime? fecha) {
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    final horaFormateada =
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';

    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inMinutes < _minutosEnUnaHora) {
      return 'Hace ${diferencia.inMinutes} min';
    }
    if (diferencia.inHours < _horasEnUnDia) {
      return 'Hace ${diferencia.inHours} h';
    }
    if (diferencia.inDays == 1) return 'Ayer $horaFormateada';
    if (diferencia.inDays < _diasEnUnaSemana) {
      return 'Hace ${diferencia.inDays} días';
    }
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
