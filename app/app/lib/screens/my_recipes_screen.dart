import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe/recipe_card.dart';
import 'recipe_detail_screen.dart';

/// Pantalla con el listado completo de recetas creadas por el usuario.
/// Se accede desde el perfil al pulsar la estadística "Recetas".
class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  final RecipeService _service = RecipeService();
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final recipes = await _service.getMyRecipes();
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar tus recetas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis recetas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C2D4E)))
          : _recipes.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: const Color(0xFFF5C518),
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _recipes.length,
                    itemBuilder: (_, i) {
                      final recipe = _recipes[i];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                          // Al volver del detalle (puede haberse borrado),
                          // recargamos la lista.
                          _load();
                        },
                        trailing: Icon(
                          recipe.isPublic
                              ? Icons.public
                              : Icons.lock_outline,
                          color: const Color(0xFF0C2D4E),
                          size: 18,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.restaurant_outlined,
              size: 64, color: Color(0xFF0C2D4E)),
          SizedBox(height: 16),
          Text(
            'Aún no has creado ninguna receta',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ve a la pestaña "Crear" para añadir\ntu primera receta',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
