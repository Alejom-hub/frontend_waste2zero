import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Stack(
          children: [
            // ── LOGO: Control de POSICIÓN (x, y) y TAMAÑO (width, height) ──
            Align(
              // alignment: Alignment(x, y)
              // x: -1.0 (izquierda) a 1.0 (derecha)
              // y: -1.0 (arriba) a 1.0 (abajo)
              // 0.0, 0.0 es el centro perfecto.
              alignment: const Alignment(0.0, -0.15), 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  'assets/images/logow2z.png',
                  width: 340,  // <--- Ajusta el ANCHO aquí
                  height: 340, // <--- Ajusta el ALTO aquí
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.shopping_basket_rounded,
                      color: Colors.white,
                      size: 160,
                    );
                  },
                ),
              ),
            ),

            // ── Zona de Botones alineada al fondo ──
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Registrarse
                    _WelcomeButton(
                      text: 'Registrarse',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    // Botón Iniciar Sesión
                    _WelcomeButton(
                      text: 'Iniciar Sesión',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      showBorder: true,
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

// Widget auxiliar para mantener los botones uniformes
class _WelcomeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool showBorder;

  const _WelcomeButton({
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: showBorder ? const BorderSide(color: Colors.white, width: 1.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
