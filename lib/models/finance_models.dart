// 📁 lib/models/finance_models.dart
import 'package:flutter/material.dart';

/// Tipo de transacción
enum TxType { income, expense }

/// Tipo de tarjeta
enum CardType { credit, debit }

/// Transacción individual
class FinanceTransaction {
  final String title;
  final String category;
  final String paymentMethod;
  final double amount;
  final DateTime date;
  final TxType type;
  final String? description;

  FinanceTransaction({
    required this.title,
    required this.category,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
  });
}

/// Tarjeta bancaria
class FinanceCard {
  final String name;
  final String bank;
  final String number;
  final CardType type;
  final DateTime? cutoffDate;
  final int? paymentDay;
  final double currentUsage;
  final double limit;
  final double usagePercentage;
  final int? daysUntilCutoff;

  FinanceCard({
    required this.name,
    required this.bank,
    required this.number,
    required this.type,
    this.cutoffDate,
    this.paymentDay,
    required this.currentUsage,
    required this.limit,
    required this.usagePercentage,
    this.daysUntilCutoff,
  });
}

/// Noticia financiera
class FinancialNews {
  final String title;
  final String summary;
  final String? source;
  final DateTime? publishDate;
  final String? program;

  FinancialNews({
    required this.title,
    required this.summary,
    this.source,
    this.publishDate,
    this.program,
  });
}
