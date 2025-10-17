import 'package:flutter/material.dart';

class DualLineChart extends StatelessWidget {
  final List<String> labels;
  final List<double> seriesA;
  final List<double> seriesB;
  final String labelA;
  final String labelB;

  const DualLineChart({
    super.key,
    required this.labels,
    required this.seriesA,
    required this.seriesB,
    required this.labelA,
    required this.labelB,
  });

  @override
  Widget build(BuildContext context) {
    assert(labels.length == seriesA.length && labels.length == seriesB.length);
    final maxV = [
      ...seriesA,
      ...seriesB,
    ].reduce((a, b) => a > b ? a : b) * 1.25;

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1C1C1E),
                  const Color(0xFF2C2C2E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 280,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                // Leyenda superior estilo iOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _AppleLegendItem(
                      color: cs.primary,
                      text: labelA,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 16),
                    _AppleLegendItem(
                      color: cs.secondary,
                      text: labelB,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Gráfico
                Expanded(
                  child: CustomPaint(
                    painter: _AppleLineChartPainter(
                      labels: labels,
                      a: seriesA,
                      b: seriesB,
                      maxV: maxV,
                      colorA: cs.primary,
                      colorB: cs.secondary,
                      isDark: isDark,
                    ),
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

class _AppleLegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final bool isDark;

  const _AppleLegendItem({
    required this.color,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppleLineChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> a;
  final List<double> b;
  final double maxV;
  final Color colorA;
  final Color colorB;
  final bool isDark;

  _AppleLineChartPainter({
    required this.labels,
    required this.a,
    required this.b,
    required this.maxV,
    required this.colorA,
    required this.colorB,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 40;
    final stepX = size.width / (labels.length - 1);

    Offset p(double xIdx, double v) {
      final x = xIdx * stepX;
      final y = chartHeight - (v / maxV) * chartHeight + 10;
      return Offset(x, y);
    }

    // Grid horizontal estilo Apple (más sutil)
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.04)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      final y = 10 + (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    void drawAppleSeries(List<double> s, Color c, bool isFirst) {
      // Gradiente de relleno suave
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.withOpacity(0.15),
            c.withOpacity(0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight + 10));

      final fillPath = Path();
      fillPath.moveTo(0, chartHeight + 10);
      for (int i = 0; i < s.length; i++) {
        final pt = p(i.toDouble(), s[i]);
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(size.width, chartHeight + 10);
      fillPath.close();
      canvas.drawPath(fillPath, gradientPaint);

      // Línea principal con sombra
      final shadowPaint = Paint()
        ..color = c.withOpacity(0.3)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final linePaint = Paint()
        ..color = c
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      for (int i = 0; i < s.length; i++) {
        final pt = p(i.toDouble(), s[i]);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }

      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, linePaint);

      // Puntos estilo Apple con anillo exterior
      for (int i = 0; i < s.length; i++) {
        final pt = p(i.toDouble(), s[i]);
        
        // Sombra del punto
        final shadowDot = Paint()
          ..color = c.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(pt, 5, shadowDot);

        // Anillo exterior
        final outerRing = Paint()
          ..color = c.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 6, outerRing);

        // Punto interior blanco
        final innerDot = Paint()
          ..color = isDark ? const Color(0xFF1C1C1E) : Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 4, innerDot);

        // Centro de color
        final centerDot = Paint()..color = c;
        canvas.drawCircle(pt, 2.5, centerDot);
      }
    }

    drawAppleSeries(a, colorA, true);
    drawAppleSeries(b, colorB, false);

    // Labels eje X estilo SF Pro
    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.6)
              : Colors.black.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      );
      tp.layout(minWidth: 1, maxWidth: 80);
      final x = i * stepX - tp.width / 2;
      tp.paint(
        canvas,
        Offset(x.clamp(0, size.width - tp.width), size.height - 25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppleLineChartPainter oldDelegate) =>
      oldDelegate.a != a ||
      oldDelegate.b != b ||
      oldDelegate.isDark != isDark;
}