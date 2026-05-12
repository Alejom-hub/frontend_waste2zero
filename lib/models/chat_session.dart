import 'chat_message.dart';

class ChatSession {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // ── Título auto-generado desde el primer mensaje del usuario ──────────────
  String get title {
    try {
      final first = messages.firstWhere((m) => m.isUser);
      final t = first.text.trim();
      return t.length > 48 ? '${t.substring(0, 48)}…' : t;
    } catch (_) {
      return 'Nueva conversación';
    }
  }

  // ── Vista previa del último mensaje ───────────────────────────────────────
  String get lastMessagePreview {
    if (messages.isEmpty) return 'Sin mensajes';
    final last = messages.last;
    final prefix = last.isUser ? 'Tú: ' : 'Greenie: ';
    final t = last.text.trim().replaceAll('\n', ' ');
    final preview = t.length > 55 ? '${t.substring(0, 55)}…' : t;
    return '$prefix$preview';
  }

  bool get isEmpty => messages.isEmpty;
  int get messageCount => messages.length;

  // ── Serialización ─────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        messages: (json['messages'] as List<dynamic>)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  // ── Copia con campos actualizados ─────────────────────────────────────────
  ChatSession copyWith({DateTime? updatedAt, List<ChatMessage>? messages}) =>
      ChatSession(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        messages: messages ?? List.from(this.messages),
      );

  // ── Generar ID único ──────────────────────────────────────────────────────
  static String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_'
      '${DateTime.now().microsecond}';
}
