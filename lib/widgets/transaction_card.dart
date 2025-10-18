import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/finance_models.dart';
import '../utils/format.dart';
import 'money_text.dart';

class TransactionCard extends StatelessWidget {
  final FinanceTransaction tx;
  const TransactionCard({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TxType.expense;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isExpense ? cs.error : cs.primary).withOpacity(
            0.12,
          ),
          child: Icon(
            isExpense
                ? CupertinoIcons.arrow_down_left
                : CupertinoIcons.arrow_up_right,
            color: isExpense ? cs.error : cs.primary,
          ),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${tx.category} • ${dateShort(tx.date)} • ${tx.paymentMethod}',
        ),
        trailing: MoneyText(
          isExpense ? -tx.amount : tx.amount,
          color: isExpense ? cs.error : Colors.green,
          style: const TextStyle(fontWeight: FontWeight.w700), fontSize: 24,
        ),
      ),
    );
  }
}
