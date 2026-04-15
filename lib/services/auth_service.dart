import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';

/// Excepción personalizada que trae el mensaje de error del servidor.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _baseUrl = 'https://w2z.matwa.is-cool.dev';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  /// POST /api/auth/login
  /// Body: { email, password }
  /// Returns: AuthResponse con access_token y user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw const AuthException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }

    final body = _decodeBody(response);

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(body);
    }

    // Error del servidor: extraer mensaje legible
    final msg = body['detail']?.toString() ??
        body['message']?.toString() ??
        'Correo o contraseña incorrectos.';
    throw AuthException(msg);
  }

  // ── REGISTER ───────────────────────────────────────────────────────────────
  /// POST /api/auth/register
  /// Body: { email, password, name }
  /// Returns: AuthResponse con access_token y user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/auth/register');

    late http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw const AuthException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }

    final body = _decodeBody(response);

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(body);
    }

    final msg = body['detail']?.toString() ??
        body['message']?.toString() ??
        'No se pudo crear la cuenta. Intenta de nuevo.';
    throw AuthException(msg);
  }

  // ── Helper: decodificar respuesta JSON ────────────────────────────────────
  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
