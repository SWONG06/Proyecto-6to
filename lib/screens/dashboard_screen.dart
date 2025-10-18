import 'package:financecloud/screens/notification_icon_button.dart';
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../widgets/money_text.dart';
import '../widgets/trend_bar_chart.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  final FinanceAppState state;
  final VoidCallback? onNavigateToProfile;
  final List<NotificationItem> notifications;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateToProfile,
    required this.notifications, required ThemeMode themeMode, required ValueChanged<bool> onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  String _searchQuery = '';
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _notifications = widget.notifications;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
        notifications: _notifications,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
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
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: NotificationIconButton(
                notificationCount: _notifications.where((n) => !n.isRead).length,
                onPressed: () {
                  // Callback cuando se presiona el botón
                },
                notifications: _notifications,
              ),
            ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tendencia mensual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                TrendBarChart(
                  labels: widget.state.months,
                  values: widget.state.monthlyTrend,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _BalanceCard(state: widget.state),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _SummaryGridView(state: widget.state, cs: cs),
          ),
        ),
        SliverToBoxAdapter(
          child: const SizedBox(height: 16),
        ),
      ],
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  final ColorScheme cs;
  final List filteredTx;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onNavigateToProfile;
  final List<NotificationItem> notifications;

  const _SearchResultsView({
    required this.cs,
    required this.filteredTx,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNavigateToProfile,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: SizedBox(
            height: 40,
            child: SearchBarAppleHeader(
              controller: searchController,
              onSearchChanged: onSearchChanged,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: NotificationIconButton(
                notificationCount: notifications.where((n) => !n.isRead).length,
                onPressed: () {},
                notifications: notifications,
              ),
            ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${filteredTx.length} resultado${filteredTx.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
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

class _SummaryGridView extends StatelessWidget {
  final FinanceAppState state;
  final ColorScheme cs;

  const _SummaryGridView({
    required this.state,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _SummaryGridCard(
          label: 'Ingresos mensuales',
          value: state.monthlyIncome,
          icon: AppleIcon.arrowUpRight,
          color: Colors.green[700],
        ),
        _SummaryGridCard(
          label: 'Gastos mensuales',
          value: state.monthlyExpense,
          icon: AppleIcon.arrowDownLeft,
          color: cs.error,
        ),
        _SummaryGridCard(
          label: 'Total ingresos',
          value: state.totalIncomeAllTime,
          icon: AppleIcon.chartUp,
          color: Colors.blue[700],
        ),
        _SummaryGridCard(
          label: 'Total gastos',
          value: state.totalExpenseAllTime,
          icon: AppleIcon.chartDown,
          color: Colors.orange[700],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final FinanceAppState state;

  const _BalanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final balance = state.currentBalance ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu balance actual',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            MoneyText(
              balance,
              fontSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGridCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color? color;

  const _SummaryGridCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (color ?? cs.primary).withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color ?? cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: MoneyText(
                value,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppleIcon {
  static const IconData arrowUpRight = Icons.arrow_outward;
  static const IconData arrowDownLeft = Icons.arrow_outward;
  static const IconData chartUp = Icons.trending_up_rounded;
  static const IconData chartDown = Icons.trending_down_rounded;
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
        color: _isFocused ? cs.surfaceContainerHigh : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isFocused ? cs.primary.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
            color: _isFocused ? cs.primary : cs.onSurface.withOpacity(0.5),
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
            horizontal: 8,
          ),
        ),
      ),
    );
  }
}