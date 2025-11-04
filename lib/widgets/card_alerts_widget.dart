// 📁 lib/widgets/card_alerts_widget.dart
import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/formatters.dart';

class CardAlertsWidget extends StatelessWidget {
  final List<FinanceCard> cards;

  const CardAlertsWidget({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (cards.isEmpty) {
      return const Center(child: Text('No hay tarjetas registradas'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final card = cards[i];
        final dias = card.daysUntilCutoff ?? 0;

        return Card(
          color: cs.surfaceContainerHighest,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              card.type == CardType.credit
                  ? Icons.credit_card
                  : Icons.credit_score,
              color: cs.primary,
            ),
            title: Text(card.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              dias > 0
                  ? "Faltan $dias días para el corte"
                  : "Fecha de corte alcanzada",
              style: TextStyle(
                color: dias <= 3 ? Colors.redAccent : cs.onSurfaceVariant,
              ),
            ),
            trailing: Text(
              pct(card.usagePercentage),
              style: TextStyle(
                color: card.usagePercentage >= 80
                    ? Colors.red
                    : Colors.greenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
