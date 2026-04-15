class ProductItem {
  final Map<String, dynamic> raw;

  const ProductItem(this.raw);

  /// Nombre / tipo de producto.
  /// 1. Prueba campos de nombre conocidos en orden de prioridad.
  /// 2. Si ninguno coincide, devuelve el primer valor no vacío del JSON.
  /// Así siempre se muestra lo que la API realmente envió.
  String get name {
    const knownKeys = [
      'name', 'product_name', 'item_name', 'product',
      'item', 'description', 'title', 'type',
      'category', 'product_type', 'article',
    ];
    for (final key in knownKeys) {
      final s = raw[key]?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    // Último recurso: primer valor no vacío que devuelva la API
    for (final entry in raw.entries) {
      final s = entry.value?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return '—';
  }

  /// Precio
  String get price {
    final p = raw['price'] ??
        raw['unit_price'] ??
        raw['total'] ??
        raw['amount'] ??
        raw['cost'] ??
        raw['valor'] ??
        raw['precio'];
    if (p == null) return '';
    return '\$${p.toString()}';
  }

  /// Cantidad
  String get quantity {
    final q = raw['quantity'] ??
        raw['qty'] ??
        raw['count'] ??
        raw['units'] ??
        raw['cantidad'];
    if (q == null) return '';
    return 'x${q.toString()}';
  }

  /// Todos los pares clave-valor no nulos del JSON, para mostrar
  /// el detalle completo del producto
  List<MapEntry<String, String>> get allFields => raw.entries
      .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
      .map((e) => MapEntry(e.key, e.value.toString()))
      .toList();

  factory ProductItem.fromJson(Map<String, dynamic> json) =>
      ProductItem(json);
}

class ReceiptResponse {
  final bool success;
  final int totalItems;
  final List<ProductItem> products;
  final String? message;

  const ReceiptResponse({
    required this.success,
    required this.totalItems,
    required this.products,
    this.message,
  });

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    return ReceiptResponse(
      success: json['success'] as bool? ?? false,
      totalItems: json['total_items'] as int? ?? rawProducts.length,
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(ProductItem.fromJson)
          .toList(),
      message: json['message']?.toString(),
    );
  }
}
