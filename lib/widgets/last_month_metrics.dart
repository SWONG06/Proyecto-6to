import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/formatters.dart';

class LastMonthMetrics extends StatelessWidget {
  final FinanceAppState state;
  final bool showTitle;

  const LastMonthMetrics({
    super.key,
    required this.state,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMonthIncome = state.getLastMonthIncome();
    final lastMonthExpense = state.getLastMonthExpense();
    final lastMonthBalance = lastMonthIncome - lastMonthExpense;
    final isPositiveBalance = lastMonthBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Métricas del Último Mes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  title: 'Ingresos',
                  value: lastMonthIncome,
                  icon: Icons.arrow_upward,
                  iconColor: Colors.green,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  title: 'Gastos',
                  value: lastMonthExpense,
                  icon: Icons.arrow_downward,
                  iconColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositiveBalance
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isPositiveBalance ? Icons.trending_up : Icons.trending_down,
                  color: isPositiveBalance ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance del mes',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        formatCurrency(lastMonthBalance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPositiveBalance ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveBalance
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isPositiveBalance ? 'Ahorro' : 'Déficit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPositiveBalance ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color iconColor;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              formatCurrency(value),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}