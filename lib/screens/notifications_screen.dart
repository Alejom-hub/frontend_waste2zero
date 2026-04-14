import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
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
                ],
              ),
            ),

            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 72,
                      color: AppColors.lightGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textGrey,
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
