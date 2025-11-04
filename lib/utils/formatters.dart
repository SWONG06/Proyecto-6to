// 📁 lib/utils/formatters.dart
import 'package:intl/intl.dart';

/// Formatea una fecha corta (por ejemplo: 03/11/2025)
String dateShort(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Formatea montos en soles (S/.)
String money(double value) {
  final format = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');
  return format.format(value);
}

/// Formatea porcentajes
String pct(double value) {
  return "${value.toStringAsFixed(1)}%";
}

/// Retorna una diferencia de días entre dos fechas
int daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays;
}
