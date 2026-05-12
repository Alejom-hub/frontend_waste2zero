import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/product_store.dart';

/// Persiste el historial de facturas por usuario en disco (shared_preferences).
/// Clave: "receipts_v1_<userId>"  →  valor: JSON de la lista de escaneos.
class ReceiptStorageService {
  ReceiptStorageService._();
  static final ReceiptStorageService instance = ReceiptStorageService._();

  static const String _prefix = 'receipts_v1_';

  /// Carga los escaneos guardados para [userId]. Devuelve [] si no hay datos.
  Future<List<ScannedReceipt>> loadReceipts(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$userId');
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => ScannedReceipt.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Si el JSON está corrupto o hay algún error, devolver lista vacía
      return [];
    }
  }

  /// Guarda la lista completa de escaneos de [userId] en disco.
  Future<void> saveReceipts(
      String userId, List<ScannedReceipt> receipts) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = receipts.map((r) => r.toJson()).toList();
      await prefs.setString('$_prefix$userId', jsonEncode(jsonList));
    } catch (_) {
      // Silencioso: no interrumpir el flujo principal si falla el guardado
    }
  }

  /// Borra el historial guardado de [userId] (al cerrar sesión).
  Future<void> clearReceipts(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefix$userId');
    } catch (_) {}
  }
}
