import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/shopping_list_service.dart';
import 'create_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _service = RecipeService();
  final ShoppingListService _shoppingService = ShoppingListService();
  final _storage = const FlutterSecureStorage();

  bool _isFavorite = false;
  bool _favoriteLoading = false;
  bool _addingToShopping = false;
  int _servings = 1;
  String _currentUsername = '';

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servingsBase;
    _loadCurrentUser();
    _loadFavoriteStatus();
  }

  Future<void> _loadCurrentUser() async {
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    setState(() {
      _currentUsername = username ?? (email?.split('@').first ?? '');
    });
  }

  // Carga el estado real de favorito consultando la lista de favoritos del
  // usuario. Si la receta ya está, marcamos el corazón en amarillo desde
  // el principio. Así evitamos intentar ADD cuando ya existe (que daba
  // "Error al actualizar favorito").
  Future<void> _loadFavoriteStatus() async {
    try {
      final favs = await _service.getFavorites();
      if (!mounted) return;
      setState(() {
        _isFavorite = favs.any((r) => r.id == widget.recipe.id);
      });
    } catch (_) {
      // Si falla, dejamos _isFavorite en false; el usuario lo verá igual.
    }
  }

  bool get _isAuthor => _currentUsername == widget.recipe.authorUsername;

  Future<void> _toggleFavorite() async {
    if (_favoriteLoading) return;
    setState(() => _favoriteLoading = true);

    // Optimismo: cambiamos el icono ya y revertimos si falla la llamada.
    final previous = _isFavorite;
    setState(() => _isFavorite = !previous);

    try {
      if (previous) {
        await _service.removeFavorite(widget.recipe.id);
      } else {
        await _service.addFavorite(widget.recipe.id);
      }
    } catch (_) {
      if (mounted) {
        // Revertimos al estado anterior si la API falla.
        setState(() => _isFavorite = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar favorito')),
        );
      }
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Future<void> _editRecipe() async {
    final result = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRecipeScreen(
          initialRecipe: widget.recipe,
          showBackButton: true,
        ),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2D4E),
        title: const Text('Eliminar receta',
            style: TextStyle(color: Colors.white)),
        content: const Text('¿Seguro que quieres eliminar esta receta?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteRecipe(widget.recipe.id);
        if (mounted) Navigator.pop(context, true);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar la receta')),
          );
        }
      }
    }
  }

  Future<void> _addToShoppingList() async {
    if (_addingToShopping) return;
    setState(() => _addingToShopping = true);
    try {
      final added = await _shoppingService.addFromRecipe(widget.recipe.id);
      if (!mounted) return;
      final msg = added.isEmpty
          ? 'Ya tienes todos los ingredientes en tu despensa'
          : '${added.length} ingrediente${added.length == 1 ? '' : 's'} añadido${added.length == 1 ? '' : 's'} a la lista';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo añadir a la lista')),
      );
    } finally {
      if (mounted) setState(() => _addingToShopping = false);
    }
  }

  double _scaledQuantity(double? qty) {
    if (qty == null) return 0;
    return (qty / widget.recipe.servingsBase) * _servings;
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0C2D4E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_isAuthor)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: _editRecipe,
                ),
              if (_isAuthor)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _deleteRecipe,
                ),
              _favoriteLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: _isFavorite
                            ? const Color(0xFFF5C518)
                            : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.recipe.imageUrl != null &&
                      widget.recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoHeader(),
                const Divider(color: Color(0xFFDDD8CF), thickness: 1),
                _buildServingsAdjuster(),
                const Divider(color: Color(0xFFDDD8CF), thickness: 1),
                _buildIngredients(),
                if (widget.recipe.instructions != null &&
                    widget.recipe.instructions!.isNotEmpty) ...[
                  const Divider(color: Color(0xFFDDD8CF), thickness: 1),
                  _buildInstructions(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addingToShopping ? null : _addToShoppingList,
            icon: _addingToShopping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.shopping_cart_outlined),
            label: Text(_addingToShopping
                ? 'Añadiendo...'
                : 'Añadir a lista de la compra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C2D4E),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF0C2D4E).withOpacity(0.6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF0C2D4E),
      child: const Center(
        child: Icon(Icons.restaurant, size: 64, color: Colors.white24),
      ),
    );
  }

  Widget _buildInfoHeader() {
    final description = widget.recipe.description?.trim() ?? '';
    final categoryLabel = RecipeCategories.label(widget.recipe.category);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.recipe.title,
            style: const TextStyle(
              color: Color(0xFF0C2D4E),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Línea con autor, raciones y categoría como chip.
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _iconText(Icons.person_outline, widget.recipe.authorUsername),
              _iconText(Icons.people_outline,
                  '${widget.recipe.servingsBase} porciones base'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C518),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryLabel,
                  style: const TextStyle(
                    color: Color(0xFF0C2D4E),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Descripción del autor (si existe), debajo del usuario y porciones
          // como pidió el usuario.
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0C2D4E)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: Color(0xFF0C2D4E), fontSize: 14)),
      ],
    );
  }

  Widget _buildServingsAdjuster() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Comensales',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              _servingsButton(
                icon: Icons.remove,
                onPressed: _servings > 1
                    ? () => setState(() => _servings--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_servings',
                  style: const TextStyle(
                      color: Color(0xFF0C2D4E),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _servingsButton(
                icon: Icons.add,
                onPressed: () => setState(() => _servings++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _servingsButton({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C2D4E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildIngredients() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredientes',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.recipe.recipeIngredients.map((ing) {
            final qty = _scaledQuantity(ing.quantity);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ing.ingredientName,
                    style: const TextStyle(
                        color: Color(0xFF0C2D4E), fontSize: 15),
                  ),
                  Text(
                    ing.quantity != null
                        ? '${_formatQuantity(qty)} ${ing.unit ?? ''}'
                        : ing.unit ?? '',
                    style: const TextStyle(
                        color: Color(0xFF0C2D4E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    // Partimos los pasos por saltos de línea. Si el usuario ya numeró
    // ("1. Pica..."), lo respetamos. Si no, los presentamos como bullets.
    final raw = widget.recipe.instructions ?? '';
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preparación',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (lines.isEmpty)
            const Text(
              'Sin pasos especificados',
              style: TextStyle(color: Color(0xFF7E8A99), fontSize: 14),
            )
          else
            ..._buildStepList(lines),
        ],
      ),
    );
  }

  /// Renderiza cada línea de instrucciones como un paso numerado.
  /// Si la línea ya empieza por "1.", "2. " etc, no añadimos el número
  /// (respetamos lo que escribió el usuario).
  List<Widget> _buildStepList(List<String> lines) {
    final widgets = <Widget>[];
    final hasOwnNumbers = lines.any((l) => RegExp(r'^\d+[\.\)]').hasMatch(l));

    for (int i = 0; i < lines.length; i++) {
      final stepText = hasOwnNumbers
          ? lines[i].replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')
          : lines[i];

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Número en círculo amarillo
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 1),
              decoration: const BoxDecoration(
                color: Color(0xFFF5C518),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                stepText,
                style: const TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return widgets;
  }
}
