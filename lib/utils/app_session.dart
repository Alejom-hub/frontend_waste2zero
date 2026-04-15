import '../models/user_model.dart';

/// Almacena la sesión del usuario en memoria durante la ejecución de la app.
/// Más adelante se puede migrar a shared_preferences para persistencia.
class AppSession {
  AppSession._();
  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  String? _token;
  UserModel? _user;

  // ── Getters ──
  String? get token => _token;
  UserModel? get user => _user;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // ── Guardar sesión al hacer login/register ──
  void save({required String token, required UserModel user}) {
    _token = token;
    _user = user;
  }

  // ── Limpiar sesión al cerrar sesión ──
  void clear() {
    _token = null;
    _user = null;
  }

  // ── Header de autorización listo para usar en peticiones ──
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
