import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';
  
  // ✅ Variables globales para mantener datos del usuario logueado
  static int? userId;
  static String? userName;
  static String? userEmail;

  static Future<bool> healthCheck() async {
    final url = Uri.parse('$baseUrl/health');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  // ✅ Login con email y password
  static Future<Map<String, dynamic>> loginUsuario(
    String email,
    String password, {required String correo}
  ) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // ✅ Registro de usuario
  static Future<Map<String, dynamic>> registrarUsuario(
    String nombre,
    String nombreUsuario,
    String correo,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'nombreUsuario': nombreUsuario,
        'email': correo,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false, 'message': 'Error al registrar usuario'};
    }
  }

  // ✅ Logout (simple)
  static Future<void> logout() async {
    userId = null;
    userName = null;
    userEmail = null;
  }
}