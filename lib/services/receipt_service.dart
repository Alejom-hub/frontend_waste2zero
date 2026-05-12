import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/receipt_response.dart';
import '../utils/app_session.dart';

class ReceiptException implements Exception {
  final String message;
  const ReceiptException(this.message);
  @override
  String toString() => message;
}

class ReceiptService {
  ReceiptService._();
  static final ReceiptService instance = ReceiptService._();

  static const String _baseUrl = 'https://w2z.matwa.is-cool.dev';
  static const Duration _timeout = Duration(seconds: 120);

  /// POST /api/receipt/analyze — multipart/form-data, campo: "file"
  /// Reintenta una vez automáticamente si el servidor responde "overloaded".
  Future<ReceiptResponse> analyzeReceipt(File imageFile) async {
    ReceiptException? lastError;

    for (int attempt = 0; attempt < 2; attempt++) {
      // Pausa de 4 segundos antes del segundo intento
      if (attempt > 0) {
        await Future.delayed(const Duration(seconds: 4));
      }

      try {
        return await _sendRequest(imageFile);
      } on ReceiptException catch (e) {
        lastError = e;
        // Reintenta en sobrecarga (503/529) y errores internos transitorios (500)
        final lower = e.message.toLowerCase();
        final isRetryable = lower.contains('overload') ||
            lower.contains('sobrecarg') ||
            lower.contains('500') ||
            lower.contains('503') ||
            lower.contains('529');
        if (!isRetryable) rethrow;
      }
    }

    throw lastError!;
  }

  /// Envío real al API — no modificar el formato de la petición.
  Future<ReceiptResponse> _sendRequest(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/api/receipt/analyze');
    final request = http.MultipartRequest('POST', uri);

    final token = AppSession.instance.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // ── Enviar ──────────────────────────────────────────────────────────────
    late http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(_timeout);
    } on TimeoutException {
      throw const ReceiptException(
        'El servidor tardó demasiado en responder. Intenta de nuevo.',
      );
    } on SocketException catch (e) {
      throw ReceiptException(
        'Sin conexión a internet. Verifica tu red. (${e.message})',
      );
    } on HandshakeException {
      throw const ReceiptException(
        'Error de seguridad SSL al conectar con el servidor.',
      );
    } catch (e) {
      throw ReceiptException(
        'No se pudo conectar al servidor: ${e.runtimeType}',
      );
    }

    // ── Leer y parsear respuesta ─────────────────────────────────────────────
    final responseBody = await streamed.stream.bytesToString();

    late Map<String, dynamic> body;
    try {
      body = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      throw ReceiptException(
        'Respuesta inesperada del servidor (HTTP ${streamed.statusCode}).',
      );
    }

    if (streamed.statusCode == 200) {
      return ReceiptResponse.fromJson(body);
    }

    final msg = body['detail']?.toString() ??
        body['message']?.toString() ??
        body['error']?.toString() ??
        'Error ${streamed.statusCode} al analizar la factura.';
    throw ReceiptException(msg);
  }
}
