import 'package:flutter/material.dart';

class TrendBarChart extends StatelessWidget {
  final List<String> labels; // Ej: ['Ene', 'Feb', ...]
  final List<double> values; // misma longitud
  
  const TrendBarChart({super.key, required this.labels, required this.values});
  
  @override
  Widget build(BuildContext context) {
    assert(labels.length == values.length && labels.isNotEmpty);
    final maxV = (values.reduce((a, b) => a > b ? a : b)) * 1.2;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: CustomPaint(
            painter: _BarPainter(
              labels: labels,
              values: values,
              maxV: maxV,
              color: Theme.of(context).colorScheme.primary,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final double maxV;
  final Color color;
  final bool isDark;
  
  _BarPainter({
    required this.labels,
    required this.values,
    required this.maxV,
    required this.color,
    required this.isDark,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 24.0;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    final gap = (size.width - (labels.length * barWidth)) / (labels.length + 1);
    
    for (int i = 0; i < labels.length; i++) {
      final x = gap + i * (barWidth + gap);
      final h = (values[i] / maxV) * (size.height - 40);
      
      // Sombra suave tipo iOS
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, size.height - h - 29, barWidth, h),
        const Radius.circular(8),
      );
      canvas.drawRRect(shadowRect, shadowPaint);
      
      // Barra con gradiente
      final rect = Rect.fromLTWH(x, size.height - h - 30, barWidth, h);
      final rrect = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      );
      
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.8),
          color,
        ],
      );
      
      final gradientPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(rrect, gradientPaint);
      
      // Etiqueta con mejor tipografía
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      );
      textPainter.layout(minWidth: barWidth, maxWidth: barWidth);
      textPainter.paint(canvas, Offset(x, size.height - 22));
    }
    
    // Línea base más sutil
    final base = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.08)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(0, size.height - 30),
      Offset(size.width, size.height - 30),
      base,
    );
  }
  
  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.values != values || old.color != color || old.isDark != isDark;
}