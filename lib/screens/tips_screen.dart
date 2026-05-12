import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/user_avatar_menu.dart';
import 'chat_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GreenIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () {
                      // TODO: abrir drawer/menú lateral
                    },
                  ),
                  const UserAvatarMenu(),
                ],
              ),
            ),

            // ── Contenido scrolleable ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título principal
                    const Text(
                      '¿CÓMO CONSERVAR\nTUS ALIMENTOS?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Tarjeta del chatbot ──────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ChatScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryGreen,
                              AppColors.darkGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/Greenie.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Habla con Greenie 🌱',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Consejos personalizados según tus productos escaneados',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Tarjeta donación de alimentos ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.greyCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título sección
                          const Center(
                            child: Text(
                              'DONACIÓN DE ALIMENTOS',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Corazón + mensaje
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.red,
                                size: 36,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'Si tienes un alimento próximo a vencer o que no quieras desperdiciar ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '¡DONALO!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Subtítulo comedores
                          const Text(
                            'Comedores comunitarios en Bogotá:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGreen,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Lista de comedores
                          _BulletItem(
                            text:
                                'Fundación Fiambre en Altos de Cazucá (alimentos no perecederos)',
                          ),
                          const SizedBox(height: 8),
                          _BulletItem(
                            text:
                                'Platos Solidario (bonos en restaurantes aliados)',
                          ),
                          const SizedBox(height: 8),
                          _BulletItem(
                            text:
                                'Red de Comedores Públicos (Secretaría de Integración Social)',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ítem de lista con viñeta ──
class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(
            Icons.circle,
            size: 7,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
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

