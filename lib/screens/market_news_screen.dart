// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../models/finance_models.dart';

class MarketNewsScreen extends StatefulWidget {
  final List<FinancialNews>? news;
  
  const MarketNewsScreen({super.key, this.news});

  @override
  State<MarketNewsScreen> createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Todos';
  late TabController _tabController;
  
  final List<String> categories = ['Todos', 'Bancos', 'Inversiones', 'Criptos', 'Mercado'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<NewsItem> get _newsItems {
    if (widget.news != null && widget.news!.isNotEmpty) {
      return widget.news!.map((news) => NewsItem(
        title: news.title,
        description: news.summary,
        fullContent: news.summary,
        category: news.program ?? 'General',
        time: news.publishDate != null ? _getTimeAgo(news.publishDate!) : 'Reciente',
        icon: news.program == 'Cresco' ? Icons.trending_up : Icons.eco,
        color: news.program == 'Cresco' ? Colors.blue : Colors.green,
      )).toList();
    }
    
    return allNews;
  }
  
  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }
  
  final List<NewsItem> allNews = [
    NewsItem(
      title: 'Banco Central sube tasa de interés al 4.5%',
      description: 'El Banco Central anunció una subida de 50 puntos base en la tasa de política monetaria...',
      fullContent: 'El Banco Central anunció una subida de 50 puntos base en la tasa de política monetaria, llevándola del 4.0% al 4.5%. Esta decisión fue tomada en respuesta a las presiones inflacionarias observadas en los últimos meses. Los analistas esperaban esta medida para controlar la inflación y mantener la estabilidad económica. Se espera que esta decisión impacte en las tasas de los créditos y depósitos bancarios en las próximas semanas.',
      category: 'Bancos',
      time: '2 horas',
      icon: Icons.trending_up,
      color: Colors.blue,
    ),
    NewsItem(
      title: 'S&P 500 alcanza nuevo máximo histórico',
      description: 'Los índices bursátiles estadounidenses continúan su racha alcista impulsados por ganancias tecnológicas...',
      fullContent: 'Los índices bursátiles estadounidenses continúan su racha alcista impulsados por ganancias tecnológicas. El S&P 500 alcanzó un nuevo máximo histórico, superando las expectativas de los analistas. Las principales empresas de tecnología como Apple, Microsoft y Google han mostrado resultados excepcionales que han impulsado el mercado. Los inversores mantienen una visión optimista sobre el desempeño económico en los próximos trimestres.',
      category: 'Inversiones',
      time: '3 horas',
      icon: Icons.show_chart,
      color: Colors.green,
    ),
    NewsItem(
      title: 'Bitcoin supera los \$45,000',
      description: 'La criptomoneda más popular del mundo alcanza nuevos máximos en medio de una recuperación del mercado...',
      fullContent: 'La criptomoneda más popular del mundo alcanza nuevos máximos en medio de una recuperación del mercado cripto. Bitcoin ha superado la barrera psicológica de los \$45,000, impulsado por noticias positivas sobre adopción institucional. Se espera que este rally continúe en las próximas semanas si se mantiene el sentimiento positivo en el mercado. Los analistas proyectan que podría alcanzar los \$50,000 antes de fin de año.',
      category: 'Criptos',
      time: '4 horas',
      icon: Icons.currency_bitcoin,
      color: Colors.orange,
    ),
    NewsItem(
      title: 'Nuevas regulaciones fintech en la UE',
      description: 'La Unión Europea implementa nuevas medidas de control para empresas de tecnología financiera...',
      fullContent: 'La Unión Europea implementa nuevas medidas de control para empresas de tecnología financiera. Estas regulaciones buscan proteger a los consumidores y garantizar la estabilidad del sistema financiero. Las empresas fintech deberán cumplir con requisitos más estrictos de capital y transparencia. Se estima que estas medidas entrarán en vigor en el próximo trimestre.',
      category: 'Bancos',
      time: '5 horas',
      icon: Icons.security,
      color: Colors.purple,
    ),
    NewsItem(
      title: 'Ethereum supera \$2,500 en bull run',
      description: 'La segunda criptomoneda más grande por capitalización de mercado continúa su ascenso...',
      fullContent: 'La segunda criptomoneda más grande por capitalización de mercado continúa su ascenso impulsada por la actividad en DeFi. Ethereum ha superado los \$2,500 gracias al optimismo sobre las mejoras de escalabilidad. La red ha procesado un volumen récord de transacciones en las últimas semanas. Los desarrolladores continúan trabajando en mejoras de rendimiento.',
      category: 'Criptos',
      time: '6 horas',
      icon: Icons.currency_bitcoin,
      color: Colors.indigo,
    ),
    NewsItem(
      title: 'Mercado de oro cae 2.3% esta semana',
      description: 'El precio del oro retrocede debido al fortalecimiento del dólar en los mercados internacionales...',
      fullContent: 'El precio del oro retrocede debido al fortalecimiento del dólar en los mercados internacionales. El metal precioso cae 2.3% esta semana afectado por la solidez de la divisa estadounidense. Los inversores han reducido sus posiciones defensivas ante el panorama económico más positivo. Se espera que el oro continúe bajo presión si el dólar mantiene su fortaleza.',
      category: 'Mercado',
      time: '7 horas',
      icon: Icons.monetization_on,
      color: Colors.amber,
    ),
    NewsItem(
      title: 'Tech stocks en caída, preocupación por tasas',
      description: 'Los inversores reevalúan posiciones en el sector tecnológico ante expectativas de tasas más altas...',
      fullContent: 'Los inversores reevalúan posiciones en el sector tecnológico ante expectativas de tasas más altas. Las acciones de tecnología experimenta presión vendedora debido a preocupaciones sobre rentabilidad futura. Un aumento en las tasas de interés afectaría la valoración de estas empresas de alto crecimiento. Los analistas recomiendan cautela pero mantienen una visión de largo plazo positiva.',
      category: 'Inversiones',
      time: '8 horas',
      icon: Icons.trending_down,
      color: Colors.red,
    ),
    NewsItem(
      title: 'Banco XYZ lanza nueva app de inversión',
      description: 'La institución financiera ofrece a sus clientes una plataforma mejorada para invertir en bolsa...',
      fullContent: 'La institución financiera ofrece a sus clientes una plataforma mejorada para invertir en bolsa. La nueva aplicación incluye herramientas avanzados de análisis, alertas personalizadas y acceso a múltiples mercados. Los clientes podrán operaren tiempo real con comisiones reducidas. La app está disponible en iOS y Android desde hoy.',
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
    
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: Text(
          '📰 Noticias Financieras',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                indicatorColor: cs.primary,
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                tabs: const [
                  Tab(text: 'Todos'),
                  Tab(text: 'Cresco'),
                  Tab(text: 'Tree'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsTab('Todos'),
          _buildNewsTab('Cresco'),
          _buildNewsTab('Tree'),
        ],
      ),
    );
  }
  
  Widget _buildNewsTab(String program) {
    final cs = Theme.of(context).colorScheme;
    final filteredNews = program == 'Todos'
        ? _newsItems
        : _newsItems.where((news) => news.category == program).toList();
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                      side: BorderSide(
                        color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.newspaper_rounded,
                        size: 40,
                        color: cs.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay noticias disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con otra categoría',
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
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
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _NewsCard(
                  news: filteredNews[index],
                  cs: cs,
                  onTap: () => _navigateToDetail(context, filteredNews[index]),
                ),
              ),
              childCount: filteredNews.length,
            ),
          ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, NewsItem news) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _NewsCard({
    required this.news,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surface,
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                      border: Border.all(
                        color: news.color.withOpacity(0.3),
                        width: 1,
                      ),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      news.time,
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              
              Text(
                news.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              
              Text(
                news.description,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Leer más',
                      style: TextStyle(
                        color: news.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: news.color,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: const Text(
          'Detalle de Noticia',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: news.color.withOpacity(0.15),
                border: Border.all(
                  color: news.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    news.icon,
                    size: 18,
                    color: news.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    news.category,
                    style: TextStyle(
                      color: news.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              news.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: cs.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                news.time,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              news.fullContent,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.8),
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.surface,
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: cs.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoría',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          news.category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsItem {
  final String title;
  final String description;
  final String fullContent;
  final String category;
  final String time;
  final IconData icon;
  final Color color;

  NewsItem({
    required this.title,
    required this.description,
    required this.fullContent,
    required this.category,
    required this.time,
    required this.icon,
    required this.color,
  });
}