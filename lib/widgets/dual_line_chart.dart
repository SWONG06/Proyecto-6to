import 'package:flutter/material.dart';
import 'dart:math';

class CategoryDistributionChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Normaliza los datos
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final entries = data.entries.toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)]
              : [Colors.white, const Color(0xFFF5F5F7)],
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _ApplePieChartPainter(entries, total, cs, isDark),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: entries.map((e) {
              final color = _colorForLabel(e.key, cs);
              final percent = (e.value / total * 100).toStringAsFixed(1);
              return _CategoryLegendItem(
                color: color,
                label: e.key,
                value: '$percent%',
                isDark: isDark,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _colorForLabel(String label, ColorScheme cs) {
    final colors = [
      cs.primary,
      cs.secondary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blueGrey,
      Colors.pinkAccent,
      Colors.teal,
    ];
    return colors[label.hashCode % colors.length];
  }
}

class _ApplePieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final ColorScheme cs;
  final bool isDark;

  _ApplePieChartPainter(this.entries, this.total, this.cs, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 2.4;
    final center = Offset(size.width / 2, size.height / 2);
    double startAngle = -pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;

    for (final e in entries) {
      final sweep = (e.value / total) * 2 * pi;
      paint.color = _colorForLabel(e.key, cs);

      // Sombra suave
      final shadow = Paint()
        ..color = paint.color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..strokeWidth = 36
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweep, false, shadow);

      // Segmento principal
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweep, false, paint);

      startAngle += sweep;
    }

    // Círculo interior
    final innerPaint = Paint()
      ..color = isDark ? const Color(0xFF1C1C1E) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 28, innerPaint);

    // Título central
    final totalText = TextSpan(
      text: 'Total',
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
    final valueText = TextSpan(
      text: '\n${total.toStringAsFixed(0)}',
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    final tp = TextPainter(
      text: TextSpan(children: [totalText, valueText]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 22));
  }

  Color _colorForLabel(String label, ColorScheme cs) {
    final colors = [
      cs.primary,
      cs.secondary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.blueGrey,
      Colors.pinkAccent,
      Colors.teal,
    ];
    return colors[label.hashCode % colors.length];
  }

  @override
  bool shouldRepaint(_ApplePieChartPainter oldDelegate) =>
      oldDelegate.entries != entries || oldDelegate.total != total;
}

class _CategoryLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  const _CategoryLegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
