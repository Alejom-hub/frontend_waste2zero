/// Configuración global de la app.
/// Reemplaza [groqApiKey] con tu clave de https://console.groq.com
class AppConfig {
  AppConfig._();

  /// API key de Groq — obtén la tuya gratis en https://console.groq.com
  /// ⚠️ NUNCA subas tu clave real a git.
  /// Coloca tu clave de Groq aquí solo localmente.
  static const String groqApiKey = 'TU_GROQ_API_KEY_AQUI';
}
