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

            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            
            // Botón de perfil (opcional)
            if (widget.onNavigateToProfile != null)
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: widget.onNavigateToProfile,
              ),
          ],
        ),

        // --- resto del contenido ---
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
                  value: widget.state.monthlyIncome ,
                  icon: Icons.north_east,
                  color: Colors.green[700],
                ),
                SummaryCard(
                  label: 'Gastos mensuales',
                  value: widget.state.monthlyExpense ,
                  icon: Icons.south_west,
                  color: cs.error,
                ),
                SummaryCard(
                  label: 'Total ingresos',
                  value: widget.state.totalIncomeAllTime ,
                  icon: Icons.trending_up,
                ),
                SummaryCard(
                  label: 'Total gastos',
                  value: widget.state.totalExpenseAllTime ,
                  icon: Icons.trending_down,
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
                  labels: widget.state.months ,
                  values: widget.state.monthlyTrend ,
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
            // CORRECCIÓN PRINCIPAL: Asegurar que balance no sea null
            MoneyText(
              balance,
              amount: balance,
            ),
          ],
        ),
      ),
    );
  }
}

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
            width: 50,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  top: 2,
                  left: isDark ? 24 : 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 16,
                      color: isDark 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
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