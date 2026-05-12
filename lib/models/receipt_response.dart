class ProductItem {
  final Map<String, dynamic> raw;

  const ProductItem(this.raw);

  /// Nombre del producto — prueba los campos más comunes en orden
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
    // Último recurso: primer valor de texto del JSON
    for (final entry in raw.entries) {
      final s = entry.value?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return '—';
  }

  String get price {
    final p = raw['price'] ?? raw['unit_price'] ?? raw['total'] ??
        raw['amount'] ?? raw['cost'] ?? raw['valor'] ?? raw['precio'];
    if (p == null) return '';
    return '\$${p.toString()}';
  }

  String get quantity {
    final q = raw['quantity'] ?? raw['qty'] ?? raw['count'] ??
        raw['units'] ?? raw['cantidad'];
    if (q == null) return '';
    return 'x${q.toString()}';
  }

  List<MapEntry<String, dynamic>> get allFields => raw.entries
      .where((e) {
        if (e.value == null) return false;
        final s = e.value.toString().trim();
        return s.isNotEmpty && s != '[]' && s != '{}' && s != 'null';
      })
      .map((e) => MapEntry(e.key, e.value))
      .toList();

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(json);
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
    // Recoger productos de forma permisiva: acepta cualquier Map
    // sin importar su tipo genérico exacto en tiempo de ejecución
    final rawList = json['products'];
    final products = <ProductItem>[];

    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          products.add(ProductItem(item));
        } else if (item is Map) {
          // Convertir cualquier otro tipo de Map a Map<String, dynamic>
          products.add(ProductItem(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ));
        }
      }
    }

    return ReceiptResponse(
      success: json['success'] == true,
      totalItems: (json['total_items'] as num?)?.toInt() ?? products.length,
      products: products,
      message: json['message']?.toString(),
    );
  }
}
