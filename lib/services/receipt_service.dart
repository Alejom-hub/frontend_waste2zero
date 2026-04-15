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

  /// POST /api/receipt/analyze  — multipart/form-data, campo: "file"
  Future<ReceiptResponse> analyzeReceipt(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/api/receipt/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Token de autenticación (si existe)
    final token = AppSession.instance.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Adjuntar el archivo tal cual, sin forzar content-type
    // (igual que hace curl con -F "file=@imagen.jpg")
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

    // ── Leer respuesta ───────────────────────────────────────────────────────
    final responseBody = await streamed.stream.bytesToString();

    Map<String, dynamic> body;
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

    // Cualquier error HTTP (401, 422, 500, …)
    final msg = body['detail']?.toString() ??
        body['message']?.toString() ??
        body['error']?.toString() ??
        'Error ${streamed.statusCode} al analizar la factura.';
    throw ReceiptException(msg);
  }
}
