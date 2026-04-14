import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
                  _UserAvatar(),
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

                    // ── Dos columnas: Orgánicos e Industriales ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _FoodTipCard(
                            title: 'Organicos',
                            tipText:
                                'Para conservar las fresas frescas por más tiempo...',
                            // TODO: reemplaza con Image.asset('assets/images/fresas.jpg')
                            imagePlaceholderColor: const Color(0xFFFFCDD2),
                            imagePlaceholderIcon: Icons.local_florist_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FoodTipCard(
                            title: 'Industriales',
                            tipText:
                                'Para conservar el arroz crudo, guárdalo en...',
                            // TODO: reemplaza con Image.asset('assets/images/arroz.jpg')
                            imagePlaceholderColor: const Color(0xFFFFF9C4),
                            imagePlaceholderIcon: Icons.inventory_2_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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
                                        text: '¡Lily! ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textGreen,
                                        ),
                                      ),
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

// ── Tarjeta de tip de alimento ──
class _FoodTipCard extends StatelessWidget {
  final String title;
  final String tipText;
  final Color imagePlaceholderColor;
  final IconData imagePlaceholderIcon;

  const _FoodTipCard({
    required this.title,
    required this.tipText,
    required this.imagePlaceholderColor,
    required this.imagePlaceholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título columna
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Imagen (placeholder por ahora)
        Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            color: imagePlaceholderColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            imagePlaceholderIcon,
            size: 48,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          // TODO: reemplaza con imagen real:
          // child: ClipRRect(
          //   borderRadius: BorderRadius.circular(16),
          //   child: Image.asset('assets/images/xxx.jpg', fit: BoxFit.cover),
          // ),
        ),

        const SizedBox(height: 10),

        // Texto del tip
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            children: [
              const TextSpan(
                text: 'Tips: ',
                style: TextStyle(
                  color: AppColors.textGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: tipText),
            ],
          ),
        ),
      ],
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
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
    );
  }
}
