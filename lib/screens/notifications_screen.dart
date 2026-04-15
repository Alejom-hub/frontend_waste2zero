import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/product_store.dart';
import '../models/receipt_response.dart';
import '../widgets/user_avatar_menu.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final withExpiry = ProductStore.instance.productsWithExpiry;
    final allProducts = ProductStore.instance.allProducts;
    final hasScans = !ProductStore.instance.isEmpty;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GreenIconButton(icon: Icons.menu_rounded, onTap: () {}),
                  const UserAvatarMenu(),
                ],
              ),
            ),

            // ── Título ──
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                'Recordatorios',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                hasScans
                    ? (withExpiry.isEmpty
                        ? 'Tus productos escaneados'
                        : 'Vencimientos más próximos primero')
                    : 'Escanea facturas para ver recordatorios',
                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ),

            // ── Contenido ──
            Expanded(
              child: !hasScans
                  ? const _EmptyState()
                  : withExpiry.isNotEmpty
                      ? _ExpiryList(items: withExpiry)
                      : _AllProductsList(products: allProducts),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lista de productos con fecha de vencimiento ───────────────────────────
class _ExpiryList extends StatelessWidget {
  final List<({ProductItem product, DateTime expiresAt, DateTime scannedAt})>
      items;

  const _ExpiryList({required this.items});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final daysLeft = item.expiresAt.difference(now).inDays;
        final isExpired = daysLeft < 0;
        final isUrgent = !isExpired && daysLeft <= 3;

        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (isExpired) {
          statusColor = AppColors.red;
          statusText = 'Vencido hace ${(-daysLeft)} día${daysLeft == -1 ? '' : 's'}';
          statusIcon = Icons.warning_amber_rounded;
        } else if (isUrgent) {
          statusColor = Colors.orange.shade600;
          statusText = daysLeft == 0
              ? 'Vence hoy'
              : 'Vence en $daysLeft día${daysLeft == 1 ? '' : 's'}';
          statusIcon = Icons.access_time_rounded;
        } else {
          statusColor = AppColors.primaryGreen;
          statusText = 'Vence en $daysLeft días';
          statusIcon = Icons.check_circle_outline_rounded;
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greyCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono de estado
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence: ${_formatDate(item.expiresAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${dt.day} de ${months[dt.month - 1]} de ${dt.year}';
  }
}

// ── Lista de todos los productos cuando no hay fechas de vencimiento ───────
class _AllProductsList extends StatelessWidget {
  final List<ProductItem> products;

  const _AllProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner informativo
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La factura no incluye fechas de vencimiento. '
                  'Revisa el empaque de cada producto.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGreen,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: products.length,
            separatorBuilder: (_, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.greyCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (product.price.isNotEmpty)
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Estado vacío (sin escaneos) ───────────────────────────────────────────
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
                Icons.notifications_none_rounded,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin recordatorios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cuando escanees una factura,\naquí verás los recordatorios de vencimiento.',
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

// ── Botón verde circular ───────────────────────────────────────────────────
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
