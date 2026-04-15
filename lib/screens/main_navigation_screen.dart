import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'scanned_products_screen.dart';
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

  // Índice 0: Mis Productos (ScannedProductsScreen)
  // Índice 1: Escáner QR (placeholder)
  // Índice 2: Escáner de factura (HomeScreen)
  // Índice 3: Notificaciones (NotificationsScreen)
  // Índice 4: Tips y donaciones (TipsScreen)
  //
  // NOTA: la lista se construye en build() y NO como late final para que
  // ScannedProductsScreen y NotificationsScreen (StatelessWidgets) se
  // reconstruyan y lean el ProductStore actualizado cada vez que se cambia
  // de pestaña. HomeScreen es StatefulWidget: Flutter preserva su estado
  // aunque la lista se recree en cada build.

  @override
  Widget build(BuildContext context) {
    // ScannedProductsScreen y NotificationsScreen NO llevan const:
    // sin const Flutter crea una nueva instancia en cada build() y fuerza
    // el rebuild del StatelessWidget, lo que hace que lean el ProductStore
    // actualizado cada vez que el usuario cambia de pestaña.
    final screens = [
      ScannedProductsScreen(),
      _PlaceholderScreen(label: 'Escáner QR', icon: Icons.crop_free_rounded),
      const HomeScreen(),
      NotificationsScreen(),
      const TipsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
