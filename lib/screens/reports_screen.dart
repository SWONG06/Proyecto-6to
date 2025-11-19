import 'package:proyecto_6to/state/finance_app_state.dart';
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/formatters.dart';
import '../widgets/dual_line_chart.dart' hide CategoryDistributionChart;
import '../widgets/category_distribution_chart.dart';

class ReportsScreen extends StatefulWidget {
  final FinanceAppState state;
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;

  const ReportsScreen({
    super.key,
    required this.state,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _themeAnimationController;
  String _selectedPeriod = 'Este mes';
  String _selectedCategory = 'Todas';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cs = Theme.of(context).colorScheme;

    // Obtener categorías únicas
    final categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category).toSet(),
    ];

    return CustomScrollView(
      slivers: [
        // Header mejorado
        SliverToBoxAdapter(
          child: Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reportes y Análisis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visualiza tus datos financieros',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sección de filtros mejorada
        SliverToBoxAdapter(
          child: Container(
            color: cs.background,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppleFilterChip(
                        label: _selectedPeriod,
                        options: const ['Este mes', 'Últimos 3 meses', 'Este año'],
                        onChanged: (value) {
                          setState(() => _selectedPeriod = value);
                        },
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppleFilterChip(
                        label: _selectedCategory,
                        options: categories,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        icon: Icons.category_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Sección de estadísticas mejorada
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas Clave',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    AppleStatCard(
                      title: 'Variación Gastos',
                      value: '+${_formatPercentage(widget.state.reportThisMonthExpenseVarPct)}',
                      icon: Icons.trending_down_rounded,
                      iconColor: Colors.red[400],
                      subtitle: 'vs mes anterior',
                    ),
                    const SizedBox(height: 12),
                    AppleStatCard(
                      title: 'Margen de Beneficio',
                      value: _formatPercentage(widget.state.reportThisMonthMarginPct),
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.green[400],
                      subtitle: 'Rentabilidad actual',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Gráfico de tendencias mejorado
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tendencias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: cs.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _selectedPeriod,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: DualLineChart(
                    labels: widget.state.months,
                    seriesA: widget.state.trendProfit,
                    seriesB: widget.state.trendExpense,
                    labelA: 'Beneficio',
                    labelB: 'Gastos',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Gráfico de distribución mejorado
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distribución por Categoría',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Icon(
                      Icons.pie_chart_rounded,
                      color: cs.primary.withOpacity(0.6),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: CategoryDistributionChart(
                    data: widget.state.categoryDistribution,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}

// ignore: non_constant_identifier_names
Widget? DualLineChart({required List<String> labels, required List<double> seriesA, required List<double> seriesB, required String labelA, required String labelB}) {
  return null;
}

/// Chip de filtro estilo Apple premium
class AppleFilterChip extends StatefulWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const AppleFilterChip({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.icon,
  });

  @override
  State<AppleFilterChip> createState() => _AppleFilterChipState();
}

class _AppleFilterChipState extends State<AppleFilterChip> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.label;
  }

  @override
  void didUpdateWidget(AppleFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      _currentValue = widget.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _currentValue,
        items: widget.options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _currentValue = value);
            widget.onChanged(value);
          }
        },
        underline: const SizedBox(),
        isDense: true,
        isExpanded: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.expand_more_rounded,
              size: 20,
              color: cs.primary.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de estadísticas estilo Apple premium
class AppleStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;

  const AppleStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
  });

  @override
  State<AppleStatCard> createState() => _AppleStatCardState();
}

class _AppleStatCardState extends State<AppleStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    final bgColor = widget.iconColor ?? cs.primary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgColor.withOpacity(0.25),
                      bgColor.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: bgColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: bgColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}