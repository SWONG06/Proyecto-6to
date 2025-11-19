// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';

class MarketNewsScreen extends StatefulWidget {
  const MarketNewsScreen({super.key});

  @override
  State<MarketNewsScreen> createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<NewsItem>> _crezcoNews;
  late Future<List<NewsItem>> _triNews;
  
  static const String apiKey = '2f7109887e404e9a9f0a1a3282a78651';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _crezcoNews = _fetchCrezcoNews();
    _triNews = _fetchTriNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<NewsItem>> _fetchCrezcoNews() async {
    try {
      const url = 'https://newsapi.org/v2/everything?q=finanzas%20perú&sortBy=publishedAt&language=es&pageSize=10&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articles = (json['articles'] as List? ?? [])
            .take(10)
            .map((article) => NewsItem(
              title: article['title'] ?? 'Sin título',
              description: article['description'] ?? 'Sin descripción',
              fullContent: article['content'] ?? article['description'] ?? 'Sin contenido',
              category: 'Cresco',
              time: _getTimeAgo(DateTime.parse(article['publishedAt'] ?? DateTime.now().toString())),
              icon: Icons.trending_up,
              color: const Color(0xFF2563EB),
              url: article['url'] ?? '',
              imageUrl: article['urlToImage'] ?? '',
            ))
            .toList();
        return articles;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return [];
  }

  Future<List<NewsItem>> _fetchTriNews() async {
    try {
      const url = 'https://newsapi.org/v2/everything?q=criptomonedas%20bitcoin&sortBy=publishedAt&language=es&pageSize=10&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final articles = (json['articles'] as List? ?? [])
            .take(10)
            .map((article) => NewsItem(
              title: article['title'] ?? 'Sin título',
              description: article['description'] ?? 'Sin descripción',
              fullContent: article['content'] ?? article['description'] ?? 'Sin contenido',
              category: 'TRII',
              time: _getTimeAgo(DateTime.parse(article['publishedAt'] ?? DateTime.now().toString())),
              icon: Icons.currency_bitcoin,
              color: const Color(0xFFF59E0B),
              url: article['url'] ?? '',
              imageUrl: article['urlToImage'] ?? '',
            ))
            .toList();
        return articles;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
    return [];
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    }
    return 'Ahora';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        title: const Text(
          'Noticias',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            indicatorColor: cs.primary,
            indicatorWeight: 2,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Cresco'),
              Tab(text: 'TRII'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNewsTab(),
          _buildNewsTabFromFuture(_crezcoNews),
          _buildNewsTabFromFuture(_triNews),
        ],
      ),
    );
  }

  Widget _buildAllNewsTab() {
    return FutureBuilder<List<List<NewsItem>>>(
      future: Future.wait([_crezcoNews, _triNews]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.hasError) {
          return _buildEmptyState();
        }

        final allNews = [...?snapshot.data?[0], ...?snapshot.data?[1]];
        
        if (allNews.isEmpty) {
          return _buildEmptyState();
        }

        return _buildNewsList(allNews);
      },
    );
  }

  Widget _buildNewsTabFromFuture(Future<List<NewsItem>> future) {
    return FutureBuilder<List<NewsItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty || snapshot.hasError) {
          return _buildEmptyState();
        }

        return _buildNewsList(snapshot.data!);
      },
    );
  }

  Widget _buildNewsList(List<NewsItem> news) {
    if (news.isEmpty) {
      return _buildEmptyState();
    }

    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: news.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NewsCard(
          news: news[index],
          cs: cs,
          onTap: () => _navigateToDetail(context, news[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_outlined,
            size: 56,
            color: cs.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin noticias disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Intenta más tarde',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
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

class NewsCard extends StatelessWidget {
  final NewsItem news;
  final ColorScheme cs;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cs.surfaceContainer,
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: news.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: news.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          news.icon,
                          size: 14,
                          color: news.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          news.category,
                          style: TextStyle(
                            color: news.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    news.time,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              if (news.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    news.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: cs.surfaceContainerHighest,
                    ),
                  ),
                ),
              
              if (news.imageUrl.isNotEmpty)
                const SizedBox(height: 10),
              
              Text(
                news.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.3,
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              Text(
                news.description,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Leer más',
                      style: TextStyle(
                        color: news.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: news.color,
                      size: 14,
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
          'Noticia',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  news.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: cs.surfaceContainer,
                    child: Icon(
                      Icons.image_not_supported,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: news.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(news.icon, size: 16, color: news.color),
                  const SizedBox(width: 6),
                  Text(
                    news.category,
                    style: TextStyle(
                      color: news.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            
            Text(
              news.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            
            Text(
              news.time,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            
            Text(
              news.fullContent,
              style: TextStyle(
                fontSize: 15,
                color: cs.onSurface.withOpacity(0.8),
                height: 1.7,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: news.url.isEmpty ? null : () => _launchUrl(news.url),
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text(
                  'Ver fuente original',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  backgroundColor: news.color,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    debugPrint('=== INICIANDO LAUNCH URL ===');
    debugPrint('URL recibida: "$urlString"');
    
    if (urlString.isEmpty) {
      debugPrint('URL vacía, abortando');
      return;
    }
    
    try {
      String url = urlString.trim();
      debugPrint('URL después de trim: "$url"');
      
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      debugPrint('URL final: "$url"');
      
      final uri = Uri.parse(url);
      debugPrint('URI parseada: $uri');
      
      // Lanzar directamente sin verificar canLaunchUrl
      debugPrint('Intentando lanzar URL directamente...');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('URL lanzada exitosamente');
      
    } catch (e) {
      debugPrint('ERROR CAPTURADO: $e');
      debugPrint('Stack trace: ${e.toString()}');
    }
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
  final String url;
  final String imageUrl;

  NewsItem({
    required this.title,
    required this.description,
    required this.fullContent,
    required this.category,
    required this.time,
    required this.icon,
    required this.color,
    required this.url,
    required this.imageUrl,
  });
}