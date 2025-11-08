import 'package:financecloud/state/finance_app_state.dart';
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  final FinanceAppState state;
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;

  const TransactionsScreen({
    super.key,
    required this.state,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  String _query = '';
  String _typeFilter = 'Todos';
  String _categoryFilter = 'Todas';
  late TextEditingController _searchController;

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

    final txs = widget.state.transactions.where((t) {
      final q = _query.toLowerCase();
      final matchesQuery = _query.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.paymentMethod.toLowerCase().contains(q);
      final matchesType = _typeFilter == 'Todos' ||
          (_typeFilter == 'Gastos' && t.type == TxType.expense) ||
          (_typeFilter == 'Ingresos' && t.type == TxType.income);
      final matchesCat =
          _categoryFilter == 'Todas' || t.category == _categoryFilter;
      return matchesQuery && matchesType && matchesCat;
    }).toList();

    double totalExpenses = widget.state.transactions
        .where((t) => t.type == TxType.expense)
        .fold(0, (sum, t) => sum + t.amount);
    double totalIncomes = widget.state.transactions
        .where((t) => t.type == TxType.income)
        .fold(0, (sum, t) => sum + t.amount);

    final categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category).toSet(),
    ];

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header minimalista
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transacciones',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 20),
                  MinimalSearchBar(
                    controller: _searchController,
                    onSearchChanged: (value) {
                      setState(() => _query = value);
                    },
                  ),
                ],
              ),
            ),

            // Resumen de totales - Diseño limpio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: MinimalSummaryCard(
                      label: 'Gastos',
                      value: totalExpenses,
                      color: const Color(0xFFEF4444),
                      icon: Icons.trending_down_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MinimalSummaryCard(
                      label: 'Ingresos',
                      value: totalIncomes,
                      color: const Color(0xFF10B981),
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filtros minimalistas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: MinimalDropdown(
                      value: _typeFilter,
                      items: const ['Todos', 'Gastos', 'Ingresos'],
                      onChanged: (v) => setState(() => _typeFilter = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MinimalDropdown(
                      value: _categoryFilter,
                      items: categories,
                      onChanged: (v) => setState(() => _categoryFilter = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista de transacciones
            Expanded(
              child: txs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 56,
                            color: cs.onSurfaceVariant.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin transacciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Comienza agregando una',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: txs.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransactionCard(tx: txs[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de búsqueda minimalista
class MinimalSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const MinimalSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<MinimalSearchBar> createState() => _MinimalSearchBarState();
}

class _MinimalSearchBarState extends State<MinimalSearchBar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onSearchChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search_rounded,
          color: cs.onSurfaceVariant,
          size: 20,
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onSearchChanged('');
                  setState(() {});
                },
                child: Icon(
                  Icons.close_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              )
            : null,
        hintText: 'Buscar transacciones',
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
      cursorColor: cs.primary,
    );
  }
}

/// Tarjeta de resumen minimalista
class MinimalSummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const MinimalSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  String _formatCurrency(double amount) {
    return 'S/ ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dropdown minimalista
class MinimalDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const MinimalDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<MinimalDropdown> createState() => _MinimalDropdownState();
}

class _MinimalDropdownState extends State<MinimalDropdown> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(MinimalDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: DropdownButton<String>(
        value: _currentValue,
        items: widget.items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _currentValue = v);
            widget.onChanged(v);
          }
        },
        underline: const SizedBox(),
        isDense: true,
        isExpanded: true,
        icon: Icon(
          Icons.unfold_more_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}