import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/product_store.dart';
import '../models/receipt_response.dart';
import '../widgets/user_avatar_menu.dart';

class ScannedProductsScreen extends StatefulWidget {
  const ScannedProductsScreen({super.key});

  @override
  State<ScannedProductsScreen> createState() => _ScannedProductsScreenState();
}

class _ScannedProductsScreenState extends State<ScannedProductsScreen> {
  bool _selectionMode = false;
  final Set<int> _selectedIndices = {};

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedIndices.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll(int total) {
    setState(() {
      if (_selectedIndices.length == total) {
        _selectedIndices.clear();
      } else {
        _selectedIndices
          ..clear()
          ..addAll(List.generate(total, (i) => i));
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIndices.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Eliminar facturas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          count == 1
              ? '¿Eliminar esta factura y todos sus productos?'
              : '¿Eliminar $count facturas y todos sus productos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ProductStore.instance.removeReceipts(_selectedIndices.toList());
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipts = ProductStore.instance.receipts;
    final allSelected = _selectedIndices.length == receipts.length && receipts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _selectionMode
                      ? _GreenIconButton(
                          icon: Icons.close_rounded,
                          onTap: _exitSelectionMode,
                        )
                      : _GreenIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () {},
                        ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _selectionMode
                            ? '${_selectedIndices.length} seleccionada${_selectedIndices.length == 1 ? '' : 's'}'
                            : 'Mis Productos',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  if (_selectionMode)
                    // Botón Seleccionar todo / ninguno
                    GestureDetector(
                      onTap: () => _selectAll(receipts.length),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: allSelected
                              ? AppColors.primaryGreen
                              : AppColors.greyCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          allSelected ? 'Ninguna' : 'Todas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: allSelected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    )
                  else
                    // Botón para entrar en modo selección (solo si hay facturas)
                    receipts.isEmpty
                        ? const UserAvatarMenu()
                        : Row(
                            children: [
                              GestureDetector(
                                onTap: _enterSelectionMode,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.greyCard,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.checklist_rounded,
                                    color: AppColors.textDark,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const UserAvatarMenu(),
                            ],
                          ),
                ],
              ),
            ),

            // ── Subtítulo ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                receipts.isEmpty
                    ? 'Aún no has escaneado ninguna factura'
                    : '${ProductStore.instance.totalProducts} producto${ProductStore.instance.totalProducts == 1 ? '' : 's'} · ${receipts.length} escaneo${receipts.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),

            // ── Contenido ──
            Expanded(
              child: receipts.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          16, 8, 16, _selectionMode ? 100 : 24),
                      itemCount: receipts.length,
                      itemBuilder: (context, index) {
                        final receipt = receipts[index];
                        final isSelected = _selectedIndices.contains(index);
                        return _ReceiptSection(
                          receipt: receipt,
                          receiptNumber: receipts.length - index,
                          selectionMode: _selectionMode,
                          isSelected: isSelected,
                          onToggleSelect: () => _toggleSelection(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── Barra inferior de eliminación ─────────────────────────────────────
      bottomNavigationBar: _selectionMode
          ? _DeleteBar(
              selectedCount: _selectedIndices.length,
              onDelete: _selectedIndices.isEmpty ? null : _deleteSelected,
              onCancel: _exitSelectionMode,
            )
          : null,
    );
  }
}

// ── Sección de una factura ────────────────────────────────────────────────
class _ReceiptSection extends StatefulWidget {
  final ScannedReceipt receipt;
  final int receiptNumber;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _ReceiptSection({
    required this.receipt,
    required this.receiptNumber,
    required this.selectionMode,
    required this.isSelected,
    required this.onToggleSelect,
  });

  @override
  State<_ReceiptSection> createState() => _ReceiptSectionState();
}

class _ReceiptSectionState extends State<_ReceiptSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final products = widget.receipt.response.products;
    final dateStr = _formatDate(widget.receipt.scannedAt);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(20),
        border: widget.isSelected
            ? Border.all(color: AppColors.red, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppColors.red.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Encabezado verde ──
          GestureDetector(
            onTap: widget.selectionMode
                ? widget.onToggleSelect
                : () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFFB71C1C)
                    : AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: (_expanded && !widget.selectionMode)
                      ? Radius.zero
                      : const Radius.circular(18),
                  bottomRight: (_expanded && !widget.selectionMode)
                      ? Radius.zero
                      : const Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Ícono o checkbox según modo
                  if (widget.selectionMode)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isSelected
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        color: widget.isSelected
                            ? const Color(0xFFB71C1C)
                            : Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 20),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factura #${widget.receiptNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${products.length} ítems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!widget.selectionMode) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Lista de productos (oculta en modo selección) ──
          if (_expanded && !widget.selectionMode)
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              itemCount: products.length,
              separatorBuilder: (_, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _ProductTile(
                index: i + 1,
                product: products[i],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  •  $h:$m';
  }
}

// ── Tile tappable de producto ─────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final int index;
  final ProductItem product;

  const _ProductTile({required this.index, required this.product});

  // Solo se filtran campos verdaderamente internos/técnicos del servidor.
  // Toda la información del producto (storage, nutrition, etc.) se muestra.
  static const _debugKeys = {
    'debug', 'raw', 'raw_text', 'ocr_text', 'internal',
    'bounding_box', 'bbox', 'confidence', 'confidence_score',
    'tokens_used', 'processing_time', 'model_version',
    'raw_response', 'llm_response', 'prompt',
    'session_id', 'request_id',
  };

  @override
  Widget build(BuildContext context) {
    final hasPrice = product.price.isNotEmpty;
    final hasQty = product.quantity.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Número
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Nombre / tipo de producto
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),

              // Tags de cantidad y precio
              if (hasQty)
                _SmallTag(
                  text: product.quantity,
                  bg: AppColors.lightGreen,
                  fg: AppColors.darkGreen,
                ),
              if (hasQty && hasPrice) const SizedBox(width: 6),
              if (hasPrice)
                _SmallTag(
                  text: product.price,
                  bg: AppColors.primaryGreen.withValues(alpha: 0.13),
                  fg: AppColors.darkGreen,
                ),
              const SizedBox(width: 4),

              // Indicador de que es tappable
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProductDetailSheet(
        product: product,
        debugKeys: _debugKeys,
      ),
    );
  }
}

// ── Panel de detalle del producto ─────────────────────────────────────────
class _ProductDetailSheet extends StatelessWidget {
  final ProductItem product;
  final Set<String> debugKeys;

