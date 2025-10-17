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
      slivers: [
        SliverAppBar(
          title: const Text('Reportes'),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financieros - Análisis y tendencias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppleStatCard(
                      title: 'Variación gastos (este mes)',
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: DualLineChart(
            labels: widget.state.months,
            seriesA: widget.state.trendProfit,
            seriesB: widget.state.trendExpense,
            labelA: 'Beneficio',
            labelB: 'Gastos',
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryDistributionChart(
            data: widget.state.categoryDistribution,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
      ],
    );
  }
}

/// Toggle de tema estilo Apple - Simple y elegante
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

/// Tarjeta de estadísticas estilo Apple - Minimalista y elegante
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