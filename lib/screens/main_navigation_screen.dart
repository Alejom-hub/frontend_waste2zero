import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'notifications_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Comenzamos en la pestaña central (índice 2 = escáner / carrito)
  int _currentIndex = 2;

  // Índice 0: Inicio general (placeholder)
  // Índice 1: Escáner QR (placeholder)
  // Índice 2: Escáner de factura (home_screen)
  // Índice 3: Notificaciones
  // Índice 4: Tips y donaciones
  late final List<Widget> _screens = [
    _PlaceholderScreen(label: 'Inicio', icon: Icons.home_rounded),
    _PlaceholderScreen(label: 'Escáner', icon: Icons.crop_free_rounded),
    const HomeScreen(),
    const NotificationsScreen(),
    const TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// Pantalla temporal para secciones aún no diseñadas
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderScreen({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCEEBB0)),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximamente',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
          ],
        ),
      ),
    );
  }
}
