import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/chat_message.dart';
import '../utils/product_store.dart';

class ChatbotException implements Exception {
  final String message;
  const ChatbotException(this.message);
  @override
  String toString() => message;
}

class ChatbotService {
  ChatbotService._();
  static final ChatbotService instance = ChatbotService._();

  static const String _url =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';
  static const Duration _timeout = Duration(seconds: 30);

  // ── Construir el prompt del sistema con los productos del usuario ──────────
  String _buildSystemPrompt() {
    final products = ProductStore.instance.allProducts;
    final receipts = ProductStore.instance.receipts;
    final buf = StringBuffer();

    buf.writeln(
      'Eres Greenie 🌱, el asistente de conservación de alimentos de la app '
      'Waste2Zero. Tu misión es ayudar a los usuarios a reducir el desperdicio '
      'alimentario y conservar mejor sus productos.',
    );
    buf.writeln();
    buf.writeln('REGLAS:');
    buf.writeln('- Responde SIEMPRE en español colombiano, de forma amable y práctica.');
    buf.writeln('- Sé conciso: máximo 3 párrafos por respuesta.');
    buf.writeln('- Usa emojis ocasionalmente para hacer la conversación amigable.');
    buf.writeln('- Si el usuario pregunta por un producto que tiene escaneado, '
        'usa su información de almacenamiento real.');
    buf.writeln('- Da consejos concretos y accionables.');
    buf.writeln('- Cuando sea relevante, motiva al usuario a donar lo que no vaya a usar.');
    buf.writeln();

    if (products.isEmpty) {
      buf.writeln('El usuario aún no ha escaneado ninguna factura. '
          'Puedes darle consejos generales de conservación.');
    } else {
      buf.writeln(
        'El usuario tiene ${products.length} producto(s) en '
        '${receipts.length} escaneo(s). Sus productos son:',
      );
      buf.writeln();
      for (final p in products) {
        buf.write('• ${p.name}');
        if (p.quantity.isNotEmpty) buf.write(' (${p.quantity})');
        if (p.price.isNotEmpty)    buf.write(' — ${p.price}');
        buf.writeln();

        // Info de almacenamiento si la tiene
        final storage = p.raw['storage_options'] ??
            p.raw['storage'] ??
            p.raw['storage_info'];
        if (storage != null) {
          buf.writeln('  Almacenamiento: $storage');
        }

        // Fecha de vencimiento si la tiene
        final expiry = p.raw['expiry_date'] ??
            p.raw['expiration_date'] ??
            p.raw['best_before'];
        if (expiry != null) {
          buf.writeln('  Vence: $expiry');
        }
      }
    }

    return buf.toString();
  }

  // ── Enviar mensaje y obtener respuesta de Groq ────────────────────────────
  Future<String> sendMessage(List<ChatMessage> history) async {
    if (AppConfig.groqApiKey == 'TU_API_KEY_AQUI') {
      throw const ChatbotException(
        'Configura tu API key de Groq en lib/config/app_config.dart',
      );
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt()},
      ...history.map((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          }),
    ];

    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_url),
            headers: {
              'Authorization': 'Bearer ${AppConfig.groqApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_tokens': 600,
              'temperature': 0.75,
            }),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const ChatbotException(
          'La respuesta tardó demasiado. Intenta de nuevo.');
    } catch (_) {
      throw const ChatbotException(
          'No se pudo conectar. Verifica tu internet.');
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          body['choices']?[0]?['message']?['content']?.toString().trim();
      if (content != null && content.isNotEmpty) return content;
      throw const ChatbotException('Respuesta vacía del servidor.');
    }

    if (response.statusCode == 401) {
      throw const ChatbotException(
          'API key inválida. Revisa tu clave en app_config.dart.');
    }
    if (response.statusCode == 429) {
      throw const ChatbotException(
          'Demasiadas solicitudes. Espera un momento e intenta de nuevo.');
    }

    throw ChatbotException(
        'Error del servidor (${response.statusCode}). Intenta de nuevo.');
  }
}
