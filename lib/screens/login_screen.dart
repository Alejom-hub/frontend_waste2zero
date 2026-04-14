import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: conectar con API de autenticación
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Zona blanca superior con logo ──
          Expanded(
            flex: 2, // Reducido para que la tarjeta verde suba
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Container(
                  width: 140, // Logo grande
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/greenlogo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shopping_basket_rounded,
                          color: AppColors.primaryGreen,
                          size: 80,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Tarjeta verde con formulario ──
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      const Center(
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Campo Email
                      _FormField(
                        label: 'Email',
                        hint: 'Ingresa tu correo',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu email';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Campo Contraseña
                      _FormField(
                        label: 'Contraseña',
                        hint: '••••••••••••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggleObscure: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      // ¿Olvidaste tu contraseña?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: pantalla de recuperar contraseña
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Botón Iniciar Sesión
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Registrarse con
                      const Center(
                        child: Text(
                          'Registrarse con',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Iconos sociales (sin fondo blanco)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            imagePath: 'assets/images/facebookIcon.webp',
                            imageScale: 1.1,
                            onTap: () {
                              // TODO: login con Facebook
                            },
                          ),
                          const SizedBox(width: 20),
                          _SocialButton(
                            imagePath: 'assets/images/googleIcon.webp',
                            onTap: () {
                              // TODO: login con Google
                            },
                          ),
                          const SizedBox(width: 20),
                          _SocialButton(
                            imagePath: 'assets/images/appleIcon.png',
                            onTap: () {
                              // TODO: login con Apple
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ¿No tienes cuenta?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿No tienes una cuenta? ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Registrarse',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de formulario con label dentro corregido ──
class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (onToggleObscure != null)
                GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textGrey,
                    size: 20,
                  ),
                )
              else
                const SizedBox(width: 20), // Espacio equivalente al icono para uniformidad
            ],
          ),
        ],
      ),
    );
  }
}

// ── Botón de red social (solo icono) ──
class _SocialButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final double imageScale;

  const _SocialButton({
    required this.imagePath,
    required this.onTap,
    this.imageScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    const double baseIconSize = 40.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        color: Colors.transparent,
        child: Center(
          child: Image.asset(
            imagePath,
            width: baseIconSize * imageScale,
            height: baseIconSize * imageScale,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
