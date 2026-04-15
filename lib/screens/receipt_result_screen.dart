import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/receipt_response.dart';

class ReceiptResultScreen extends StatelessWidget {
  final ReceiptResponse result;

  const ReceiptResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header verde ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón volver
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resultado del\nescaneo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chips de resumen
                  Row(
                    children: [
                      _SummaryChip(
                        icon: Icons.check_circle_rounded,
                        label: result.success ? 'Exitoso' : 'Con errores',
                        color: result.success
                            ? Colors.white
                            : Colors.orange.shade200,
                      ),
                      const SizedBox(width: 10),
                      _SummaryChip(
                        icon: Icons.shopping_basket_rounded,
                        label: '${result.totalItems} productos',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Lista de productos ──
            Expanded(
              child: result.products.isEmpty
                  ? _EmptyProducts(message: result.message)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      itemCount: result.products.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = result.products[index];
                        return _ProductCard(
                          index: index + 1,
                          product: product,
                        );
                      },
                    ),
            ),

            // ── Botón escanear otra ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text(
                    'Escanear otra factura',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip de resumen en el header ─────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de producto ───────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final int index;
  final ProductItem product;

  const _ProductCard({required this.index, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasPrice = product.price.isNotEmpty;
    final hasQty = product.quantity.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Número
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                if (hasPrice || hasQty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (hasQty)
                        _Tag(text: product.quantity, color: AppColors.lightGreen),
                      if (hasQty && hasPrice) const SizedBox(width: 8),
                      if (hasPrice)
                        _Tag(
                          text: product.price,
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          textColor: AppColors.darkGreen,
                        ),
                    ],
                  ),
                ],
                // Campos adicionales que devuelva la API
                ..._buildExtraFields(product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExtraFields(ProductItem product) {
    // Campos ya mostrados
    const shown = {
      'name', 'product', 'description', 'item',
      'price', 'total', 'amount', 'cost',
      'quantity', 'qty', 'count', 'units',
    };

    final extras = product.raw.entries
        .where((e) => !shown.contains(e.key) && e.value != null)
        .toList();

    if (extras.isEmpty) return [];

    return [
      const SizedBox(height: 8),
      ...extras.map(
        (e) => Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${_formatKey(e.key)}: ${e.value}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ),
      ),
    ];
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : w)
        .join(' ');
  }
}

// ── Tag pequeño ───────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Tag({
    required this.text,
    required this.color,
    this.textColor = AppColors.darkGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Sin productos ─────────────────────────────────────────────────────────
class _EmptyProducts extends StatelessWidget {
  final String? message;
  const _EmptyProducts({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 72,
              color: AppColors.lightGreen,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se detectaron productos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
