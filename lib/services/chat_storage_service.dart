import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';

/// Persiste las sesiones de chat por usuario en disco (shared_preferences).
/// Clave: "chat_sessions_v1_<userId>"  →  JSON de la lista de sesiones.
class ChatStorageService {
  ChatStorageService._();
  static final ChatStorageService instance = ChatStorageService._();

  static const String _prefix = 'chat_sessions_v1_';

  /// Carga las sesiones guardadas para [userId]. Devuelve [] si no hay datos.
  Future<List<ChatSession>> loadSessions(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$userId');
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Guarda todas las sesiones de [userId] en disco.
  Future<void> saveSessions(String userId, List<ChatSession> sessions) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await prefs.setString('$_prefix$userId', jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Borra todas las sesiones guardadas de [userId].
  Future<void> clearSessions(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$userId');
    } catch (_) {}
  }
}
