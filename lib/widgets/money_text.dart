import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class MoneyText extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final Color? color;
  final int? fontSize;

  const MoneyText(
    this.value, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
  });
  
  get moneyFormatter => null;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleMedium;
    
    return Text(
      moneyFormatter.format(value),
      style: baseStyle?.copyWith(
        color: color,
        fontSize: fontSize?.toDouble(),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}