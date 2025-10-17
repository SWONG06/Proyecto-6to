import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/format.dart';
import '../widgets/dual_line_chart.dart';
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
    // Obtener categorías únicas
    final categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category).toSet(),
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
         
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppleThemeToggle(
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: _selectedPeriod,
                        options: const ['Este mes', 'Últimos 3 meses', 'Este año'],
                        onChanged: (value) {
                          setState(() => _selectedPeriod = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilterChip(
                        label: _selectedCategory,
                        options: categories,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tarjetas de estadísticas
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppleStatCard(
                      title: 'Variación gastos',
                      value: '+${pct(widget.state.reportThisMonthExpenseVarPct)}',
                      icon: Icons.trending_down_rounded,
                      iconColor: Colors.red[400],
                    ),
                    AppleStatCard(
                      title: 'Margen beneficio',
                      value: pct(widget.state.reportThisMonthMarginPct),
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.green[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DualLineChart(
              labels: widget.state.months,
              seriesA: widget.state.trendProfit,
              seriesB: widget.state.trendExpense,
              labelA: 'Beneficio',
              labelB: 'Gastos',
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CategoryDistributionChart(
              data: widget.state.categoryDistribution,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
      ],
    );
  }
}

/// Chip de filtro estilo Apple
class FilterChip extends StatefulWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const FilterChip({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  @override
  State<FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<FilterChip> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.label;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: DropdownButton<String>(
        value: _currentValue,
        items: widget.options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
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
        icon: Icon(
          Icons.unfold_more_rounded,
          size: 16,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Toggle de tema estilo Apple
class AppleThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const AppleThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => onToggle(!isDark),
          child: Container(
            width: 52,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDark
                  ? cs.primary.withOpacity(0.2)
                  : cs.surfaceContainerHighest,
              border: Border.all(
                color: isDark
                    ? cs.primary.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  top: 3,
                  left: isDark ? 26 : 3,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? cs.primary : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isDark ? Icons.mood_rounded : Icons.cut_rounded,
                        size: 14,
                        color: isDark ? Colors.white : cs.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta de estadísticas estilo Apple
class AppleStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const AppleStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  State<AppleStatCard> createState() => _AppleStatCardState();
}

class _AppleStatCardState extends State<AppleStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
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

    return ScaleTransition(
      scale: _hoverAnimation,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.5),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.iconColor?.withOpacity(0.15) ??
                      cs.primary.withOpacity(0.15),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? cs.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}