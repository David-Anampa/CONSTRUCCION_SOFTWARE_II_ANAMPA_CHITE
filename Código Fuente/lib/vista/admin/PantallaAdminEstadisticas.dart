// vista/admin/PantallaAdminEstadisticas.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../vistamodelo/admin/AdminEstadisticas_vm.dart';

class PantallaAdminEstadisticas extends StatelessWidget {
  const PantallaAdminEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminEstadisticasVM()..cargarEstadisticas(),
      child: const _ContenidoEstadisticas(),
    );
  }
}

class _ContenidoEstadisticas extends StatelessWidget {
  const _ContenidoEstadisticas();
  
  String _formatearFecha(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminEstadisticasVM>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "Estadísticas Avanzadas",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "${_formatearFecha(vm.rangoFechas.inicio)} - ${_formatearFecha(vm.rangoFechas.fin)}",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: Colors.black87),
            onSelected: (periodo) async {
              if (periodo == "personalizado") {
                // Abrir selector de fechas
                final DateTimeRange? rango = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: vm.rangoFechas.inicio,
                    end: vm.rangoFechas.fin,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                
                if (rango != null && context.mounted) {
                  vm.cambiarRangoPersonalizado(rango.start, rango.end);
                }
              } else {
                vm.cambiarRangoFechas(periodo);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "semana", child: Text("Última semana")),
              const PopupMenuItem(value: "mes", child: Text("Último mes")),
              const PopupMenuItem(value: "trimestre", child: Text("Último trimestre")),
              const PopupMenuItem(value: "anio", child: Text("Último año")),
              const PopupMenuItem(
                value: "personalizado",
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Personalizado..."),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: vm.cargarEstadisticas,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TarjetasResumen(vm: vm),
                    const SizedBox(height: 20),
                    _GraficoTendenciaMensual(vm: vm),
                    const SizedBox(height: 20),
                    _GraficoPorDia(vm: vm),
                    const SizedBox(height: 20),
                    _GraficoPorTipo(vm: vm),
                    const SizedBox(height: 20),
                    _TopDistritos(vm: vm),
                    const SizedBox(height: 20),
                    _TopUbicacionesTacna(vm: vm),
                    const SizedBox(height: 20),
                    _SelectorResumen(vm: vm),
                    const SizedBox(height: 12),
                    _CuadroResumen(vm: vm),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

// 📊 TARJETAS DE RESUMEN
class _TarjetasResumen extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _TarjetasResumen({required this.vm});

  @override
  Widget build(BuildContext context) {
    final stats = vm.estadisticasGenerales;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildTarjeta("Usuarios", "${stats.totalUsuarios}", Icons.people, Colors.blue),
        _buildTarjeta("Reportes", "${stats.totalReportes}", Icons.pets, Colors.orange),
        _buildTarjeta("Avistamientos", "${stats.totalAvistamientos}", Icons.visibility, Colors.purple),
        _buildTarjeta("Encontrados", "${stats.reportesEncontrados}", Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildTarjeta(String titulo, String valor, IconData icono, Color color) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// 📈 GRÁFICO DE TENDENCIA MENSUAL (CustomPaint)
class _GraficoTendenciaMensual extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _GraficoTendenciaMensual({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.estadisticasMensuales.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📈 Tendencia Mensual",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _LineChartPainter(
                reportes: vm.estadisticasMensuales.map((e) => e.reportes.toDouble()).toList(),
                avistamientos: vm.estadisticasMensuales.map((e) => e.avistamientos.toDouble()).toList(),
                labels: vm.estadisticasMensuales.map((e) => e.mes.split(' ')[0]).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLeyenda(Colors.orange, "Reportes"),
              const SizedBox(width: 20),
              _buildLeyenda(Colors.purple, "Avistamientos"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeyenda(Color color, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// Painter para gráfico de líneas
class _LineChartPainter extends CustomPainter {
  final List<double> reportes;
  final List<double> avistamientos;
  final List<String> labels;

  _LineChartPainter({
    required this.reportes,
    required this.avistamientos,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (reportes.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    // Calcular valores máximos y mínimos
    final maxValue = [
      ...reportes,
      ...avistamientos,
    ].reduce(math.max).toDouble();
    
    final padding = 40.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding * 2;

    // Dibujar grid horizontal
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (graphHeight / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Función para convertir valor a coordenada Y
    double valueToY(double value) {
      if (maxValue == 0) return size.height - padding;
      return size.height - padding - (value / maxValue * graphHeight);
    }

    // Función para convertir índice a coordenada X
    double indexToX(int index) {
      return padding + (graphWidth / (reportes.length - 1)) * index;
    }

    // Dibujar línea de reportes
    paint.color = Colors.orange;
    final reportesPath = Path();
    reportesPath.moveTo(indexToX(0), valueToY(reportes[0]));
    for (int i = 1; i < reportes.length; i++) {
      reportesPath.lineTo(indexToX(i), valueToY(reportes[i]));
    }
    canvas.drawPath(reportesPath, paint);

    // Dibujar puntos de reportes
    dotPaint.color = Colors.orange;
    for (int i = 0; i < reportes.length; i++) {
      canvas.drawCircle(
        Offset(indexToX(i), valueToY(reportes[i])),
        4,
        dotPaint,
      );
    }

    // Dibujar línea de avistamientos
    paint.color = Colors.purple;
    final avistamientosPath = Path();
    avistamientosPath.moveTo(indexToX(0), valueToY(avistamientos[0]));
    for (int i = 1; i < avistamientos.length; i++) {
      avistamientosPath.lineTo(indexToX(i), valueToY(avistamientos[i]));
    }
    canvas.drawPath(avistamientosPath, paint);

    // Dibujar puntos de avistamientos
    dotPaint.color = Colors.purple;
    for (int i = 0; i < avistamientos.length; i++) {
      canvas.drawCircle(
        Offset(indexToX(i), valueToY(avistamientos[i])),
        4,
        dotPaint,
      );
    }

    // Dibujar etiquetas del eje X
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(indexToX(i) - textPainter.width / 2, size.height - 20),
      );
    }

    // Dibujar valores del eje Y
    for (int i = 0; i <= 4; i++) {
      final value = (maxValue / 4 * (4 - i)).toInt();
      textPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, padding + (graphHeight / 4) * i - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 📊 GRÁFICO POR DÍA DE LA SEMANA
class _GraficoPorDia extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _GraficoPorDia({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.estadisticasPorDia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Reportes por Día de la Semana",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _BarChartPainter(
                values: vm.estadisticasPorDia.map((e) => e.cantidad.toDouble()).toList(),
                labels: vm.estadisticasPorDia.map((e) => e.dia).toList(),
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para gráfico de barras
class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce(math.max);
    final padding = 40.0;
    final graphHeight = size.height - padding * 2;
    final barWidth = (size.width - padding * 2) / (values.length * 2);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    // Dibujar grid horizontal
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (graphHeight / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Dibujar barras
    for (int i = 0; i < values.length; i++) {
      final barHeight = maxValue > 0 ? (values[i] / maxValue) * graphHeight : 0.0;
      final x = padding + barWidth / 2 + (i * barWidth * 2);
      final y = size.height - padding - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);

      // Dibujar valor encima de la barra
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${values[i].toInt()}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 15),
      );
    }

    // Dibujar etiquetas
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labels.length; i++) {
      final x = padding + barWidth / 2 + (i * barWidth * 2);
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 11, color: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 20),
      );
    }

    // Dibujar valores del eje Y
    for (int i = 0; i <= 4; i++) {
      final value = (maxValue / 4 * (4 - i)).toInt();
      textPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(fontSize: 10, color: Colors.black54),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, padding + (graphHeight / 4) * i - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 🐾 GRÁFICO POR TIPO DE MASCOTA (Pie Chart)
class _GraficoPorTipo extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _GraficoPorTipo({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.estadisticasPorTipoMascota.isEmpty) {
      return const SizedBox.shrink();
    }

    final colores = [Colors.orange, Colors.blue, Colors.green, Colors.purple, Colors.red];

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🐾 Distribución por Tipo de Mascota",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: _PieChartPainter(
                      values: vm.estadisticasPorTipoMascota.map((e) => e.cantidad.toDouble()).toList(),
                      percentages: vm.estadisticasPorTipoMascota.map((e) => e.porcentaje).toList(),
                      colors: colores,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: vm.estadisticasPorTipoMascota.asMap().entries.map((e) {
                    final color = colores[e.key % colores.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "${e.value.tipo} (${e.value.cantidad})",
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Painter para gráfico circular (Pie Chart)
class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<double> percentages;
  final List<Color> colors;

  _PieChartPainter({
    required this.values,
    required this.percentages,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final innerRadius = radius * 0.5;

    final total = values.reduce((a, b) => a + b);
    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      // Dibujar segmento exterior
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Dibujar círculo interior (donut)
      canvas.drawCircle(
        center,
        innerRadius,
        Paint()..color = Colors.white,
      );

      // Dibujar porcentaje
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = (radius + innerRadius) / 2;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${percentages[i].toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 📍 TOP DISTRITOS
class _TopDistritos extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _TopDistritos({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.estadisticasPorDistrito.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📍 Top 10 Distritos Más Activos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...vm.estadisticasPorDistrito.map((distrito) {
            final total = distrito.reportes + distrito.avistamientos;
            final maxTotal = vm.estadisticasPorDistrito.first.reportes + 
                            vm.estadisticasPorDistrito.first.avistamientos;
            final percentage = maxTotal > 0 ? (total / maxTotal) : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          distrito.distrito,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        "${distrito.reportes}R / ${distrito.avistamientos}A",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$total",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// 🗺️ TOP UBICACIONES ESPECÍFICAS EN TACNA
class _TopUbicacionesTacna extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _TopUbicacionesTacna({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.estadisticasPorUbicacion.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Ubicaciones Más Reportadas en Tacna",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Separar por tipo
          const Text(
            "🐾 Reportes de Mascotas",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          ...vm.estadisticasPorUbicacion
              .where((u) => u.reportes > 0)
              .take(5)
              .map((ubicacion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        "${ubicacion.reportes}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ubicacion.ubicacion,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ubicacion.distrito,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (vm.estadisticasPorUbicacion.any((u) => u.avistamientos > 0)) ...[
            const SizedBox(height: 16),
            const Text(
              "👁️ Avistamientos",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            ...vm.estadisticasPorUbicacion
                .where((u) => u.avistamientos > 0)
                .take(5)
                .map((ubicacion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "${ubicacion.avistamientos}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ubicacion.ubicacion,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            ubicacion.distrito,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// 📄 SELECTOR DE RESUMEN
class _SelectorResumen extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _SelectorResumen({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📝 Tipo de Resumen",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip("General", "general", vm),
            _buildChip("Usuarios", "usuarios", vm),
            _buildChip("Reportes", "reportes", vm),
            _buildChip("Avistamientos", "avistamientos", vm),
            _buildChip("Ubicaciones", "ubicaciones", vm),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String label, String valor, AdminEstadisticasVM vm) {
    final seleccionado = vm.filtroResumen == valor;
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => vm.cambiarFiltroResumen(valor),
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }
}

// 📋 CUADRO DE RESUMEN
class _CuadroResumen extends StatelessWidget {
  final AdminEstadisticasVM vm;
  const _CuadroResumen({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        vm.generarResumen(),
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ),
    );
  }
}