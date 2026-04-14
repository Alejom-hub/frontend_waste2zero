import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Menú hamburguesa
                  _GreenIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () {
                      // TODO: abrir drawer/menú lateral
                    },
                  ),

                  // Ubicación centrada
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Bogota, COL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar de usuario
                  _UserAvatar(),
                ],
              ),
            ),

            // ── Saludo y título ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '¡Bienvenida Lily!',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Escanea tu factura\nde mercado',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tarjeta de factura ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.greyCard,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícono de factura ilustrado
                      _ReceiptIllustration(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Botón verde circular con ícono ──
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

// ── Avatar de usuario ──
class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF9C75BC),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 26,
        ),
        // TODO: cuando tengas foto de perfil del usuario:
        // child: Image.network(userPhotoUrl, fit: BoxFit.cover),
      ),
    );
  }
}

// ── Ilustración de factura (placeholder visual) ──
class _ReceiptIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "BILL"
          Text(
            'BILL',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          // Líneas de texto simuladas
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Símbolo $
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Código de barras simulado
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: List.generate(
                18,
                (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: i % 3 == 0
                          ? Colors.grey.shade500
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Firma simulada
          Align(
            alignment: Alignment.center,
            child: Text(
              'ＯＳ',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontFamily: 'cursive',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
