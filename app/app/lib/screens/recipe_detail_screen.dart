import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/shopping_list_service.dart';

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
  }

  Future<void> _loadCurrentUser() async {
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    setState(() {
      _currentUsername = username ?? (email?.split('@').first ?? '');
    });
  }

  bool get _isAuthor => _currentUsername == widget.recipe.authorUsername;

  Future<void> _toggleFavorite() async {
    setState(() => _favoriteLoading = true);
    try {
      if (_isFavorite) {
        await _service.removeFavorite(widget.recipe.id);
      } else {
        await _service.addFavorite(widget.recipe.id);
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar favorito')),
        );
      }
    } finally {
      setState(() => _favoriteLoading = false);
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
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: Color(0xFF0C2D4E)),
              const SizedBox(width: 4),
              Text(
                widget.recipe.authorUsername,
                style: const TextStyle(
                    color: Color(0xFF0C2D4E), fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline,
                  size: 16, color: Color(0xFF0C2D4E)),
              const SizedBox(width: 4),
              Text(
                '${widget.recipe.servingsBase} porciones base',
                style: const TextStyle(
                    color: Color(0xFF0C2D4E), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
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
          Text(
            widget.recipe.instructions!,
            style: const TextStyle(
                color: Color(0xFF0C2D4E), fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}
