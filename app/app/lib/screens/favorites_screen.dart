import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe/recipe_card.dart';
import 'recipe_detail_screen.dart';

//pantalla con la lista de recetas marcadas como favoritas
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

// Estado público para que HomeScreen pueda forzar una recarga via GlobalKey
// cuando el usuario cambia a este tab.
class FavoritesScreenState extends State<FavoritesScreen> {
  final RecipeService _service = RecipeService();
  //lista de recetas favoritas del usuario
  List<Recipe> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Permite a HomeScreen forzar una recarga cuando se selecciona el tab.
  void reload() => _loadFavorites();

  //carga los favoritos desde la API
  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final favs = await _service.getFavorites();
      setState(() {
        _favorites = favs;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  //elimina una receta de la lista de favoritos y la quita visualmente de la pantalla
  Future<void> _removeFavorite(Recipe recipe) async {
    try {
      await _service.removeFavorite(recipe.id);
      setState(() => _favorites.removeWhere((r) => r.id == recipe.id));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar de favoritos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        title: const Text(
          'Favoritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C2D4E)))
          // El RefreshIndicator envuelve siempre, incluso si está vacía,
          // para que el pull-to-refresh funcione desde cualquier estado.
          : RefreshIndicator(
              color: const Color(0xFFF5C518),
              onRefresh: _loadFavorites,
              child: _favorites.isEmpty
                  ? ListView(
                      // Hay que dejar physics always-scrollable para que
                      // el pull-to-refresh funcione aunque no haya items.
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmpty(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _favorites.length,
                      itemBuilder: (_, i) {
                        final recipe = _favorites[i];
                        return RecipeCard(
                          recipe: recipe,
                          onTap: () async {
                            //al volver del detalle recarga los favoritos por si se quitó alguno
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                            _loadFavorites();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite,
                                color: Color(0xFFF5C518)),
                            onPressed: () => _removeFavorite(recipe),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  //mensaje que aparece cuando el usuario todavía no tiene favoritos guardados
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_outline,
              size: 64, color: Color(0xFF0C2D4E)),
          const SizedBox(height: 16),
          const Text(
            'Aún no tienes favoritos',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Guarda recetas que te gusten\ndesde el feed principal',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
