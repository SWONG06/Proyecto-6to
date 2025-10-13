// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro', // ✅ más preciso que flash
          apiKey: apiKey,
        );

  Future<Map<String, dynamic>?> analyzeReceipt(XFile imageFile) async {
    try {
      final mimeType = imageFile.path.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final imageBytes = await File(imageFile.path).readAsBytes();
      if (imageBytes.isEmpty) {
        print('⚠️ La imagen está vacía.');
        return null;
      }

      final image = DataPart(mimeType, imageBytes);

      const prompt = '''
Analiza esta imagen de un recibo o factura y devuelve **solo** un JSON con:
{
  "amount": número sin símbolos,
  "date": "YYYY-MM-DD",
  "description": nombre del comercio o concepto,
  "category": una de: Transporte, Alimentación, Suministros, Ventas, Salud, Educación, Entretenimiento, Otros,
  "paymentMethod": una de: Tarjeta Visa, Tarjeta MasterCard, Transferencia, Efectivo, Cheque, Otro
}
Responde solo con el JSON válido. No agregues texto ni explicación.
Si un dato no está claro, deja el campo vacío.
''';

      print('📤 Enviando imagen a Gemini...');

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), image])
      ]);

      final rawText = response.text?.trim() ?? '';
      print('📥 Respuesta cruda de Gemini:\n$rawText');

      if (rawText.isEmpty) {
        print('⚠️ Gemini no devolvió texto.');
        return null;
      }

      // Limpiar formato
      var cleaned = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Buscar JSON válido
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) {
        print('❌ No se encontró JSON, usando detección alternativa...');
        return _extractFallback(cleaned);
      }

      final jsonString = cleaned.substring(start, end + 1);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Asegurar que existan todas las claves
      final filled = {
        "amount": data["amount"] ?? "",
        "date": data["date"] ?? "",
        "description": data["description"] ?? "",
        "category": data["category"] ?? "",
        "paymentMethod": data["paymentMethod"] ?? "",
      };

      print('🎯 Datos extraídos: $filled');
      return filled;
    } catch (e, stack) {
      print('💥 Error analizando el recibo: $e');
      print(stack);
      return null;
    }
  }

  /// Método alternativo si Gemini no devuelve JSON puro
  Map<String, dynamic> _extractFallback(String text) {
    final regexMonto = RegExp(r'(\d+[.,]\d{2})');
    final regexFecha = RegExp(r'\d{4}[-/]\d{2}[-/]\d{2}');
    final monto = regexMonto.firstMatch(text)?.group(1) ?? "";
    final fecha = regexFecha.firstMatch(text)?.group(0) ??
        DateTime.now().toIso8601String().split('T')[0];

    return {
      "amount": monto,
      "date": fecha,
      "description": "",
      "category": "Otros",
      "paymentMethod": ""
    };
  }
}
