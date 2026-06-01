import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'create_recipe_screen.dart';
import 'shopping_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _feedKey = GlobalKey<FeedScreenState>();
  final _shoppingKey = GlobalKey<ShoppingListScreenState>();
  final _favoritesKey = GlobalKey<FavoritesScreenState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    //se inicializa aquí para poder pasar el callback que cambia el tab activo
    _screens = [
      FeedScreen(key: _feedKey, onNavigateToProfile: () => setState(() => _currentIndex = 4)),
      FavoritesScreen(key: _favoritesKey),
      const CreateRecipeScreen(),
      ShoppingListScreen(key: _shoppingKey),
      const ProfileScreen(),
    ];
  }

  //al cambiar de tab, recargamos las pantallas dinámicas (Favoritos y Mi
  //compra) para que reflejen cambios hechos en otras tabs (p.ej. marcar
  //como favorito desde el feed o añadir desde una receta).
  void _onTabTap(int index) {
    if (index == 0 && _currentIndex != 0) {
      _feedKey.currentState?.reload();
    }
    if (index == 1 && _currentIndex != 1) {
      _favoritesKey.currentState?.reload();
    }
    if (index == 3 && _currentIndex != 3) {
      _shoppingKey.currentState?.reload();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        backgroundColor: const Color(0xFF0C2D4E),
        selectedItemColor: const Color(0xFFF5C518),
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Comprar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        title: Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Próximamente',
            style: TextStyle(color: Color(0xFF0C2D4E), fontSize: 18)),
      ),
    );
  }
}
