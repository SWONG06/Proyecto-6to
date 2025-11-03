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

    // ✅ Modelo válido para la versión 0.4.6/0.4.7
    _model = GenerativeModel(model: 'gemini-1.0-pro', apiKey: apiKey);
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      _chat ??= _model.startChat();
      final response = await _chat!.sendMessage(Content.text(userMessage));

      return response.text ??
          "🤖 No pude generar una respuesta en este momento.";
    } on NotInitializedError {
      _chat = _model.startChat();
      final response = await _chat!.sendMessage(Content.text(userMessage));
      return response.text ?? "⚠️ Error al reiniciar la sesión.";
    } catch (e) {
      return "⚠️ Error al conectar con Gemini: $e";
    }
  }
}
