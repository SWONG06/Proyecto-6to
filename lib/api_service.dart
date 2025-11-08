import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = "https://finabiz-1.onrender.com/api"; // URL base del backend

  /// Inicia sesión con email y contraseña
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }

  /// Obtiene la lista de gastos de un usuario por su ID
  Future<List<dynamic>> obtenerGastos(int idUsuario) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/gastos.php?id_usuario=$idUsuario"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al cargar gastos: $e");
    }
  }
}
