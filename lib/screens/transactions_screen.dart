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
  late AnimationController _themeAnimationController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchController = TextEditingController();

    if (widget.themeMode == ThemeMode.dark) {
      _themeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    // Filtro de transacciones
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

    // Cálculo de totales
    double totalExpenses = widget.state.transactions
        .where((t) => t.type == TxType.expense)
        .fold(0, (sum, t) => sum + t.amount);
    double totalIncomes = widget.state.transactions
        .where((t) => t.type == TxType.income)
        .fold(0, (sum, t) => sum + t.amount);

    // Lista de categorías
    final List<String> categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category).toSet(),
    ];

    return Scaffold(
      backgroundColor: cs.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mejorado
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Transacciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Barra de búsqueda mejorada
                AppleSearchBar(
                  controller: _searchController,
                  onSearchChanged: (value) {
                    setState(() => _query = value);
                  },
                ),
              ],
            ),
          ),

          // Resumen mejorado
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppleSummaryCard(
                        label: 'Gastos',
                        value: totalExpenses,
                        isExpense: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppleSummaryCard(
                        label: 'Ingresos',
                        value: totalIncomes,
                        isExpense: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filtros mejorados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppleDropdownButton(
                    value: _typeFilter,
                    items: const ['Todos', 'Gastos', 'Ingresos'],
                    onChanged: (v) => setState(() => _typeFilter = v),
                    label: 'Tipo',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppleDropdownButton(
                    value: _categoryFilter,
                    items: categories,
                    onChanged: (v) => setState(() => _categoryFilter = v),
                    label: 'Categoría',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lista de transacciones
          Expanded(
            child: txs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 40,
                            color: cs.primary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No hay transacciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comienza agregando una transacción',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: txs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TransactionCard(tx: txs[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Barra de búsqueda estilo Apple premium
class AppleSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  const AppleSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<AppleSearchBar> createState() => _AppleSearchBarState();
}

class _AppleSearchBarState extends State<AppleSearchBar>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _focusController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: cs.primary.withOpacity(
                0.2 + (_focusController.value * 0.5),
              ),
              width: 1.5,
            ),
            boxShadow: [
              if (_focusController.value > 0.1)
                BoxShadow(
                  color: cs.primary.withOpacity(_focusController.value * 0.2),
                  blurRadius: 16 * _focusController.value,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.search_rounded,
                  color: cs.primary.withOpacity(0.6),
                  size: 22,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        widget.onSearchChanged('');
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.cloud_circle_rounded,
                          color: cs.primary.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    )
                  : null,
              hintText: 'Buscar transacciones...',
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: cs.primary,
          ),
        );
      },
    );
  }
}

/// Dropdown estilo Apple premium
class AppleDropdownButton extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? label;

  const AppleDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
  });

  @override
  State<AppleDropdownButton> createState() => _AppleDropdownButtonState();
}

class _AppleDropdownButtonState extends State<AppleDropdownButton> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(AppleDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
          ],
          DropdownButton<String>(
            value: _currentValue,
            items: widget.items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
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
              Icons.expand_more_rounded,
              size: 22,
              color: cs.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de resumen estilo Apple premium
class AppleSummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final bool isExpense;

  const AppleSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.isExpense,
  });

  String _formatCurrency(double amount) {
    return 'S/ ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    final bgColor = isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF51CF66);
    final borderColor = isExpense ? const Color(0xFFFF5252) : const Color(0xFF40C057);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor.withOpacity(0.15),
            bgColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor.withOpacity(0.2),
                ),
                child: Icon(
                  isExpense
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 18,
                  color: bgColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              color: bgColor,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}