import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiChatService {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return content;
      } else {
        return 'Error al procesar tu solicitud';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}