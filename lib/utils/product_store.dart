import '../models/receipt_response.dart';
import '../services/receipt_storage_service.dart';

/// Un escaneo completo con fecha y hora
class ScannedReceipt {
  final DateTime scannedAt;
  final ReceiptResponse response;

  ScannedReceipt({required this.scannedAt, required this.response});

  // ── Serialización para almacenamiento en disco ────────────────────────────
  Map<String, dynamic> toJson() => {
        'scannedAt': scannedAt.toIso8601String(),
        'response': {
          'success': response.success,
          'total_items': response.totalItems,
          'products': response.products.map((p) => p.raw).toList(),
          'message': response.message,
        },
      };

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) => ScannedReceipt(
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        response: ReceiptResponse.fromJson(
          Map<String, dynamic>.from(json['response'] as Map),
        ),
      );
}

/// Almacena todos los escaneos en memoria y los persiste en disco por usuario
class ProductStore {
  ProductStore._();
  static final ProductStore instance = ProductStore._();

  final List<ScannedReceipt> _receipts = [];
  String? _userId;

  // ── Cargar historial del usuario desde disco al iniciar sesión ────────────
  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _receipts.clear();
    final saved = await ReceiptStorageService.instance.loadReceipts(userId);
    _receipts.addAll(saved);
  }

  // ── Agregar un nuevo escaneo y persistir ──────────────────────────────────
  void addReceipt(ReceiptResponse response) {
    _receipts.insert(
      0,
      ScannedReceipt(scannedAt: DateTime.now(), response: response),
    );
    if (_userId != null && _userId!.isNotEmpty) {
      ReceiptStorageService.instance.saveReceipts(_userId!, _receipts);
    }
  }

  // ── Eliminar facturas por índice y persistir ───────────────────────────────
  void removeReceipts(List<int> indices) {
    // Ordenar de mayor a menor para no alterar índices al eliminar
    final sorted = indices.toList()..sort((a, b) => b.compareTo(a));
    for (final i in sorted) {
      if (i >= 0 && i < _receipts.length) _receipts.removeAt(i);
    }
    if (_userId != null && _userId!.isNotEmpty) {
      ReceiptStorageService.instance.saveReceipts(_userId!, _receipts);
    }
  }

  // ── Limpiar memoria al cerrar sesión (el disco se mantiene) ───────────────
  void clear() {
    _receipts.clear();
    _userId = null;
  }

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ScannedReceipt> get receipts => List.unmodifiable(_receipts);

  List<ProductItem> get allProducts =>
      _receipts.expand((r) => r.response.products).toList();

  List<({ProductItem product, DateTime expiresAt, DateTime scannedAt})>
      get productsWithExpiry {
    final result =
        <({ProductItem product, DateTime expiresAt, DateTime scannedAt})>[];

    for (final receipt in _receipts) {
      for (final product in receipt.response.products) {
        // 1. Intentar fecha explícita del API
        DateTime? date = _parseExpiryDate(product.raw);
        // 2. Si no hay fecha explícita, calcular desde duration_max
        date ??= _calculateExpiryFromStorage(product.raw, receipt.scannedAt);
        if (date != null) {
          result.add((
            product: product,
            expiresAt: date,
            scannedAt: receipt.scannedAt,
          ));
        }
      }
    }

    result.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    return result;
  }

  /// Calcula la fecha de vencimiento usando duration_max del primer
  /// storage_option y la fecha en que se registró la factura.
  static DateTime? _calculateExpiryFromStorage(
    Map<String, dynamic> raw,
    DateTime scannedAt,
  ) {
    final opts = raw['storage_options'];
    if (opts is! List || opts.isEmpty) return null;
    final first = opts.first;
    if (first is! Map) return null;
    final v = first['duration_max'];
    if (v == null) return null;
    final days = v is num ? v.toInt() : int.tryParse(v.toString());
    if (days == null || days <= 0) return null;
    return scannedAt.add(Duration(days: days));
  }

  /// Lista plana de (producto, scannedAt) para reprogramar notificaciones.
  List<({ProductItem product, DateTime scannedAt})> get allProductsWithScanDate {
    return [
      for (final r in _receipts)
        for (final p in r.response.products)
          (product: p, scannedAt: r.scannedAt),
    ];
  }

  bool get isEmpty => _receipts.isEmpty;
  int get totalProducts => allProducts.length;

  // ── Intentar parsear fecha de vencimiento de campos conocidos ──────────────
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
