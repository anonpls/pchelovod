import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> register({required String email, required String password}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractError(response.body, fallback: 'Registration failed'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response.body, fallback: 'Login failed'));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token missing in response');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  String _extractError(String body, {required String fallback}) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['error']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}
