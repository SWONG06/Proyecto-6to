class FinancialNews {
  final String id;
  final String title;
  final String description;
  final String source;
  final String imageUrl;
  final DateTime publishedAt;
  final String url;
  final String category;
  final String program;
  final String content; // ✅ agregado correctamente

  FinancialNews({
    required this.id,
    required this.title,
    this.description = '',
    required this.source,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
    required this.category,
    this.program = '',
    this.content = '', // ✅ se declara aquí correctamente
  });

  factory FinancialNews.fromJson(Map<String, dynamic> json) {
    return FinancialNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      url: json['url'] ?? '',
      category: json['category'] ?? 'General',
      program: json['program'] ?? '',
      content: json['content'] ?? '', // ✅ agregado al factory
    );
  }
}
