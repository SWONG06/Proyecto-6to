import '../models/finance_models.dart';

class FinanceAppState {
  final List<Transaction> transactions;
  final List<FinanceCard> cards;

  FinanceAppState({
    required this.transactions,
    required this.cards,
  });

  // Constructor inicial con datos de ejemplo
  factory FinanceAppState.seed() {
    return FinanceAppState(
      transactions: [
        Transaction(
          id: 't1',
          title: 'Compra supermercado',
          amount: 120.50,
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Alimentos',
          type: TransactionType.expense,
        ),
        Transaction(
          id: 't2',
          title: 'Salario',
          amount: 2500.00,
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Ingresos',
          type: TransactionType.income,
        ),
      ],
      cards: [
        FinanceCard(
          name: 'Visa BCP',
          bank: 'BCP',
          number: '1234',
          type: CardType.credit,
          cutoffDate: DateTime.now().add(const Duration(days: 3)),
          paymentDay: 20,
          currentUsage: 1200,
          limit: 2000,
          usagePercentage: 60,
          daysUntilCutoff: 3,
        ),
        FinanceCard(
          name: 'Débito Interbank',
          bank: 'Interbank',
          number: '9876',
          type: CardType.debit,
          currentUsage: 800,
          limit: 0,
          usagePercentage: 0,
          daysUntilCutoff: null,
        ),
      ],
    );
  }
}
// 📁 lib/state/finance_app_state.dart
import 'package:flutter/material.dart';
import '../models/finance_models.dart';

class FinanceAppState extends ChangeNotifier {
  final List<FinanceTransaction> _transactions = [];
  final List<FinanceCard> _cards = [];
  final List<FinancialNews> _news = [];

  List<FinanceTransaction> get transactions => _transactions;
  List<FinanceCard> get cards => _cards;
  List<FinancialNews> get news => _news;

  void addTransaction(FinanceTransaction tx) {
    _transactions.add(tx);
    notifyListeners();
  }

  void addCard(FinanceCard card) {
    _cards.add(card);
    notifyListeners();
  }

  void addNews(FinancialNews item) {
    _news.add(item);
    notifyListeners();
  }

  // 🔹 Métodos de reporte
  double getLastMonthIncome() {
    return _transactions
        .where((tx) =>
            tx.type == TxType.income &&
            tx.date.month == DateTime.now().month - 1)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getLastMonthExpense() {
    return _transactions
        .where((tx) =>
            tx.type == TxType.expense &&
            tx.date.month == DateTime.now().month - 1)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Map<String, double> get categoryDistribution {
    final Map<String, double> totals = {};
    for (final tx in _transactions) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }

  // 🔹 Datos de tendencia (ejemplo simple)
  List<String> get months => ['Ago', 'Sep', 'Oct', 'Nov'];
  List<double> get trendProfit => [800, 950, 1000, 1200];
  List<double> get trendExpense => [500, 650, 700, 850];
}
