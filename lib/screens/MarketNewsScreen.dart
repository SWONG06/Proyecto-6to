// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MarketNewsScreen extends StatefulWidget {
  const MarketNewsScreen({super.key});

  @override
  State<MarketNewsScreen> createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> {
  String _selectedCategory = 'Todos';
  
  final List<String> categories = ['Todos', 'Bancos', 'Inversiones', 'Criptos', 'Mercado'];
  
  final List<NewsItem> allNews = [
    NewsItem(
      title: 'Banco Central sube tasa de interés al 4.5%',
      description: 'El Banco Central anunció una subida de 50 puntos base en la tasa de política monetaria...',
      category: 'Bancos',
      time: '2 horas',
      icon: Icons.trending_up,
      color: Colors.blue,
    ),
    NewsItem(
      title: 'S&P 500 alcanza nuevo máximo histórico',
      description: 'Los índices bursátiles estadounidenses continúan su racha alcista impulsados por ganancias tecnológicas...',
      category: 'Inversiones',
      time: '3 horas',
      icon: Icons.show_chart,
      color: Colors.green,
    ),
    NewsItem(
      title: 'Bitcoin supera los \$45,000',
      description: 'La criptomoneda más popular del mundo alcanza nuevos máximos en medio de una recuperación del mercado...',
      category: 'Criptos',
      time: '4 horas',
      icon: Icons.currency_bitcoin,
      color: Colors.orange,
    ),
    NewsItem(
      title: 'Nuevas regulaciones fintech en la UE',
      description: 'La Unión Europea implementa nuevas medidas de control para empresas de tecnología financiera...',
      category: 'Bancos',
      time: '5 horas',
      icon: Icons.security,
      color: Colors.purple,
    ),
    NewsItem(
      title: 'Ethereum supera \$2,500 en bull run',
      description: 'La segunda criptomoneda más grande por capitalización de mercado continúa su ascenso...',
      category: 'Criptos',
      time: '6 horas',
      icon: Icons.currency_bitcoin,
      color: Colors.indigo,
    ),
    NewsItem(
      title: 'Mercado de oro cae 2.3% esta semana',
      description: 'El precio del oro retrocede debido al fortalecimiento del dólar en los mercados internacionales...',
      category: 'Mercado',
      time: '7 horas',
      icon: Icons.monetization_on,
      color: Colors.amber,
    ),
    NewsItem(
      title: 'Tech stocks en caída, preocupación por tasas',
      description: 'Los inversores reevalúan posiciones en el sector tecnológico ante expectativas de tasas más altas...',
      category: 'Inversiones',
      time: '8 horas',
      icon: Icons.trending_down,
      color: Colors.red,
    ),
    NewsItem(
      title: 'Banco XYZ lanza nueva app de inversión',
      description: 'La institución financiera ofrece a sus clientes una plataforma mejorada para invertir en bolsa...',
      category: 'Bancos',
      time: '9 horas',
      icon: Icons.phone_android,
      color: Colors.cyan,
    ),
  ];

  List<NewsItem> get filteredNews {
    if (_selectedCategory == 'Todos') {
      return allNews;
    }
    return allNews.where((news) => news.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
       
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      label: Text(category),
                      backgroundColor: cs.surfaceContainerHighest,
                      selectedColor: cs.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        if (filteredNews.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.newspaper,
                      size: 64,
                      color: cs.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay noticias en esta categoría',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _NewsCard(
                news: filteredNews[index],
                cs: cs,
              ),
              childCount: filteredNews.length,
            ),
          ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;
  final ColorScheme cs;

  const _NewsCard({
    required this.news,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Aquí puedes navegar a detalle de noticia
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cs.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: news.color.withOpacity(0.15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            news.icon,
                            size: 16,
                            color: news.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            news.category,
                            style: TextStyle(
                              color: news.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      news.time,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Text(
                  news.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                Text(
                  news.description,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Leer más →',
                    style: TextStyle(
                      color: news.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NewsItem {
  final String title;
  final String description;
  final String category;
  final String time;
  final IconData icon;
  final Color color;

  NewsItem({
    required this.title,
    required this.description,
    required this.category,
    required this.time,
    required this.icon,
    required this.color,
  });
}