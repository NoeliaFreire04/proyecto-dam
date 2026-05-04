import 'package:flutter/material.dart';
import 'feed_screen.dart';

/// Pantalla principal con navegación inferior entre secciones.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pestaña seleccionada actualmente
  int _currentIndex = 0;

  // Pantallas de cada pestaña
  final List<Widget> _screens = [
    const FeedScreen(),
    const _PlaceholderScreen(title: 'Favoritos', icon: Icons.favorite),
    const _PlaceholderScreen(title: 'Crear receta', icon: Icons.add_circle_outline),
    const _PlaceholderScreen(title: 'Lista de la compra', icon: Icons.shopping_cart),
    const _PlaceholderScreen(title: 'Perfil', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0C2D4E),
        selectedItemColor: const Color(0xFFE8C55A),
        unselectedItemColor: const Color(0xFF7A8FA3),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 32),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Pantalla temporal para las secciones que aún no están implementadas.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071E33),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Color(0xFFF5F0E8)),
        ),
        backgroundColor: const Color(0xFF0C2D4E),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF7A8FA3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF7A8FA3),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximamente',
              style: TextStyle(
                color: Color(0xFF7A8FA3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}