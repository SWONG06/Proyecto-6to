import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../widgets/money_text.dart';
import '../widgets/summary_card.dart';
import '../widgets/trend_bar_chart.dart';

class DashboardScreen extends StatefulWidget {
  final FinanceAppState state;
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;
  final VoidCallback? onNavigateToProfile;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onNavigateToProfile,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.themeMode == ThemeMode.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('FinanceCloud'),
          actions: [
            // Interruptor de tema
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ModernThemeToggle(
                isDark: isDark,
                onToggle: (isDarkMode) {
                  widget.onThemeChanged(isDarkMode);
                  if (isDarkMode) {
                    _themeAnimationController.forward();
                  } else {
                    _themeAnimationController.reverse();
                  }
                },
                animationController: _themeAnimationController,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppleIconButton(
                icon: Icons.sell,
                onPressed: () {},
              ),
            ),

           
            // Botón de perfil (opcional)
            if (widget.onNavigateToProfile != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AppleIconButton(
                  icon: Icons.person, // The argument type 'VoidCallback?' can't be assigned to the parameter type 'VoidCallback'.
                  onPressed: widget.onNavigateToProfile!,
                ),
              ),
          ],
        ),        // --- resto del contenido ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _HeaderCard(state: widget.state),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              children: [
                SummaryCard(
                  label: 'Ingresos mensuales',
                  value: widget.state.monthlyIncome,
                  icon: AppleIcon.arrowUpRight,
                  color: Colors.green[700],
                ),
                SummaryCard(
                  label: 'Gastos mensuales',
                  value: widget.state.monthlyExpense,
                  icon: AppleIcon.arrowDownLeft,
                  color: cs.error,
                ),
                SummaryCard(
                  label: 'Total ingresos',
                  value: widget.state.totalIncomeAllTime,
                  icon: AppleIcon.chartUp,
                ),
                SummaryCard(
                  label: 'Total gastos',
                  value: widget.state.totalExpenseAllTime,
                  icon: AppleIcon.chartDown,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tendencia mensual',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TrendBarChart(
                  labels: widget.state.months,
                  values: widget.state.monthlyTrend,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final FinanceAppState state;

  const _HeaderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final balance = state.currentBalance ?? 0.0;
    final userName = state.userName ?? 'Usuario';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, $userName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu balance actual es:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            MoneyText(balance),
          ],
        ),
      ),
    );
  }
}

/// Iconos personalizados estilo Apple
class AppleIcon {
  static const IconData arrowUpRight = Icons.arrow_outward;
  static const IconData arrowDownLeft = Icons.arrow_outward;
  static const IconData chartUp = Icons.trending_up_rounded;
  static const IconData chartDown = Icons.trending_down_rounded;
}

/// Botón de ícono estilo Apple con efecto de interacción sutil
class AppleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const AppleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  State<AppleIconButton> createState() => _AppleIconButtonState();
}

class _AppleIconButtonState extends State<AppleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          _onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainerHighest,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? cs.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Toggle de tema mejorado con estilo Apple
class ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const ModernThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
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
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
              border: Border.all(
                color: isDark
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
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
                      color: isDark
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
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
                        isDark ? Icons.mood : Icons.cut_sharp,
                        size: 14,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context).colorScheme.outline,
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