  const _ProductDetailSheet({
    required this.product,
    required this.debugKeys,
  });

  // ── Traducciones de nombres de campo al español ──────────────────────────
  static const _fieldNames = {
    'name': 'Nombre',
    'product_name': 'Nombre del producto',
    'original_name': 'Nombre original',
    'normalized_name': 'Nombre normalizado',
    'spanish_name': 'Nombre en español',
    'english_name': 'Nombre en inglés',
    'quantity': 'Cantidad',
    'qty': 'Cantidad',
    'unit': 'Unidad de medida',
    'units': 'Unidades',
    'price': 'Precio',
    'unit_price': 'Precio por unidad',
    'total': 'Total',
    'total_price': 'Precio total',
    'amount': 'Monto',
    'cost': 'Costo',
    'valor': 'Valor',
    'status': 'Estado del producto',
    'category': 'Categoría',
    'type': 'Tipo',
    'product_type': 'Tipo de producto',
    'brand': 'Marca',
    'description': 'Descripción',
    'weight': 'Peso',
    'volume': 'Volumen',
    'expiry_date': 'Fecha de vencimiento',
    'expiration_date': 'Fecha de vencimiento',
    'best_before': 'Consumir antes de',
    'expire_date': 'Fecha de vencimiento',
    'manufacture_date': 'Fecha de fabricación',
    'barcode': 'Código de barras',
    'sku': 'Código SKU',
    'origin': 'País de origen',
    'country': 'País de origen',
    'allergens': 'Alérgenos',
    'ingredients': 'Ingredientes',
    'item': 'Ítem',
    'article': 'Artículo',
    'title': 'Título',
    'count': 'Conteo',
  };

