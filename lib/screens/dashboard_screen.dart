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

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateToProfile,
    required this.themeMode,
    required this.onThemeChanged,
    required List<NotificationItem> notifications,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  String _searchQuery = '';
  String _chartType = 'bar'; // 'bar', 'line', 'area'

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTx = widget.state.transactions.where((tx) {
      final query = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          tx.title.toLowerCase().contains(query) ||
          tx.category.toLowerCase().contains(query) ||
          tx.paymentMethod.toLowerCase().contains(query);
    }).toList();

    if (_searchQuery.isNotEmpty) {
      return _SearchResultsView(
        cs: cs,
        filteredTx: filteredTx,
        searchController: _searchController,
        onSearchChanged: (value) {
          setState(() => _searchQuery = value);
        },
        onNavigateToProfile: widget.onNavigateToProfile,
      );
    }

    return CustomScrollView(
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tendencia mensual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    PopupMenuButton<String>(
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.surfaceContainerHighest,
                        ),
                        child: Icon(Icons.more_vert_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? cs.surfaceContainerHighest
                        : cs.surfaceContainerHighest,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: _buildChart(context, cs, widget.state.monthlyTrend, _chartType),
                ),
              ],
            ),
          ),
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
    final chartValues = values.isEmpty ? [1500, 2200, 1800, 2500, 2100, 1900] : values;
    final maxValue = chartValues.reduce((a, b) => a > b ? a : b);
    final total = chartValues.fold(0.0, (sum, val) => sum + val);
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < chartValues.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: chartValues[i],
              color: cs.primary,
              width: 20,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 380,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 20, bottom: 16, left: 0),
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
                  color: cs.outlineVariant.withOpacity(0.08),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      final percentage = (chartValues[index] / total * 100);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            months[index],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${(value / 1000).toStringAsFixed(1)}k',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => cs.surfaceContainerHighest.withOpacity(0.95),
                tooltipPadding: const EdgeInsets.all(12),
                tooltipBorderRadius: BorderRadius.circular(12),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final percentage = (rod.toY / total * 100);
                  return BarTooltipItem(
                    '\$${rod.toY.toStringAsFixed(0)}\n${percentage.toStringAsFixed(1)}%',
                    TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, ColorScheme cs, List<double> values) {
    final chartValues = values.isEmpty ? [1500, 2200, 1800, 2500, 2100, 1900] : values;
    final maxValue = chartValues.reduce((a, b) => a > b ? a : b);
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    List<FlSpot> spots = [];
    for (int i = 0; i < chartValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartValues[i]));
    }

    return SizedBox(
      height: 380,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 20, bottom: 16, left: 0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: cs.outlineVariant.withOpacity(0.08),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      return Text(months[index], style: Theme.of(context).textTheme.bodySmall);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${(value / 1000).toStringAsFixed(1)}k',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
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
                dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: cs.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context, ColorScheme cs, List<double> values) {
    final chartValues = values.isEmpty ? [1500, 2200, 1800, 2500, 2100, 1900] : values;
    final maxValue = chartValues.reduce((a, b) => a > b ? a : b);
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    List<FlSpot> spots = [];
    for (int i = 0; i < chartValues.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartValues[i]));
    }

    return SizedBox(
      height: 380,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 20, bottom: 16, left: 0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: cs.outlineVariant.withOpacity(0.08),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < months.length) {
                      return Text(months[index], style: Theme.of(context).textTheme.bodySmall);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${(value / 1000).toStringAsFixed(1)}k',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
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
                belowBarData: BarAreaData(
                  show: true,
                  color: cs.primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
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
                  'Resultados de búsqueda',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
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
                  'No hay transacciones que coincidan',
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
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
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
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: cs.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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