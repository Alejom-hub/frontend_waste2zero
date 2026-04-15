import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_session.dart';
import '../screens/welcome_screen.dart';

class UserAvatarMenu extends StatelessWidget {
  const UserAvatarMenu({super.key});

  Future<void> _showMenu(BuildContext context) async {
    // Obtiene la posición exacta del avatar en pantalla
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final user = AppSession.instance.user;

    await showMenu(
      context: context,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx - 180,          // izquierda: desplaza el menú hacia la izquierda
        offset.dy + size.height + 8, // debajo del avatar
        offset.dx + size.width,
        0,
      ),
      items: <PopupMenuEntry<String>>[
        // ── Encabezado con info del usuario ──
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Mini avatar
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF9C75BC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Usuario',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Divisor ──
        const PopupMenuDivider(height: 1),

        // ── Cerrar sesión ──
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'logout' && context.mounted) {
        _logout(context);
      }
    });
  }

  void _logout(BuildContext context) {
    // Limpiar sesión
    AppSession.instance.clear();

    // Volver a la pantalla de bienvenida, eliminar todo el historial
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF9C75BC),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
