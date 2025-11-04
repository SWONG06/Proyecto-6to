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
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final year = now.month == 1 ? now.year - 1 : now.year;

    return _transactions
        .where((tx) =>
            tx.type == TxType.income &&
            tx.date.month == lastMonth &&
            tx.date.year == year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getLastMonthExpense() {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final year = now.month == 1 ? now.year - 1 : now.year;

    return _transactions
        .where((tx) =>
            tx.type == TxType.expense &&
            tx.date.month == lastMonth &&
            tx.date.year == year)
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

  double get reportThisMonthExpenseVarPct {
    final currentExpense = _getCurrentMonthExpense();
    final lastExpense = getLastMonthExpense();
    
    if (lastExpense == 0) return 0.0;
    return ((currentExpense - lastExpense) / lastExpense) * 100;
  }

  double get reportThisMonthMarginPct {
    final currentIncome = _getCurrentMonthIncome();
    final currentExpense = _getCurrentMonthExpense();
    
    if (currentIncome == 0) return 0.0;
    return ((currentIncome - currentExpense) / currentIncome) * 100;
  }

  double _getCurrentMonthIncome() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.type == TxType.income &&
            tx.date.month == now.month &&
            tx.date.year == now.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double _getCurrentMonthExpense() {
    final now = DateTime.now();
    return _transactions
        .where((tx) =>
            tx.type == TxType.expense &&
            tx.date.month == now.month &&
            tx.date.year == now.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  static Future<FinanceAppState> seed() async {
    final state = FinanceAppState();
    
    // Añadir transacciones de ejemplo
    state.addTransaction(
      FinanceTransaction(
        id: 't1',
        title: 'Compra supermercado',
        amount: 120.50,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Alimentación',
        type: TxType.expense, paymentMethod: '',
      ),
    );

    state.addTransaction(
      FinanceTransaction(
        id: 't2',
        title: 'Salario',
        amount: 2500.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Ingresos',
        type: TxType.income, paymentMethod: '',
      ),
    );

    // Añadir tarjetas de ejemplo
    state.addCard(
      FinanceCard(
        id: 'card1',
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
    );

    state.addCard(
      FinanceCard(
        id: 'card2',
        name: 'Débito Interbank',
        bank: 'Interbank',
        number: '9876',
        type: CardType.debit,
        currentUsage: 800,
        limit: 0,
        usagePercentage: 0,
        daysUntilCutoff: null,
      ),
    );

    return state;
  }
}