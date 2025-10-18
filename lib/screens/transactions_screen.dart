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

    // Lista de categorías
    final List<String> categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category).toSet(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: AppleSearchBar(
          controller: _searchController,
          onSearchChanged: (value) {
            setState(() => _query = value);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                AppleSummaryChip(label: 'Gastos', value: '\$1223.00'),
                AppleSummaryChip(label: 'Ingresos', value: '\$4500.00'),
              ],
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                AppleDropdownButton(
                  value: _typeFilter,
                  items: const ['Todos', 'Gastos', 'Ingresos'],
                  onChanged: (v) => setState(() => _typeFilter = v),
                ),
                const SizedBox(width: 12),
                AppleDropdownButton(
                  value: _categoryFilter,
                  items: categories,
                  onChanged: (v) => setState(() => _categoryFilter = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lista de transacciones
          Expanded(
            child: txs.isEmpty
                ? Center(
                    child: Text(
                      'No hay transacciones',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: txs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionCard(tx: txs[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Barra de búsqueda estilo Apple
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? cs.surfaceContainerHigh.withOpacity(
                    0.6 + (_focusController.value * 0.2))
                : cs.surfaceContainerHighest.withOpacity(
                    0.8 + (_focusController.value * 0.2)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? cs.primary.withOpacity(_focusController.value * 0.3)
                  : cs.outlineVariant.withOpacity(_focusController.value * 0.5),
              width: 0.5,
            ),
            boxShadow: [
              if (_focusController.value > 0)
                BoxShadow(
                  color: cs.primary.withOpacity(_focusController.value * 0.1),
                  blurRadius: 8 * _focusController.value,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onSearchChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                color: cs.onSurfaceVariant.withOpacity(0.6),
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
                        color: cs.onSurfaceVariant.withOpacity(0.6),
                        size: 18,
                      ),
                    )
                  : null,
              hintText: 'Buscar transacciones...',
              hintStyle: TextStyle(
                color: cs.onSurfaceVariant.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface,
            ),
            cursorColor: cs.primary,
          ),
        );
      },
    );
  }
}

/// Dropdown estilo Apple - Minimalista
class AppleDropdownButton extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const AppleDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
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
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        items: widget.items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor),
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
        isExpanded: false,
        icon: Icon(
          Icons.unfold_more_rounded,
          size: 18,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Chip de resumen estilo Apple
class AppleSummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const AppleSummaryChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = label.toLowerCase() == 'gastos';
    final labelColor = isDark ? Colors.white : Colors.black87;
    final valueColor = isExpense ? Colors.red[500] : Colors.green[500];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isExpense
            ? Colors.red[500]?.withOpacity(0.12)
            : Colors.green[500]?.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isExpense
              ? Colors.red[300]?.withOpacity(0.3) ?? Colors.transparent
              : Colors.green[300]?.withOpacity(0.3) ?? Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: labelColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}