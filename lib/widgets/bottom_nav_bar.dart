import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.crop_free_rounded,
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              // Center elevated cart button
              GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: currentIndex == 2
                        ? AppColors.primaryGreen
                        : AppColors.darkGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.notifications_rounded,
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.volunteer_activism_rounded,
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? AppColors.darkGreen : AppColors.darkGreen.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
