import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import '../models/finance_models.dart' as models;
import '../utils/formatters.dart';

class CardsScreen extends material.StatefulWidget {
  final List<models.FinanceCard> cards;

  const CardsScreen({super.key, required this.cards});

  @override
  material.State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends material.State<CardsScreen> {
  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      appBar: material.AppBar(
        title: const Text('Mis Tarjetas'),
        actions: [
          material.IconButton(
            icon: const Icon(material.Icons.add),
            onPressed: () => _showAddCardDialog(context),
          ),
        ],
      ),
      body: widget.cards.isEmpty
          ? _buildEmptyState()
          : material.ListView(
              padding: const material.EdgeInsets.all(16),
              children: [
                _buildCardAlerts(),
                const material.SizedBox(height: 16),
                ...widget.cards.map((card) => _buildCardItem(card)),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return material.Center(
      child: material.Column(
        mainAxisAlignment: material.MainAxisAlignment.center,
        children: [
          material.Icon(material.Icons.credit_card_off,
              size: 80, color: material.Colors.grey[400]),
          const material.SizedBox(height: 16),
          Text('No tienes tarjetas registradas',
              style: Theme.of(context).textTheme.titleLarge),
          const material.SizedBox(height: 8),
          Text('Agrega una tarjeta para gestionar tus gastos',
              style: Theme.of(context).textTheme.bodyMedium),
          const material.SizedBox(height: 24),
          material.ElevatedButton.icon(
            icon: const Icon(material.Icons.add),
            label: const Text('Agregar Tarjeta'),
            onPressed: () => _showAddCardDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAlerts() {
    final alertCards = widget.cards
        .where((card) =>
            card.type == models.CardType.credit &&
            card.cutoffDate != null &&
            (card.daysUntilCutoff ?? 99) <= 5 &&
            (card.daysUntilCutoff ?? -1) >= 0)
        .toList();

    if (alertCards.isEmpty) return const material.SizedBox.shrink();

    return material.Container(
      padding: const material.EdgeInsets.all(16),
      decoration: material.BoxDecoration(
        color: material.Colors.amber.shade50,
        borderRadius: material.BorderRadius.circular(12),
        border: material.Border.all(color: material.Colors.amber.shade200),
      ),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.Row(
            children: [
              const material.Icon(material.Icons.warning_amber_rounded,
                  color: material.Colors.amber),
              const material.SizedBox(width: 8),
              Text('Próximos cortes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: material.FontWeight.bold)),
            ],
          ),
          const material.SizedBox(height: 8),
          ...alertCards.map((card) => material.Padding(
                padding: const material.EdgeInsets.only(top: 8),
                child: material.Row(
                  children: [
                    material.Icon(
                      (card.daysUntilCutoff ?? 99) == 0
                          ? material.Icons.today
                          : material.Icons.calendar_today,
                      size: 16,
                      color: (card.daysUntilCutoff ?? 99) == 0
                          ? material.Colors.red
                          : material.Colors.amber.shade800,
                    ),
                    const material.SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (card.daysUntilCutoff ?? 99) == 0
                            ? '${card.name} - ¡Fecha de corte HOY!'
                            : '${card.name} - Corte en ${card.daysUntilCutoff ?? 0} días',
                        style: TextStyle(
                          color: (card.daysUntilCutoff ?? 99) == 0
                              ? material.Colors.red
                              : material.Colors.amber.shade800,
                          fontWeight: material.FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCardItem(models.FinanceCard card) {
    final cardColor = card.type == models.CardType.credit
        ? const material.Color(0xFF1E3A8A)
        : const material.Color(0xFF065F46);

    return material.Container(
      margin: const material.EdgeInsets.only(bottom: 16),
      child: material.Material(
        elevation: 4,
        borderRadius: material.BorderRadius.circular(16),
        child: material.Container(
          padding: const material.EdgeInsets.all(16),
          decoration: material.BoxDecoration(
            borderRadius: material.BorderRadius.circular(16),
            gradient: material.LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardColor, cardColor.withOpacity(0.8)],
            ),
          ),
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Row(
                mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                children: [
                  Text(card.bank,
                      style: const TextStyle(
                          color: material.Colors.white70, fontSize: 14)),
                  Text(
                    card.type == models.CardType.credit ? 'Crédito' : 'Débito',
                    style: const TextStyle(
                        color: material.Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const material.SizedBox(height: 16),
              Text(card.name,
                  style: const TextStyle(
                      color: material.Colors.white,
                      fontSize: 20,
                      fontWeight: material.FontWeight.bold)),
              const material.SizedBox(height: 8),
              Text('•••• •••• •••• ${card.number}',
                  style: const TextStyle(
                      color: material.Colors.white,
                      fontSize: 16,
                      letterSpacing: 2)),
              const material.SizedBox(height: 16),

              if (card.type == models.CardType.credit) ...[
                material.Row(
                  mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                  children: [
                    material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha de corte',
                            style: TextStyle(
                                color: material.Colors.white70, fontSize: 12)),
                        Text(
                          card.cutoffDate != null
                              ? formatDate(card.cutoffDate!)
                              : 'No disponible',
                          style: const TextStyle(
                              color: material.Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.end,
                      children: [
                        const Text('Día de pago',
                            style: TextStyle(
                                color: material.Colors.white70, fontSize: 12)),
                        Text(
                          card.paymentDay != null
                              ? 'Día ${card.paymentDay}'
                              : 'No disponible',
                          style: const TextStyle(
                              color: material.Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const material.SizedBox(height: 16),
                material.Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Uso actual',
                            style: TextStyle(
                                color: material.Colors.white70, fontSize: 12)),
                        Text(
                          '${card.usagePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: card.usagePercentage > 80
                                ? material.Colors.red.shade300
                                : material.Colors.white,
                            fontWeight: material.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const material.SizedBox(height: 4),
                    material.ClipRRect(
                      borderRadius: material.BorderRadius.circular(4),
                      child: material.LinearProgressIndicator(
                        value: card.usagePercentage / 100,
                        backgroundColor: material.Colors.white24,
                        valueColor: material.AlwaysStoppedAnimation<Color>(
                          card.usagePercentage > 80
                              ? material.Colors.red.shade300
                              : material.Colors.green.shade300,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const material.SizedBox(height: 8),
                    material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatCurrency(card.currentUsage),
                            style: const TextStyle(
                                color: material.Colors.white, fontSize: 14)),
                        Text(formatCurrency(card.limit),
                            style: const TextStyle(
                                color: material.Colors.white, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
              const material.SizedBox(height: 16),
              material.Row(
                mainAxisAlignment: material.MainAxisAlignment.end,
                children: [
                  material.IconButton(
                    icon: const material.Icon(material.Icons.edit,
                        color: material.Colors.white70),
                    onPressed: () => _showEditCardDialog(context, card),
                  ),
                  material.IconButton(
                    icon: const material.Icon(material.Icons.delete,
                        color: material.Colors.white70),
                    onPressed: () => _showDeleteCardDialog(context, card),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    material.showDialog(
      context: context,
      builder: (context) => material.AlertDialog(
        title: const Text('Agregar Tarjeta'),
        content: const Text('Funcionalidad en desarrollo'),
        actions: [
          material.TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(BuildContext context, models.FinanceCard card) {
    material.showDialog(
      context: context,
      builder: (context) => material.AlertDialog(
        title: const Text('Editar Tarjeta'),
        content: Text('Editar ${card.name}'),
        actions: [
          material.TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog(BuildContext context, models.FinanceCard card) {
    material.showDialog(
      context: context,
      builder: (context) => material.AlertDialog(
        title: const Text('Eliminar Tarjeta'),
        content: Text('¿Estás seguro de eliminar ${card.name}?'),
        actions: [
          material.TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          material.TextButton(
            onPressed: () => Navigator.pop(context),
            style: material.TextButton.styleFrom(
              foregroundColor: material.Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
