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

    // Lista de categorías (ahora tipo List<String>)
    final List<String> categories = [
      'Todas',
      ...widget.state.transactions.map((e) => e.category),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _ModernThemeToggle(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen fijo (puedes reemplazar valores luego)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _SummaryChip(label: 'Gastos', value: '\$1223.00'),
                _SummaryChip(label: 'Ingresos', value: '\$4500.00'),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar transacciones...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              DropdownButton<String>(
                value: _typeFilter,
                items: const [
                  DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                  DropdownMenuItem(value: 'Gastos', child: Text('Gastos')),
                  DropdownMenuItem(value: 'Ingresos', child: Text('Ingresos')),
                ],
                onChanged: (v) => setState(() => _typeFilter = v!),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _categoryFilter,
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryFilter = v!),
              ),
            ]),
          ),
          const SizedBox(height: 8),

          // Lista de transacciones
          Expanded(
            child: ListView.builder(
              itemCount: txs.length,
              itemBuilder: (_, i) => TransactionCard(tx: txs[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const _ModernThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final progress = animationController.value;

          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFFFB347),
                    const Color(0xFF1A1A2E),
                    progress,
                  )!,
                  Color.lerp(
                    const Color(0xFFFFD700),
                    const Color(0xFF16213E),
                    progress,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (progress > 0.5)
                  Positioned.fill(
                    child: CustomPaint(
                      painter:
                          _StarsPainter(opacity: (progress - 0.5) * 2),
                    ),
                  ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: isDark
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                            scale: animation, child: child);
                      },
                      child: isDark
                          ? Icon(
                              Icons.nightlight_round,
                              key: const ValueKey('dark'),
                              color: const Color(0xFF1A1A2E),
                              size: 16,
                            )
                          : Icon(
                              Icons.wb_sunny_rounded,
                              key: const ValueKey('light'),
                              color: const Color(0xFFFFB347),
                              size: 16,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double opacity;

  const _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    final stars = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                color: cs.primary, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
