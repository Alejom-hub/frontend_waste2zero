import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_storage_service.dart';

/// Gestiona todas las sesiones de chat en memoria y las persiste por usuario.
class ChatStore {
  ChatStore._();
  static final ChatStore instance = ChatStore._();

  final List<ChatSession> _sessions = [];
  String? _userId;
  String? _activeSessionId;

  // ── Cargar sesiones desde disco al iniciar sesión ─────────────────────────
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _sessions.clear();
    _activeSessionId = null;
    final saved = await ChatStorageService.instance.loadSessions(userId);
    _sessions.addAll(saved);
  }

  // ── Crear nueva sesión y activarla ────────────────────────────────────────
  ChatSession createSession() {
    final session = ChatSession(
      id: ChatSession.generateId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    _sessions.insert(0, session);
    _activeSessionId = session.id;
    _persist();
    return session;
  }

  // ── Activar una sesión existente ──────────────────────────────────────────
  void setActiveSession(String sessionId) {
    _activeSessionId = sessionId;
  }

  // ── Agregar mensaje a la sesión activa ────────────────────────────────────
  void addMessage(ChatMessage message) {
    if (_activeSessionId == null) return;
    final idx = _sessions.indexWhere((s) => s.id == _activeSessionId);
    if (idx < 0) return;

    final updated = _sessions[idx].copyWith(
      updatedAt: DateTime.now(),
      messages: [..._sessions[idx].messages, message],
    );

    _sessions[idx] = updated;

    // Mover al tope de la lista (más reciente primero)
    if (idx != 0) {
      _sessions.removeAt(idx);
      _sessions.insert(0, updated);
    }
    _persist();
  }

  // ── Eliminar una sesión ───────────────────────────────────────────────────
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_activeSessionId == sessionId) _activeSessionId = null;
    _persist();
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  ChatSession? get activeSession {
    if (_activeSessionId == null) return null;
    try {
      return _sessions.firstWhere((s) => s.id == _activeSessionId);
    } catch (_) {
      return null;
    }
  }

  bool get isEmpty => _sessions.isEmpty;

  // ── Limpiar memoria al cerrar sesión (disco se conserva) ──────────────────
  void clear() {
    _sessions.clear();
    _activeSessionId = null;
    _userId = null;
  }

  // ── Persistir en background ───────────────────────────────────────────────
  void _persist() {
    if (_userId != null && _userId!.isNotEmpty) {
      ChatStorageService.instance.saveSessions(_userId!, _sessions);
    }
  }
}
