import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiChatService {
  late final GenerativeModel _model;
  ChatSession? _chat;

  GeminiChatService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('❌ API Key de Gemini no encontrada en .env');
    }

    // ✅ Usa un modelo estable y soportado
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // modelo 100% compatible con v1beta
      apiKey: apiKey,
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      _chat ??= _model.startChat();
      final response = await _chat!.sendMessage(Content.text(userMessage));

      final text =
          response.text ?? "🤖 No pude generar una respuesta en este momento.";
      return _cleanMarkdown(text);
    } catch (e) {
      print('Error detallado: $e');
      return "⚠️ Error al conectar con Gemini: ${e.toString()}";
    }
  }

  /// 🧹 Limpia texto con formato Markdown (negritas, cursivas, símbolos)
  String _cleanMarkdown(String text) {
    return text
        // elimina **negrita**
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        // elimina *itálica*
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => m.group(1) ?? '')
        // elimina __negritas__ o _itálicas_
        .replaceAll('_', '')
        // elimina `código`
        .replaceAll('`', '')
        // elimina > citas
        .replaceAll('>', '')
        // elimina títulos tipo markdown (#)
        .replaceAll(RegExp(r'#{1,6} '), '')
        // normaliza saltos de línea
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
