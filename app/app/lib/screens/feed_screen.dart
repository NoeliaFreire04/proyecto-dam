import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'create_recipe_screen.dart';
class FeedScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const FeedScreen({super.key, this.onNavigateToProfile});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final RecipeService _service = RecipeService();
  final _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Recipe> _recipes = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 0;
  bool _hasMore = true;

  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  final List<String> _categories = ['Todas', 'Italiana', 'Vegana', 'Fría'];

  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadFeed();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    setState(() {
      _username = username ?? (email?.split('@').first ?? 'Usuario');
    });
  }

  Future<void> _loadFeed({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 0;
        _hasMore = true;
        _recipes = [];
        _loading = true;
      });
    }
    try {
      final recipes = await _service.getFeed(page: _page, size: 10);
      setState(() {
        _recipes.addAll(recipes);
        _loading = false;
        _loadingMore = false;
        if (recipes.length < 10) _hasMore = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      setState(() {
        _loadingMore = true;
        _page++;
      });
      _loadFeed();
    }
  }

  List<Recipe> get _filteredRecipes {
    Iterable<Recipe> result = _recipes;
    if (_selectedCategory != 'Todas') {
      final cat = _selectedCategory.toLowerCase();
      result = result.where((r) =>
          (r.title + (r.description ?? '')).toLowerCase().contains(cat));
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) =>
          r.title.toLowerCase().contains(q) ||
          (r.description ?? '').toLowerCase().contains(q) ||
          r.recipeIngredients
              .any((i) => i.ingredientName.toLowerCase().contains(q)));
    }
    return result.toList();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        elevation: 0,
        title: const Text(
          'CookShare',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: widget.onNavigateToProfile,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF5C518),
                child: Text(
                  _initials(_username),
                  style: const TextStyle(
                      color: Color(0xFF0C2D4E),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF5C518),
        onRefresh: () => _loadFeed(reset: true),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C2D4E)))
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final filtered = _filteredRecipes;
                        if (index < filtered.length) {
                          return RecipeCard(
                            recipe: filtered[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailScreen(
                                    recipe: filtered[index]),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: _filteredRecipes.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (_loadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: Color(0xFF0C2D4E)),
                          ),
                        const SizedBox(height: 8),
                        _buildVideoCard(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF0C2D4E),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                '¿Qué cocinamos hoy?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2240),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.trim()),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar recetas',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white38),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white38),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFF5C518)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFF5C518)
                          : const Color(0xFF0C2D4E),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0C2D4E)
                          : const Color(0xFF0C2D4E),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Tendencias',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5C518),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crea una receta desde vídeo',
            style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sube un vídeo y Gemini extrae los ingredientes, pasos y tiempo de preparación',
            style: TextStyle(color: Color(0xFF0C2D4E), fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateRecipeScreen(
                      startInVideoMode: true,
                      showBackButton: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C2D4E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Seleccionar vídeo'),
            ),
          ),
        ],
      ),
    );
  }
}
