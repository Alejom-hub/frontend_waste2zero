import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chatbot_service.dart';
import '../utils/chat_store.dart';
import '../utils/product_store.dart';

// ════════════════════════════════════════════════════════════════════════════
// Pantalla principal: lista de sesiones
// ════════════════════════════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _sessions = List.from(ChatStore.instance.sessions));
  }

  Future<void> _openSession(ChatSession session) async {
    ChatStore.instance.setActiveSession(session.id);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ChatConversationScreen(sessionId: session.id),
      ),
    );
    _refresh(); // Al volver, refrescar la lista
  }

  Future<void> _createSession() async {
    final session = ChatStore.instance.createSession();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ChatConversationScreen(sessionId: session.id),
      ),
    );
    _refresh();
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar conversación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Eliminar esta conversación con Greenie?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ChatStore.instance.deleteSession(sessionId);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/Greenie.png',
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Greenie',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text('Asistente de conservación',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Botón nueva conversación
                  GestureDetector(
                    onTap: _createSession,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Nuevo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Contenido ───────────────────────────────────────────────────
            Expanded(
              child: _sessions.isEmpty
                  ? _SessionsEmptyState(onCreate: _createSession)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _SessionCard(
                        session: _sessions[i],
                        onTap: () => _openSession(_sessions[i]),
                        onDelete: () => _deleteSession(_sessions[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tarjeta de sesión en la lista
// ════════════════════════════════════════════════════════════════════════════
class _SessionCard extends StatelessWidget {
  final ChatSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text('Eliminar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // El delete lo maneja onDelete, no Dismissible
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15)),
              color: AppColors.greyCard,
            ),
            child: Row(
              children: [
                // Avatar Greenie
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset('assets/images/Greenie.png',
                        fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 12),

                // Título y preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        session.lastMessagePreview,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Fecha y contador de mensajes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(session.updatedAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${session.messageCount} msg',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Estado vacío cuando no hay sesiones
// ════════════════════════════════════════════════════════════════════════════
class _SessionsEmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _SessionsEmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Greenie.png', width: 110, height: 110),
            const SizedBox(height: 20),
            const Text(
              '¡Hola! Soy Greenie 🌱',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aún no tienes conversaciones.\nInicia una nueva para preguntarme\nsobre conservación de alimentos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onCreate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Nueva conversación',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Pantalla de conversación individual
// ════════════════════════════════════════════════════════════════════════════
class _ChatConversationScreen extends StatefulWidget {
  final String sessionId;
  const _ChatConversationScreen({required this.sessionId});

  @override
  State<_ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<_ChatConversationScreen> {
  late List<ChatMessage> _messages;
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _isLoading = false;

  ChatSession? get _session => ChatStore.instance.activeSession;

  @override
  void initState() {
    super.initState();
    ChatStore.instance.setActiveSession(widget.sessionId);
    _messages = List.from(_session?.messages ?? []);
    if (_messages.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _input.clear();
    final userMsg = ChatMessage(text: trimmed, role: MessageRole.user);
    ChatStore.instance.addMessage(userMsg);
    setState(() {
      _messages = List.from(_session?.messages ?? []);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await ChatbotService.instance.sendMessage(_messages);
      if (!mounted) return;
      final botMsg =
          ChatMessage(text: reply, role: MessageRole.assistant);
      ChatStore.instance.addMessage(botMsg);
      setState(() => _messages = List.from(_session?.messages ?? []));
    } on ChatbotException catch (e) {
      if (!mounted) return;
      final errMsg = ChatMessage(
          text: '⚠️ ${e.message}', role: MessageRole.assistant);
      ChatStore.instance.addMessage(errMsg);
      setState(() => _messages = List.from(_session?.messages ?? []));
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasProducts = !ProductStore.instance.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _ConversationHeader(
              title: _session?.title ?? 'Greenie',
              hasMessages: _messages.isNotEmpty,
              onBack: () => Navigator.of(context).pop(),
            ),

            // ── Mensajes ─────────────────────────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? _ConversationEmptyState(
                      hasProducts: hasProducts,
                      onSuggestion: _send,
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      itemCount:
                          _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i == _messages.length) {
                          return const _TypingIndicator();
                        }
                        return _MessageBubble(message: _messages[i]);
                      },
                    ),
            ),

            // ── Input ────────────────────────────────────────────────────────
            _ChatInput(
              controller: _input,
              isLoading: _isLoading,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header de la conversación ─────────────────────────────────────────────
class _ConversationHeader extends StatelessWidget {
  final String title;
  final bool hasMessages;
  final VoidCallback onBack;

  const _ConversationHeader({
    required this.title,
    required this.hasMessages,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/Greenie.png',
                fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasMessages ? title : 'Greenie',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('Asistente de conservación',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 7, color: Color(0xFF69FF47)),
                SizedBox(width: 5),
                Text('En línea',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vacío de conversación (con sugerencias) ────────────────────────
class _ConversationEmptyState extends StatelessWidget {
  final bool hasProducts;
  final void Function(String) onSuggestion;

  static const _suggestions = [
    '¿Qué alimentos tengo que vencen pronto?',
    '¿Cómo conservo mejor la carne?',
    'Dame tips para reducir el desperdicio',
    '¿Cuánto dura el pollo en la nevera?',
  ];

  const _ConversationEmptyState(
      {required this.hasProducts, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Image.asset('assets/images/Greenie.png', width: 90, height: 90),
          const SizedBox(height: 16),
          const Text('¡Hola! Soy Greenie 🌱',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(
            hasProducts
                ? 'Conozco tus productos escaneados y puedo ayudarte a conservarlos mejor.'
                : 'Puedo ayudarte con consejos de conservación. Escanea una factura para consejos personalizados.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textGrey, height: 1.5),
          ),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Pregúntame sobre...',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(height: 12),
          ..._suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => onSuggestion(s),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.greyCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primaryGreen
                              .withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(s,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textDark))),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Burbuja de mensaje ────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset('assets/images/Greenie.png',
                    fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryGreen : AppColors.greyCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : AppColors.textDark,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Indicador "escribiendo..." ────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset('assets/images/Greenie.png',
                  fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: const _DotsAnimation(),
          ),
        ],
      ),
    );
  }
}

class _DotsAnimation extends StatefulWidget {
  const _DotsAnimation();

  @override
  State<_DotsAnimation> createState() => _DotsAnimationState();
}

class _DotsAnimationState extends State<_DotsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final opacity =
              ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
          final scale = 0.6 +
              0.4 *
                  (opacity < 0.5 ? opacity * 2 : (1 - opacity) * 2);
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen
                      .withValues(alpha: 0.4 + 0.6 * opacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Campo de entrada ──────────────────────────────────────────────────────
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final void Function(String) onSend;

  const _ChatInput({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color:
                        AppColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Pregúntame algo...',
                  hintStyle:
                      TextStyle(fontSize: 14, color: AppColors.textGrey),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
                onSubmitted: isLoading ? null : onSend,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? null : () => onSend(controller.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.primaryGreen.withValues(alpha: 0.5)
                    : AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryGreen
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Icon(
                isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
