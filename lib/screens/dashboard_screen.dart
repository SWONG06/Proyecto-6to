import 'package:flutter/material.dart';
import 'package:financecloud/models/financial_news.dart';
import 'package:financecloud/services/gemini_chat_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
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

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late GeminiChatService _geminiService;
  bool _showAvatarChat = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiChatService();
  }

  List<FinancialNews> _getDemoNews() {
    return [
      FinancialNews(
        id: '1',
        title: 'Nuevas tendencias en inversión sostenible',
        description: 'Descubre cómo las inversiones sostenibles están cambiando el panorama financiero global.',
        content: 'Las inversiones sostenibles están ganando terreno rápidamente, combinando rentabilidad y responsabilidad social...',
        category: 'Inversiones',
        program: 'Cresco',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        imageUrl: '',
      ),
      FinancialNews(
        id: '2',
        title: 'Cómo optimizar tus finanzas personales',
        description: 'Estrategias efectivas para mejorar tu salud financiera y tus hábitos de ahorro.',
        content: 'La planificación financiera personal es fundamental para mantener estabilidad y alcanzar metas a largo plazo...',
        category: 'Finanzas Personales',
        program: 'Tree',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: '',
      ),
      FinancialNews(
        id: '3',
        title: 'El futuro de las criptomonedas',
        description: 'Análisis de las tendencias y predicciones para el mercado cripto global.',
        content: 'El mercado de criptomonedas continúa evolucionando con nuevas regulaciones y tecnologías emergentes...',
        category: 'Criptos',
        program: 'Cresco',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: '',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _showAvatarChat = !_showAvatarChat);
        },
        backgroundColor: cs.primary,
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header Premium
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenido",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onBackground.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Resumen general",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onBackground,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToProfile,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.primary.withBlue(220)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(Icons.account_circle_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Tarjeta Principal Premium
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withBlue(220)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Saldo Total",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Premium",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "S/ 3,560.00",
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceMetric("Ingresos", "S/ 4,200.00", Colors.white),
                            _buildBalanceMetric("Gastos", "S/ 640.00", Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Sección Estadísticas
                  Text(
                    "Estadísticas",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Ingresos",
                          "S/ 4,200.00",
                          Icons.trending_up_rounded,
                          Colors.green,
                          cs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Gastos",
                          "S/ 640.00",
                          Icons.trending_down_rounded,
                          Colors.red,
                          cs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Noticias
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "📰 Noticias",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onBackground,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Ver más",
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: news.map((item) => _buildModernNewsCard(context, item, cs)).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (_showAvatarChat)
              BankingAvatarChat(
                geminiService: _geminiService,
                onClose: () {
                  setState(() => _showAvatarChat = false);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceMetric(String title, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor.withOpacity(0.7),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNewsCard(BuildContext context, FinancialNews item, ColorScheme cs) {
    IconData iconForCategory(String category) {
      switch (category.toLowerCase()) {
        case 'inversiones':
          return Icons.trending_up;
        case 'criptos':
          return Icons.currency_bitcoin;
        case 'finanzas personales':
          return Icons.wallet;
        default:
          return Icons.newspaper;
      }
    }

    Color colorForCategory(String category) {
      switch (category.toLowerCase()) {
        case 'inversiones':
          return const Color(0xFF2196F3);
        case 'criptos':
          return const Color(0xFFFF9800);
        case 'finanzas personales':
          return const Color(0xFF4CAF50);
        default:
          return cs.primary;
      }
    }

    final icon = iconForCategory(item.category);
    final color = colorForCategory(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurface.withOpacity(0.65),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.program,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      _formatDate(item.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BankingAvatarChat extends StatefulWidget {
  final GeminiChatService geminiService;
  final VoidCallback onClose;

  const BankingAvatarChat({
    super.key,
    required this.geminiService,
    required this.onClose,
  });

  @override
  State<BankingAvatarChat> createState() => _BankingAvatarChatState();
}

class _BankingAvatarChatState extends State<BankingAvatarChat> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '¡Hola! Soy tu asistente financiero. 💳 ¿En qué puedo ayudarte con tus finanzas?',
      isUser: false,
    ),
  ];
  bool _isLoading = false;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final context = '''Eres un asistente financiero amigable para una app de finanzas personales llamada "FinanceCloud".
La app tiene las siguientes características principales:
- Resumen general: Saldo total (S/ 3,560.00), Ingresos (S/ 4,200.00), Gastos (S/ 640.00)
- Programas: "Cresco" (inversiones sostenibles) y "Tree" (finanzas personales)
- Secciones: Dashboard, Transacciones, Reportes, Tarjetas, Notificaciones, Configuración
- Funcionalidades: Seguimiento de gastos, inversiones, análisis de finanzas, noticias financieras
Responde siempre en español, de forma amigable y profesional. Si el usuario pregunta sobre temas no relacionados con finanzas o la app, redirige amablemente hacia temas financieros.
Pregunta del usuario: $userMessage''';

      final response = await widget.geminiService.sendMessage(context);

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(text: '⚠️ Error al conectar: ${e.toString()}', isUser: false),
        );
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.primary.withBlue(220)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asistente Financiero',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Listo para ayudarte',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: cs.onSurface),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: message.isUser
                            ? LinearGradient(
                          colors: [cs.primary, cs.primary.withBlue(220)],
                        )
                            : null,
                        color: !message.isUser ? cs.surfaceContainerHighest : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: (message.isUser ? cs.primary : Colors.black).withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : cs.onSurface,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pensando...',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'Pregunta sobre tus finanzas...',
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(Icons.edit_rounded, color: cs.primary, size: 20),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: cs.primary,
                    elevation: 6,
                    onPressed: _isLoading ? null : _sendMessage,
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
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

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}