import 'package:financecloud/screens/notification_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/finance_models.dart';
import '../widgets/money_text.dart';
import '../widgets/trend_bar_chart.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  final FinanceAppState state;
  final VoidCallback? onNavigateToProfile;
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;
  final List<NotificationItem> notifications;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateToProfile,
    required this.themeMode,
    required this.onThemeChanged,
    required this.notifications,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _chartType = 'bar';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _safeDouble(double? value) => value ?? 0.0;
  List<double> _safeList(List<double>? value) => value ?? [];
  List _safeTxList(List? value) => value ?? [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final txList = _safeTxList(widget.state.transactions);
    final filteredTx = txList.where((tx) {
      final query = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          (tx.title?.toLowerCase().contains(query) ?? false) ||
          (tx.category?.toLowerCase().contains(query) ?? false) ||
          (tx.paymentMethod?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (_searchQuery.isNotEmpty) {
      return Stack(
        children: [
          _SearchResultsView(
            cs: cs,
            filteredTx: filteredTx,
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
            onNavigateToProfile: widget.onNavigateToProfile,
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: _AIFloatingButton(cs: cs),
          ),
        ],
      );
    }

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: isDark
                  ? cs.surface.withOpacity(0.95)
                  : Colors.white.withOpacity(0.95),
              title: SizedBox(
                height: 40,
                child: SearchBarAppleHeader(
                  controller: _searchController,
                  onSearchChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              actions: [
                if (widget.onNavigateToProfile != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: AppleIconButton(
                      icon: Icons.person,
                      onPressed: widget.onNavigateToProfile ?? () {},
                    ),
                  ),
              ],
            ),
            // Balance Total - PRIMERO
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primary,
                        cs.primary.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu Balance Actual',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${_safeDouble(widget.state.balance).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Grid de 2x2 - Ingresos y Gastos Mensuales
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Este Mes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ModernStatCard(
                            title: 'Ingresos',
                            amount: _safeDouble(widget.state.monthlyIncome),
                            icon: Icons.trending_up_rounded,
                            color: Colors.green,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernStatCard(
                            title: 'Gastos',
                            amount: _safeDouble(widget.state.monthlyExpense),
                            icon: Icons.trending_down_rounded,
                            color: Colors.red,
                            cs: cs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Grid de 2x2 - Totales
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Totales',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ModernTotalCard(
                            title: 'Total Ingresos',
                            amount: _safeDouble(widget.state.totalIncome),
                            icon: Icons.arrow_downward_rounded,
                            color: Colors.blue,
                            cs: cs,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernTotalCard(
                            title: 'Total Gastos',
                            amount: _safeDouble(widget.state.totalExpense),
                            icon: Icons.arrow_upward_rounded,
                            color: Colors.orange,
                            cs: cs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Gráfico principal - AL FINAL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tendencia Mensual',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: cs.surfaceContainerHighest,
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() => _chartType = value);
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                value: 'bar',
                                child: Row(
                                  children: [
                                    Icon(Icons.bar_chart_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Barras'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'line',
                                child: Row(
                                  children: [
                                    Icon(Icons.trending_up_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Líneas'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'area',
                                child: Row(
                                  children: [
                                    Icon(Icons.area_chart_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Área'),
                                  ],
                                ),
                              ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Icon(Icons.more_vert_rounded, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: cs.surfaceContainerHighest,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _buildChart(context, cs, _safeList(widget.state.monthlyTrend), _chartType),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: _AIFloatingButton(cs: cs),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, ColorScheme cs, List<double> values, String type) {
    switch (type) {
      case 'line':
        return _buildLineChart(context, cs, values);
      case 'area':
        return _buildAreaChart(context, cs, values);
      default:
        return _buildBarChart(context, cs, values);
    }
  }

  Widget _buildBarChart(BuildContext context, ColorScheme cs, List<double> values) {
    final chartValues = values.isEmpty 
        ? [1500.0, 2200.0, 1800.0, 2500.0, 2100.0, 1900.0] 
        : values.map((v) => (v).toDouble()).toList();
    final maxValue = chartValues.isEmpty ? 3000.0 : chartValues.reduce((a, b) => a > b ? a : b);

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < chartValues.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (chartValues[i]).toDouble(),
              color: cs.primary,
              width: 16,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final months = ['E', 'F', 'M', 'A', 'M', 'J'];
                  int index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Text(
                      months[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}k',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, ColorScheme cs, List<double> values) {
    final chartValues = values.isEmpty 
        ? [1500.0, 2200.0, 1800.0, 2500.0, 2100.0, 1900.0] 
        : values.map((v) => (v).toDouble()).toList();
    final maxValue = chartValues.isEmpty ? 3000.0 : chartValues.reduce((a, b) => a > b ? a : b);

    List<FlSpot> spots = [];
    for (int i = 0; i < chartValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), (chartValues[i]).toDouble()));
    }

    return SizedBox(
      height: 280,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: cs.outlineVariant.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final months = ['E', 'F', 'M', 'A', 'M', 'J'];
                  int index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Text(
                      months[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}k',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: cs.primary,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context, ColorScheme cs, List<double> values) {
    final chartValues = values.isEmpty 
        ? [1500.0, 2200.0, 1800.0, 2500.0, 2100.0, 1900.0] 
        : values.map((v) => (v).toDouble()).toList();
    final maxValue = chartValues.isEmpty ? 3000.0 : chartValues.reduce((a, b) => a > b ? a : b);

    List<FlSpot> spots = [];
    for (int i = 0; i < chartValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), (chartValues[i]).toDouble()));
    }

    return SizedBox(
      height: 280,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: cs.outlineVariant.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final months = ['E', 'F', 'M', 'A', 'M', 'J'];
                  int index = value.toInt();
                  if (index >= 0 && index < months.length) {
                    return Text(
                      months[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}k',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: cs.primary,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: cs.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIFloatingButton extends StatefulWidget {
  final ColorScheme cs;

  const _AIFloatingButton({required this.cs});

  @override
  State<_AIFloatingButton> createState() => _AIFloatingButtonState();
}

class _AIFloatingButtonState extends State<_AIFloatingButton>
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
    // Aquí puedes agregar la acción para abrir el chat con IA
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Abriendo asistente de IA...'),
        backgroundColor: widget.cs.primary,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.cs.primary,
                widget.cs.primary.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.cs.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final ColorScheme cs;

  const _ModernStatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernTotalCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final ColorScheme cs;

  const _ModernTotalCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  final ColorScheme cs;
  final List filteredTx;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onNavigateToProfile;

  const _SearchResultsView({
    required this.cs,
    required this.filteredTx,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNavigateToProfile,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          title: SizedBox(
            height: 40,
            child: SearchBarAppleHeader(
              controller: searchController,
              onSearchChanged: onSearchChanged,
            ),
          ),
          actions: [
            if (onNavigateToProfile != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AppleIconButton(
                  icon: Icons.person,
                  onPressed: onNavigateToProfile ?? () {},
                ),
              ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${filteredTx.length} resultado${filteredTx.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (filteredTx.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Sin coincidencias',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TransactionCard(tx: filteredTx[index]),
              ),
              childCount: filteredTx.length,
            ),
          ),
      ],
    );
  }
}

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
          width: 40,
          height: 40,
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

class SearchBarAppleHeader extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const SearchBarAppleHeader({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<SearchBarAppleHeader> createState() => _SearchBarAppleHeaderState();
}

class _SearchBarAppleHeaderState extends State<SearchBarAppleHeader> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _isFocused
            ? cs.surfaceContainerHigh
            : cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? cs.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          hintStyle: TextStyle(
            fontSize: 15,
            color: cs.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: _isFocused
                ? cs.primary
                : cs.onSurface.withOpacity(0.5),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearchChanged('');
                    _focusNode.unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}