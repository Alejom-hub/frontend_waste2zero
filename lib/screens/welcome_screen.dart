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
        child: Column(
          children: [
            // ── Logo area (flex to fill most of the screen) ──
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── PLACEHOLDER PARA EL LOGO ──
                      // Reemplaza este Container con tu Image.asset(...)
                      // Ejemplo:
                      //   Image.asset(
                      //     'assets/images/logo_waste2zero.png',
                      //     width: 280,
                      //   )
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // Descomenta la siguiente linea cuando tengas el logo:
                        // child: Image.asset('assets/images/logo_waste2zero.png'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Botones en la parte inferior ──
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
              child: Column(
                children: [
                  // Botón Registrarse
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.30),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enlace Iniciar Sesión
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
