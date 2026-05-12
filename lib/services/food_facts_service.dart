import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Información nutricional por cada 100g obtenida de Open Food Facts
class NutritionInfo {
  final String? matchedName;
  final String? grade; // Nutri-Score: A, B, C, D, E
  final double? calories;
  final double? proteins;
  final double? carbs;
  final double? sugars;
  final double? fat;
  final double? saturatedFat;
  final double? fiber;
  final double? salt;
  final double? sodium;

  const NutritionInfo({
    this.matchedName,
    this.grade,
    this.calories,
    this.proteins,
    this.carbs,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.fiber,
    this.salt,
    this.sodium,
  });

  bool get hasData =>
      calories != null || proteins != null || carbs != null || fat != null;

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    final n = json['nutriments'];
    final nm = n is Map ? n : <String, dynamic>{};

    double? read(String key) {
      final v = nm['${key}_100g'] ?? nm[key];
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return NutritionInfo(
      matchedName: json['product_name']?.toString(),
      grade: json['nutrition_grades']?.toString().toUpperCase(),
      calories: read('energy-kcal'),
      proteins: read('proteins'),
      carbs: read('carbohydrates'),
      sugars: read('sugars'),
      fat: read('fat'),
      saturatedFat: read('saturated-fat'),
      fiber: read('fiber'),
      salt: read('salt'),
      sodium: read('sodium'),
    );
  }
}

class FoodFactsService {
  FoodFactsService._();
  static final FoodFactsService instance = FoodFactsService._();

  static const _timeout = Duration(seconds: 15);
  final Map<String, NutritionInfo?> _cache = {};

  // ── Búsqueda principal: intenta múltiples candidatos hasta encontrar algo ──
  Future<NutritionInfo?> searchBestMatch(List<String> candidates) async {
    for (final name in candidates) {
      if (name.trim().isEmpty) continue;
      final result = await searchByName(name);
      if (result != null && result.hasData) return result;
    }
    return null;
  }

  /// Busca por nombre. Devuelve null si no hay resultados (silencioso).
  Future<NutritionInfo?> searchByName(String productName) async {
    final key = productName.trim().toLowerCase();
    if (key.isEmpty) return null;
    if (_cache.containsKey(key)) return _cache[key];

    final uri = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl',
    ).replace(queryParameters: {
      'search_terms': productName.trim(),
      'json': '1',
      'page_size': '3',
      'fields': 'product_name,nutriments,nutrition_grades',
    });

    try {
      final response = await http
          .get(uri, headers: {'User-Agent': 'Waste2Zero/1.0'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        _cache[key] = null;
        return null;
      }

      final body = jsonDecode(response.body);
      if (body is! Map) { _cache[key] = null; return null; }

      final products = body['products'];
      if (products is! List || products.isEmpty) {
        _cache[key] = null;
        return null;
      }

      // Tomar el primer resultado con datos nutricionales
      for (final p in products) {
        if (p is! Map<String, dynamic>) continue;
        final info = NutritionInfo.fromJson(p);
        if (info.hasData) {
          _cache[key] = info;
          return info;
        }
      }

      _cache[key] = null;
      return null;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  // ── Genera candidatos de búsqueda a partir de los datos crudos del producto ─
  static List<String> candidatesFrom(Map<String, dynamic> raw) {
    final seen = <String>{};
    final result = <String>[];

    void add(String? s) {
      if (s == null) return;
      final t = s.trim();
      if (t.isEmpty || seen.contains(t.toLowerCase())) return;
      seen.add(t.toLowerCase());
      result.add(t);
    }

    // 1. Nombre en inglés (mejor compatibilidad con OFF)
    add(raw['english_name']?.toString());
    add(raw['name_en']?.toString());

    // 2. Nombre normalizado (sin marca)
    add(raw['normalized_name']?.toString());

    // 3. Nombre en español
    add(raw['spanish_name']?.toString());
    add(raw['name_es']?.toString());

    // 4. Nombre original del escaneo
    for (final key in ['name', 'product_name', 'item_name', 'item', 'description']) {
      add(raw[key]?.toString());
    }

    // 5. Categoría como último recurso
    add(raw['category']?.toString());
    add(raw['product_type']?.toString());
    add(raw['type']?.toString());

    // 6. Variantes simplificadas: sin números/unidades y primera palabra
    final allNames = List<String>.from(result);
    for (final name in allNames) {
      // Quitar cantidades: "500g", "1L", "x6", "pack", etc.
      final clean = name
          .replaceAll(RegExp(r'\b\d+\s*(g|kg|ml|l|oz|lb|x\d+|pack)\b',
              caseSensitive: false), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
      add(clean);

      // Solo primer término (generalmente el tipo de producto)
      final firstWord = clean.split(RegExp(r'[\s,]+'))[0];
      if (firstWord.length > 2) add(firstWord);
    }

    return result;
  }
}