  static String _translateField(String key) {
    final lower = key.toLowerCase();
    return _fieldNames[lower] ?? _humanize(key);
  }

  static String _humanize(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
      .join(' ');

  static bool _isStorageKey(String key) {
    final k = key.toLowerCase();
    return k.contains('storage') || k.contains('conservation') ||
        k.contains('conservacion') || k.contains('almacen');
  }

  static bool _isNutritionKey(String key) {
    final k = key.toLowerCase();
    return k.contains('nutrition') || k.contains('nutriment') ||
        k.contains('nutrient') || k.contains('nutricion') ||
        k.contains('calorias') || k.contains('macros');
  }

  @override
  Widget build(BuildContext context) {
    final all = product.allFields
        .where((e) =>
            !debugKeys.contains(e.key.toLowerCase()) &&
            !e.key.startsWith('_'))
        .toList();

    final basicFields     = <MapEntry<String, dynamic>>[];
    final storageFields   = <MapEntry<String, dynamic>>[];
    final nutritionFields = <MapEntry<String, dynamic>>[];
    final otherFields     = <MapEntry<String, dynamic>>[];

    for (final e in all) {
      if (_isStorageKey(e.key)) {
        storageFields.add(e);
      } else if (_isNutritionKey(e.key)) {
        nutritionFields.add(e);
      } else if (e.value is! Map && e.value is! List) {
        basicFields.add(e);
      } else {
        otherFields.add(e);
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fastfood_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [

                  // ── 1. Información básica ────────────────────────────────
                  if (basicFields.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.info_outline_rounded,
                      label: 'INFORMACIÓN BÁSICA',
                      color: AppColors.primaryGreen,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.15)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      child: Column(
                        children: basicFields.map((e) => Column(
                          children: [
                            _DetailRow(
                              label: _translateField(e.key),
                              value: e.value,
                            ),
                            if (e != basicFields.last)
                              const Divider(height: 1, thickness: 0.4),
                          ],
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── 2. Conservación con tarjetas visuales ─────────────────
                  if (storageFields.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.kitchen_rounded,
                      label: 'CÓMO CONSERVARLO',
                      color: const Color(0xFF1565C0),
                    ),
                    ...storageFields.map((e) {
                      final val = e.value;
                      if (val is List && val.isNotEmpty) {
                        return _StorageOptionsList(options: val);
                      }
                      if (val is Map && val.isNotEmpty) {
                        return _StorageOptionsList(options: [val]);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DetailRow(
                          label: _translateField(e.key),
                          value: val,
                          accentColor: const Color(0xFF1565C0),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],

                  // ── 3. Nutrición con tarjetas de valores ──────────────────
                  if (nutritionFields.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.monitor_heart_rounded,
                      label: 'INFORMACIÓN NUTRICIONAL',
                      color: const Color(0xFFE65100),
                    ),
                    ...nutritionFields.map((e) {
                      final val = e.value;
                      if (val is Map && val.isNotEmpty) {
                        return _NutritionMapCard(data: val);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DetailRow(
                          label: _translateField(e.key),
                          value: val,
                          accentColor: const Color(0xFFE65100),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],

                  // ── 4. Otros datos del API ────────────────────────────────
                  if (otherFields.isNotEmpty) ...[
                    _SectionHeader(
                      icon: Icons.data_object_rounded,
                      label: 'DATOS ADICIONALES',
                      color: AppColors.textGrey,
                    ),
                    ...otherFields.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DetailRow(
                        label: _translateField(e.key),
                        value: e.value,
                      ),
                    )),
                  ],

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Encabezado de sección ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lista de opciones de almacenamiento ──────────────────────────────────
class _StorageOptionsList extends StatelessWidget {
  final List options;
  const _StorageOptionsList({required this.options});

  // Nombre en español de cada método de conservación
  static String _methodName(String method) {
    return {
      'refrigerator'   : 'Refrigerador',
      'fridge'         : 'Refrigerador',
      'refrigeration'  : 'Refrigeración',
      'freezer'        : 'Congelador',
      'freezing'       : 'Congelación',
      'frozen'         : 'Congelado',
      'room_temperature': 'Temperatura Ambiente',
      'ambient'        : 'Temperatura Ambiente',
      'cool_dry'       : 'Lugar Fresco y Seco',
      'dry'            : 'Lugar Seco',
      'pantry'         : 'Despensa',
      'cellar'         : 'Bodega',
      'dark'           : 'Lugar Oscuro y Seco',
      'cool'           : 'Lugar Fresco',
      'vacuum'         : 'Al Vacío',
    }[method.toLowerCase()] ??
        method
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty
                ? '${w[0].toUpperCase()}${w.substring(1)}'
                : w)
            .join(' ');
  }

  static IconData _methodIcon(String method) {
    return {
      'refrigerator'    : Icons.kitchen_rounded,
      'fridge'          : Icons.kitchen_rounded,
      'refrigeration'   : Icons.kitchen_rounded,
      'freezer'         : Icons.ac_unit_rounded,
      'freezing'        : Icons.ac_unit_rounded,
      'frozen'          : Icons.ac_unit_rounded,
      'room_temperature': Icons.wb_sunny_outlined,
      'ambient'         : Icons.wb_sunny_outlined,
      'cool_dry'        : Icons.home_rounded,
      'dry'             : Icons.air_rounded,
      'pantry'          : Icons.inventory_2_rounded,
      'cellar'          : Icons.wine_bar_rounded,
      'dark'            : Icons.nights_stay_rounded,
      'cool'            : Icons.thermostat_rounded,
      'vacuum'          : Icons.compress_rounded,
    }[method.toLowerCase()] ??
        Icons.storage_rounded;
  }

  static Color _methodColor(String method) {
    return {
      'refrigerator'    : const Color(0xFF1565C0),
      'fridge'          : const Color(0xFF1565C0),
      'refrigeration'   : const Color(0xFF1565C0),
      'freezer'         : const Color(0xFF0288D1),
      'freezing'        : const Color(0xFF0288D1),
      'frozen'          : const Color(0xFF0288D1),
      'room_temperature': const Color(0xFFE65100),
      'ambient'         : const Color(0xFFE65100),
      'cool_dry'        : const Color(0xFF37474F),
      'dry'             : const Color(0xFF546E7A),
      'pantry'          : const Color(0xFF5D4037),
      'cellar'          : const Color(0xFF4A148C),
      'dark'            : const Color(0xFF4A148C),
      'cool'            : const Color(0xFF00695C),
      'vacuum'          : const Color(0xFF424242),
    }[method.toLowerCase()] ??
        AppColors.textGrey;
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar solo entradas que sean Map
    final maps = options.whereType<Map>().toList();
    if (maps.isEmpty) return const SizedBox.shrink();

    // La primera opción es la recomendación principal
    final primary = maps.first;
    // El resto son alternativas secundarias
    final secondary = maps.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tarjeta principal ────────────────────────────────────────────────
        _buildCard(primary),

        // ── Alternativas en texto compacto ───────────────────────────────────
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'También puede conservarse en: ${secondary.map((m) => _methodName(m['method']?.toString() ?? '')).join(' · ')}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard(Map opt) {
    final rawMethod = opt['method']?.toString() ?? '';
    final name      = _methodName(rawMethod);
    final icon      = _methodIcon(rawMethod);
    final color     = _methodColor(rawMethod);
    final dMin      = opt['duration_min'];
    final dMax      = opt['duration_max'];
    final hasDur    = dMin != null && dMax != null;

    final extras = opt.entries
        .where((e) =>
            e.key != 'method' &&
            e.key != 'duration_min' &&
            e.key != 'duration_max' &&
            e.value != null)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1565C0).withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                if (hasDur) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 13, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        'Dura entre $dMin y $dMax días',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                for (final ex in extras) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${_translateStorageField(ex.key.toString())}: ${ex.value}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _translateStorageField(String key) {
    return {
      'temperature'   : 'Temperatura',
      'humidity'      : 'Humedad',
      'container'     : 'Recipiente recomendado',
      'tips'          : 'Consejos',
      'notes'         : 'Notas',
      'condition'     : 'Condición',
    }[key.toLowerCase()] ??
        key.replaceAll('_', ' ');
  }
}

// ── Tarjeta de información nutricional ──────────────────────────────────
class _NutritionMapCard extends StatelessWidget {
  final Map data;
  const _NutritionMapCard({required this.data});

  // Configuración de cada nutriente conocido
  static const _nutrients = {
    'calories'       : ('Calorías',       Icons.local_fire_department_rounded, Color(0xFFEF6C00)),
    'energy'         : ('Calorías',       Icons.local_fire_department_rounded, Color(0xFFEF6C00)),
    'energy_kcal'    : ('Calorías',       Icons.local_fire_department_rounded, Color(0xFFEF6C00)),
    'proteins'       : ('Proteínas',      Icons.fitness_center_rounded,        Color(0xFF1565C0)),
    'protein'        : ('Proteínas',      Icons.fitness_center_rounded,        Color(0xFF1565C0)),
    'carbohydrates'  : ('Carbohidratos',  Icons.grain_rounded,                 Color(0xFFF9A825)),
    'carbs'          : ('Carbohidratos',  Icons.grain_rounded,                 Color(0xFFF9A825)),
    'fat'            : ('Grasas totales', Icons.opacity_rounded,               Color(0xFFE53935)),
    'fats'           : ('Grasas totales', Icons.opacity_rounded,               Color(0xFFE53935)),
    'saturated_fat'  : ('Grasas saturadas', Icons.water_drop_rounded,          Color(0xFFB71C1C)),
    'fiber'          : ('Fibra',          Icons.grass_rounded,                 Color(0xFF2E7D32)),
    'sugars'         : ('Azúcares',       Icons.cake_rounded,                  Color(0xFFAD1457)),
    'sugar'          : ('Azúcares',       Icons.cake_rounded,                  Color(0xFFAD1457)),
    'sodium'         : ('Sodio',          Icons.science_rounded,               Color(0xFF00838F)),
    'salt'           : ('Sal',            Icons.science_rounded,               Color(0xFF00838F)),
    'cholesterol'    : ('Colesterol',     Icons.favorite_rounded,              Color(0xFFC62828)),
    'potassium'      : ('Potasio',        Icons.bolt_rounded,                  Color(0xFF6A1B9A)),
    'calcium'        : ('Calcio',         Icons.healing_rounded,               Color(0xFF0277BD)),
    'iron'           : ('Hierro',         Icons.hardware_rounded,              Color(0xFF4E342E)),
    'vitamin_c'      : ('Vitamina C',     Icons.eco_rounded,                   Color(0xFFF57F17)),
    'vitamin_a'      : ('Vitamina A',     Icons.visibility_rounded,            Color(0xFFFF8F00)),
  };

  @override
  Widget build(BuildContext context) {
    final known   = <_NutrientEntry>[];
    final unknown = <MapEntry>[];

    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase();
      if (_nutrients.containsKey(key)) {
        final cfg = _nutrients[key]!;
        known.add(_NutrientEntry(
          label: cfg.$1,
          icon:  cfg.$2,
          color: cfg.$3,
          raw:   entry.value,
        ));
      } else {
        unknown.add(MapEntry(entry.key, entry.value));
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE65100).withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: const [
                Icon(Icons.monitor_heart_rounded,
                    size: 16, color: Color(0xFFE65100)),
                SizedBox(width: 6),
                Text(
                  'Valores por porción',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
          ),
          // Grid de nutrientes conocidos
          if (known.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: known.map((e) => _NutrientChip(entry: e)).toList(),
              ),
            ),
          // Campos no reconocidos como lista simple
          if (unknown.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: unknown.map((e) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• ${_humanize(e.key.toString())}: ${e.value}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textDark),
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  static String _humanize(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
      .join(' ');
}

class _NutrientEntry {
  final String label;
  final IconData icon;
  final Color color;
  final dynamic raw;
  const _NutrientEntry(
      {required this.label,
      required this.icon,
      required this.color,
      required this.raw});
}

class _NutrientChip extends StatelessWidget {
  final _NutrientEntry entry;
  const _NutrientChip({required this.entry});

  String get _value {
    final v = entry.raw;
    if (v is num) {
      return v == v.toInt() ? '${v.toInt()}' : v.toStringAsFixed(1);
    }
    return v?.toString() ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: entry.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: entry.color.withValues(alpha: 0.08),
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entry.icon, size: 15, color: entry.color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: entry.color,
                ),
              ),
              Text(
                entry.label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Fila de detalle clave / valor ─────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color? accentColor;

  const _DetailRow({required this.label, required this.value, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
          _buildValue(value),
        ],
      ),
    );
  }

  Widget _buildValue(dynamic val) {
    // ── Lista ──────────────────────────────────────────────────────────────
    if (val is List) {
      if (val.isEmpty) return _empty();

      // Lista de mapas → cada mapa como tarjeta
      if (val.any((item) => item is Map)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: val.asMap().entries.map<Widget>((e) {
            final item = e.value;
            return Padding(
              padding: EdgeInsets.only(top: e.key == 0 ? 0 : 8),
              child: item is Map
                  ? _buildMapCard(item)
                  : _buildBullet(_stringify(item)),
            );
          }).toList(),
        );
      }

      // Lista de primitivos → viñetas
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: val
            .map<Widget>((item) => _buildBullet(_stringify(item)))
            .toList(),
      );
    }

    // ── Mapa ───────────────────────────────────────────────────────────────
    if (val is Map) {
      if (val.isEmpty) return _empty();
      return _buildMapCard(val);
    }

    // ── Primitivo (String, número, bool) ───────────────────────────────────
    return Text(
      _stringify(val),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
        height: 1.4,
      ),
    );
  }

  /// Tarjeta para un Map, con lógica especial para duration_min/duration_max
  Widget _buildMapCard(Map map) {
    final hasDurationRange =
        map.containsKey('duration_min') && map.containsKey('duration_max');

    final rows = <Widget>[];
    bool durationAdded = false;

    for (final entry in map.entries) {
      final key = entry.key.toString();

      if (key == 'duration_min' || key == 'duration_max') {
        if (hasDurationRange && !durationAdded) {
          rows.add(_mapRow(
            'Duración',
            '${map['duration_min']} – ${map['duration_max']} días',
          ));
          durationAdded = true;
        }
        continue;
      }

      rows.add(_mapRow(_humanKey(key), _stringify(entry.value)));
    }

    final borderColor = (accentColor ?? AppColors.primaryGreen).withValues(alpha: 0.25);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _mapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textDark, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() => const Text(
        '—',
        style: TextStyle(fontSize: 13, color: AppColors.textGrey),
      );

  static String _stringify(dynamic v) => v?.toString().trim() ?? '—';

  static String _humanKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}

// ── Tag pequeño ───────────────────────────────────────────────────────────
class _SmallTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _SmallTag({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_rounded,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin productos aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Escanea tu primera factura de mercado\npara ver tus productos aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barra inferior de eliminación ─────────────────────────────────────────
class _DeleteBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback? onDelete;
  final VoidCallback onCancel;

  const _DeleteBar({
    required this.selectedCount,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete = onDelete != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Info de selección
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedCount == 0
                      ? 'Toca una factura para seleccionarla'
                      : '$selectedCount factura${selectedCount == 1 ? '' : 's'} seleccionada${selectedCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: canDelete ? AppColors.textDark : AppColors.textGrey,
                  ),
                ),
                if (canDelete)
                  const Text(
                    'Se eliminarán todos sus productos',
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Botón cancelar
          GestureDetector(
            onTap: onCancel,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón eliminar
          GestureDetector(
            onTap: onDelete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: canDelete ? AppColors.red : AppColors.red.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_rounded,
                    color: Colors.white.withValues(alpha: canDelete ? 1.0 : 0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                          .withValues(alpha: canDelete ? 1.0 : 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón verde circular ──────────────────────────────────────────────────
class _GreenIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GreenIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
