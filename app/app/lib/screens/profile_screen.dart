import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe/recipe_card.dart';
import 'auth_screen.dart';
import 'recipe_detail_screen.dart';
import 'my_recipes_screen.dart';
import 'favorites_screen.dart';
import 'inventory_screen.dart';
import 'edit_profile_screen.dart';

//pantalla de perfil del usuario con sus recetas y opciones de cuenta
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RecipeService _service = RecipeService();
  final _storage = const FlutterSecureStorage();

  //recetas creadas por el usuario
  List<Recipe> _myRecipes = [];
  //recetas que el usuario ha marcado como favoritas
  List<Recipe> _favorites = [];
  bool _loading = true;
  String _username = '';
  String _email = '';
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //carga el usuario del almacenamiento seguro y sus recetas+favoritos desde la API
  Future<void> _loadData() async {
    setState(() => _loading = true);
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    final picture = await _storage.read(key: 'profilePicture');
    setState(() {
      _email = email ?? '';
      _username = username ?? (email?.split('@').first ?? 'Usuario');
      _profilePicture = picture ?? '';
    });

    // Refrescamos el perfil desde el backend para que coja cambios
    // hechos desde otro dispositivo o si la storage local está stale.
    _refreshUserFromBackend();

    try {
      // Cargamos en paralelo recetas y favoritos para que sea rápido
      final results = await Future.wait([
        _service.getMyRecipes(),
        _service.getFavorites(),
      ]);
      if (!mounted) return;
      setState(() {
        _myRecipes = results[0];
        _favorites = results[1];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // Pide al backend los datos del usuario actual y los sincroniza con
  // storage para que el avatar/email/username se mantengan al día.
  Future<void> _refreshUserFromBackend() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) return;
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final newUsername = data['username']?.toString() ?? _username;
      final newEmail = data['email']?.toString() ?? _email;
      final newPicture = data['profilePicture']?.toString() ?? '';
      await _storage.write(key: 'username', value: newUsername);
      await _storage.write(key: 'email', value: newEmail);
      await _storage.write(key: 'profilePicture', value: newPicture);
      if (!mounted) return;
      setState(() {
        _username = newUsername;
        _email = newEmail;
        _profilePicture = newPicture;
      });
    } catch (_) {
      // Silencioso: si falla, usamos lo que ya tenemos en storage local.
    }
  }

  //borra todos los datos de sesión y manda al usuario a la pantalla de login
  Future<void> _logout() async {
    await _storage.deleteAll();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    }
  }

  //navega al listado completo de mis recetas y refresca al volver
  Future<void> _openMyRecipes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyRecipesScreen()),
    );
    _loadData();
  }

  //navega al listado de favoritos y refresca al volver
  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    _loadData();
  }

  //saca las iniciales del nombre para el avatar circular
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
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C2D4E)))
          : RefreshIndicator(
              color: const Color(0xFFF5C518),
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildProfileHeader(),
                  _buildStats(),
                  const SizedBox(height: 16),
                  _buildMyRecipesSection(),
                  const SizedBox(height: 8),
                  _buildOptions(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  //cabecera con avatar, nombre y email del usuario
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0C2D4E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 12),
          Text(
            _username,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          if (_email.isNotEmpty)
            Text(
              _email,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
        ],
      ),
    );
  }

  /// Avatar circular: imagen si hay URL, iniciales sobre amarillo si no.
  Widget _buildAvatar() {
    if (_profilePicture.isEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: const Color(0xFFF5C518),
        child: Text(
          _initials(_username),
          style: const TextStyle(
              color: Color(0xFF0C2D4E),
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        _profilePicture,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFFF5C518),
          child: Text(
            _initials(_username),
            style: const TextStyle(
                color: Color(0xFF0C2D4E),
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  //tarjeta con las estadísticas del usuario: recetas, favoritos y seguidores
  //las dos primeras son clicables y abren la pantalla correspondiente
  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2D4E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('${_myRecipes.length}', 'Recetas', onTap: _openMyRecipes),
          _divider(),
          _statItem('${_favorites.length}', 'Favoritos',
              onTap: _openFavorites),
          _divider(),
          _statItem('–', 'Seguidores'),
        ],
      ),
    );
  }

  //un dato estadístico con su valor y etiqueta. opcionalmente clicable
  Widget _statItem(String value, String label, {VoidCallback? onTap}) {
    final content = Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              color: Color(0xFFF5C518),
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: content,
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: Colors.white24);
  }

  //sección con las últimas recetas creadas por el usuario
  Widget _buildMyRecipesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIS RECETAS',
                style: TextStyle(
                    color: Color(0xFF0C2D4E),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
              if (_myRecipes.length > 5)
                GestureDetector(
                  onTap: _openMyRecipes,
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      color: Color(0xFFF5C518),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_myRecipes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Aún no has creado ninguna receta',
              style: TextStyle(color: Color(0xFF5A7A9A), fontSize: 14),
            ),
          )
        else
          //muestra como máximo las últimas 5 recetas
          ..._myRecipes.take(5).map((r) => RecipeCard(
                recipe: r,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r),
                    ),
                  );
                  _loadData();
                },
              )),
      ],
    );
  }

  //navega a la pantalla de inventario y refresca el perfil al volver
  Future<void> _openInventory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InventoryScreen()),
    );
  }

  //navega a la pantalla de edición de perfil y refresca los datos al volver
  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentUsername: _username,
          currentEmail: _email,
          currentProfilePicture:
              _profilePicture.isEmpty ? null : _profilePicture,
        ),
      ),
    );
    if (updated == true) _loadData();
  }

  //menú de opciones de cuenta: inventario, editar perfil, notificaciones y cerrar sesión
  Widget _buildOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2D4E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _optionTile(
            icon: Icons.kitchen_outlined,
            label: 'Mi despensa',
            onTap: _openInventory,
          ),
          const Divider(color: Colors.white12, height: 1),
          _optionTile(
            icon: Icons.edit_outlined,
            label: 'Editar perfil',
            onTap: _openEditProfile,
          ),
          const Divider(color: Colors.white12, height: 1),
          _optionTile(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            onTap: () {},
          ),
          const Divider(color: Colors.white12, height: 1),
          _optionTile(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: const Color(0xFFE57373),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  //fila individual de opción con icono, texto y flecha
  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
    );
  }
}
