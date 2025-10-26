import 'dart:math';
import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  late TextEditingController _messageController;
  late FocusNode _focusNode;
  final List<Message> _messages = [];
  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _addInitialMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add(
        Message(
          text: '¡Hola! Soy tu asistente financiero IA. ¿En qué puedo ayudarte hoy?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final response = _generateAIResponse(text);
        setState(() {
          _messages.add(
            Message(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('gasto') || message.contains('gastos')) {
      return 'Basándome en tu historial, tus gastos mensuales promedio son de \$2,150. Te recomiendo revisar la categoría de entretenimiento donde podrías ahorrar un 15%.';
    } else if (message.contains('ingreso') || message.contains('ingresos')) {
      return 'Tus ingresos mensuales totales son de \$5,200. Esto representa un crecimiento del 8% respecto al mes anterior. ¡Excelente progreso!';
    } else if (message.contains('ahorro') || message.contains('ahorrar')) {
      return 'Para mejorar tus ahorros, te sugiero:\n• Reducir gastos en comidas fuera\n• Automatizar transferencias a cuenta de ahorro\n• Revisar suscripciones no utilizadas';
    } else if (message.contains('balance') || message.contains('saldo')) {
      return 'Tu balance actual es de \$8,450.25. Este mes has ahorrado \$1,200 más que el anterior.';
    } else if (message.contains('presupuesto')) {
      return 'Te recomiendo seguir la regla 50/30/20:\n• 50% en necesidades\n• 30% en gustos\n• 20% en ahorros e inversiones';
    } else if (message.contains('inversión') || message.contains('invertir')) {
      return 'Con tu balance actual, puedes considerar: fondos indexados, fondos mutuos o cuentas de ahorro de alto rendimiento. ¿Cuál te interesa?';
    } else if (message.contains('tarjeta') || message.contains('crédito')) {
      return 'Tienes 3 tarjetas registradas. Tu límite de crédito disponible es de \$5,800. Tasa de utilización: 25%.';
    } else if (message.contains('ayuda') || message.contains('help')) {
      return 'Puedo ayudarte con:\n• Análisis de gastos e ingresos\n• Consejos de ahorro\n• Información de inversiones\n• Gestión de tarjetas de crédito\n\n¿Qué te interesa?';
    } else {
      return 'Entiendo tu pregunta. Para darte una respuesta más precisa, necesito más detalles. ¿Puedes ser más específico sobre finanzas?';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Financiero IA'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cs.surfaceContainerHighest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Sin mensajes',
                      style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TypingIndicator(cs: cs),
                        );
                      }

                      final message = _messages[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChatBubble(
                          message: message,
                          cs: cs,
                          timeFormatter: _formatTime,
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: cs.surfaceContainerHighest,
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? cs.primary.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        hintStyle: TextStyle(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => _sendMessage(_messageController.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary,
                          cs.primary.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isLoading
                            ? Icons.hourglass_bottom_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  final ColorScheme cs;
  final String Function(DateTime) timeFormatter;

  const _ChatBubble({
    required this.message,
    required this.cs,
    required this.timeFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: message.isUser
                ? cs.primary
                : cs.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser
                  ? Colors.white
                  : cs.onSurface,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          timeFormatter(message.timestamp),
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final ColorScheme cs;

  const _TypingIndicator({required this.cs});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.cs.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = sin((index / 2 + _controller.value) * pi) * 6;
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.cs.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}