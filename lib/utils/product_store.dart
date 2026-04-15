import '../models/receipt_response.dart';

/// Un escaneo completo con fecha y hora
class ScannedReceipt {
  final DateTime scannedAt;
  final ReceiptResponse response;

  ScannedReceipt({required this.scannedAt, required this.response});
}

/// Almacena todos los escaneos en memoria durante la sesión
class ProductStore {
  ProductStore._();
  static final ProductStore instance = ProductStore._();

  final List<ScannedReceipt> _receipts = [];

  // ── Agregar un nuevo escaneo ──
  void addReceipt(ReceiptResponse response) {
    _receipts.insert(
      0,
      ScannedReceipt(scannedAt: DateTime.now(), response: response),
    );
  }

  // ── Todos los escaneos (más reciente primero) ──
  List<ScannedReceipt> get receipts => List.unmodifiable(_receipts);

  // ── Todos los productos de todos los escaneos ──
  List<ProductItem> get allProducts =>
      _receipts.expand((r) => r.response.products).toList();

  // ── Productos que tienen fecha de vencimiento en sus datos ──
  List<({ProductItem product, DateTime expiresAt, DateTime scannedAt})>
      get productsWithExpiry {
    final result =
        <({ProductItem product, DateTime expiresAt, DateTime scannedAt})>[];

    for (final receipt in _receipts) {
      for (final product in receipt.response.products) {
        final date = _parseExpiryDate(product.raw);
        if (date != null) {
          result.add((
            product: product,
            expiresAt: date,
            scannedAt: receipt.scannedAt,
          ));
        }
      }
    }

    // Ordenar: los que vencen primero primero
    result.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    return result;
  }

  bool get isEmpty => _receipts.isEmpty;
  int get totalProducts => allProducts.length;

  void clear() => _receipts.clear();

  // ── Intentar parsear fecha de vencimiento de campos conocidos ──
  static DateTime? _parseExpiryDate(Map<String, dynamic> raw) {
    const dateKeys = [
      'expiry_date', 'expiration_date', 'best_before', 'expires',
      'expire_date', 'vencimiento', 'fecha_vencimiento',
      'fecha_expiracion', 'caducidad',
    ];
    for (final key in dateKeys) {
      final val = raw[key];
      if (val == null) continue;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {}
    }
    return null;
  }
}
