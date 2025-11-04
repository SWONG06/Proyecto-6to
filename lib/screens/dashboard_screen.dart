import 'package:flutter/material.dart';
import 'package:financecloud/models/financial_news.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final dynamic state;
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onNavigateToProfile;
  final List<dynamic> notifications;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onNavigateToProfile,
    required this.notifications,
  });

  /// Noticias de demostración
  List<FinancialNews> _getDemoNews() {
    return [
      FinancialNews(
        id: '1',
        title: 'Nuevas tendencias en inversión sostenible',
        description:
            'Descubre cómo las inversiones sostenibles están cambiando el panorama financiero global.',
        content:
            'Las inversiones sostenibles están ganando terreno rápidamente, combinando rentabilidad y responsabilidad social...',
        category: 'Inversiones',
        program: 'Cresco',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        imageUrl:
            'https://images.unsplash.com/photo-1623961983321-d2c1a42f3c4b?w=800',
      ),
      FinancialNews(
        id: '2',
        title: 'Cómo optimizar tus finanzas personales',
        description:
            'Estrategias efectivas para mejorar tu salud financiera y tus hábitos de ahorro.',
        content:
            'La planificación financiera personal es fundamental para mantener estabilidad y alcanzar metas a largo plazo...',
        category: 'Finanzas Personales',
        program: 'Tree',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl:
            'https://images.unsplash.com/photo-1605902711622-cfb43c4437b5?w=800',
      ),
      FinancialNews(
        id: '3',
        title: 'El futuro de las criptomonedas',
        description:
            'Análisis de las tendencias y predicciones para el mercado cripto global.',
        content:
            'El mercado de criptomonedas continúa evolucionando con nuevas regulaciones y tecnologías emergentes...',
        category: 'Criptos',
        program: 'Cresco',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl:
            'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final news = _getDemoNews();

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Resumen general",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onBackground,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Saldo total", "S/ 3,560.00", Icons.account_balance_wallet_rounded, cs.primary),
                    _buildMetric("Ingresos", "S/ 4,200.00", Icons.trending_up_rounded, Colors.green),
                    _buildMetric("Gastos", "S/ 640.00", Icons.trending_down_rounded, Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "📰 Noticias financieras",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onBackground,
                    ),
              ),
              const SizedBox(height: 16),
              Column(
                children: news.map((item) => _buildNewsCard(context, item, cs)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNewsCard(BuildContext context, FinancialNews item, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl.isNotEmpty)
            Image.network(item.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.category.toUpperCase(),
                    style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 13.5, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Programa: ${item.program}",
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                    Text(
                      _formatDate(item.publishedAt),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
