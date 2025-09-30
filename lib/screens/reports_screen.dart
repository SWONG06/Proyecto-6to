import 'package:flutter/material.dart'; // Importa los widgets y utilidades principales de Flutter.
import '../models/finance_models.dart'; // Importa los modelos financieros utilizados en la aplicación.
import '../utils/format.dart'; // Importa funciones de utilidad para formatear datos.
import '../widgets/dual_line_chart.dart'; // Importa un widget personalizado para gráficos de líneas.
import '../widgets/category_distribution_chart.dart'; // Importa un widget personalizado para gráficos de distribución por categorías.

// Pantalla principal de reportes financieros.
class ReportsScreen extends StatefulWidget {
  final FinanceAppState state; // Estado de la aplicación que contiene los datos financieros.
  final ThemeMode themeMode; // Modo de tema actual (claro u oscuro).
  final void Function(bool isDark) onThemeChanged; // Callback para cambiar el tema.

  const ReportsScreen({
    super.key,
    required this.state,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late AnimationController _themeAnimationController;

  @override
  void initState() {
    super.initState();
    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (widget.themeMode == ThemeMode.dark) {
      _themeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Vista de desplazamiento personalizada con soporte para Slivers.
      slivers: [
        // Barra de aplicación con título y botón para cambiar el tema.
        SliverAppBar(
          title: const Text('Reportes'), // Título de la pantalla.
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _ModernThemeToggle(
                isDark: widget.themeMode == ThemeMode.dark,
                onToggle: (isDark) {
                  widget.onThemeChanged(isDark);
                  if (isDark) {
                    _themeAnimationController.forward();
                  } else {
                    _themeAnimationController.reverse();
                  }
                },
                animationController: _themeAnimationController,
              ),
            ),
          ],
        ),
        // Contenedor principal con estadísticas y gráficos.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              0,
            ), // Margen interno del contenedor.
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinea los elementos al inicio.
              children: [
                // Título de la sección.
                Text(
                  'Financieros - Análisis y tendencias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12), // Espaciado vertical.
                // Tarjetas de estadísticas rápidas.
                Wrap(
                  spacing: 12, // Espaciado horizontal entre tarjetas.
                  runSpacing: 12, // Espaciado vertical entre tarjetas.
                  children: [
                    _StatCard(
                      title: 'Variación gastos (este mes)',
                      value: '+${pct(widget.state.reportThisMonthExpenseVarPct)}',
                    ), // Tarjeta con variación de gastos.
                    _StatCard(
                      title: 'Margen beneficio',
                      value: pct(widget.state.reportThisMonthMarginPct),
                    ), // Tarjeta con margen de beneficio.
                  ],
                ),
                const SizedBox(height: 8), // Espaciado adicional.
              ],
            ),
          ),
        ),
        // Gráfico de líneas para mostrar tendencias de beneficios y gastos.
        SliverToBoxAdapter(
          child: DualLineChart(
            labels: widget.state.months, // Etiquetas de los meses.
            seriesA: widget.state.trendProfit, // Datos de la serie de beneficios.
            seriesB: widget.state.trendExpense, // Datos de la serie de gastos.
            labelA: 'Beneficio', // Etiqueta para la serie A.
            labelB: 'Gastos', // Etiqueta para la serie B.
          ),
        ),
        // Gráfico de distribución por categorías.
        SliverToBoxAdapter(
          child: CategoryDistributionChart(
            data: widget.state.categoryDistribution,
          ), // Muestra la distribución de gastos por categoría.
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ), // Espaciado final.
      ],
    );
  }
}

class _ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const _ModernThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final progress = animationController.value;
          
          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFFFB347), // Naranja suave para modo claro
                    const Color(0xFF1A1A2E), // Azul oscuro para modo oscuro
                    progress,
                  )!,
                  Color.lerp(
                    const Color(0xFFFFD700), // Dorado para modo claro
                    const Color(0xFF16213E), // Azul más oscuro para modo oscuro
                    progress,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fondo con estrellas para modo oscuro
                if (progress > 0.5)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StarsPainter(opacity: (progress - 0.5) * 2),
                    ),
                  ),
                
                // Indicador deslizante
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: isDark
                          ? Icon(
                              Icons.nightlight_round,
                              key: const ValueKey('dark'),
                              color: const Color(0xFF1A1A2E),
                              size: 16,
                            )
                          : Icon(
                              Icons.wb_sunny_rounded,
                              key: const ValueKey('light'),
                              color: const Color(0xFFFFB347),
                              size: 16,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double opacity;
  
  const _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    // Dibujar pequeñas estrellas
    final stars = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget para mostrar una tarjeta de estadísticas rápidas.
class _StatCard extends StatelessWidget {
  final String title; // Título de la tarjeta.
  final String value; // Valor mostrado en la tarjeta.

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(
      context,
    ).colorScheme; // Obtiene el esquema de colores del tema actual.
    return Container(
      decoration: BoxDecoration(
        color: cs.surface, // Color de fondo de la tarjeta.
        borderRadius: BorderRadius.circular(16), // Bordes redondeados.
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05), // Sombra ligera.
            blurRadius: 6, // Difuminado de la sombra.
            offset: const Offset(0, 2), // Desplazamiento de la sombra.
          ),
        ],
      ),
      padding: const EdgeInsets.all(14), // Margen interno de la tarjeta.
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Ajusta el tamaño de la fila al contenido.
        children: [
          Icon(Icons.insights, color: cs.primary), // Icono de la tarjeta.
          const SizedBox(width: 10), // Espaciado entre el icono y el texto.
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea el texto al inicio.
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ), // Valor de la tarjeta.
              const SizedBox(height: 4), // Espaciado vertical.
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ), // Título de la tarjeta.
            ],
          ),
        ],
      ),
    );
  }
}