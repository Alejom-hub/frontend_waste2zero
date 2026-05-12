enum MessageRole { user, assistant }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
  bool get isBot  => role == MessageRole.assistant;

  // ── Serialización ─────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'text': text,
        'role': role.name,           // 'user' | 'assistant'
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
