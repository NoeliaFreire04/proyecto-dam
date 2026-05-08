import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Recipe>> getFeed({int page = 0, int size = 10}) async {
    final token = await _storage.read(key: 'token');
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/recipes/feed?page=$page&size=$size'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      // El backend devuelve un Page<RecipeDTO> con la propiedad "content".
      // Si en algún caso devolviera una lista directa, también lo soportamos.
      final List<dynamic> data = decoded is Map<String, dynamic>
          ? (decoded['content'] as List<dynamic>? ?? const [])
          : (decoded as List<dynamic>);
      return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar el feed');
  }

  Future<List<Recipe>> getMyRecipes() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/recipes/mine'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar tus recetas');
  }

  Future<Recipe> getRecipeById(int id) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/recipes/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al cargar la receta');
  }

  Future<List<Recipe>> getFavorites() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/favorites'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar favoritos');
  }

  Future<void> addFavorite(int recipeId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/favorites/$recipeId'),
      headers: headers,
    );
    if (response.statusCode != 201) {
      throw Exception('Error al añadir a favoritos');
    }
  }

  Future<void> removeFavorite(int recipeId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/favorites/$recipeId'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar de favoritos');
    }
  }

  Future<void> deleteRecipe(int recipeId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/recipes/$recipeId'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la receta');
    }
  }

  /// Crea una receta nueva (formulario manual).
  /// Envía un JSON con los campos del DTO esperado por el backend.
  Future<Recipe> createRecipe({
    required String title,
    String? description,
    String? instructions,
    required int servingsBase,
    required bool isPublic,
    String? imageUrl,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    final headers = await _authHeaders();
    final body = jsonEncode({
      'title': title,
      'description': description,
      'instructions': instructions,
      'servingsBase': servingsBase,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'recipeIngredients': ingredients,
    });

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/recipes'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al crear la receta (${response.statusCode})');
  }

  /// Crea una receta a partir de un vídeo usando Gemini (multipart).
  /// El backend espera el campo "video" como MultipartFile.
  Future<Recipe> createFromVideo({
    required String filePath,
    String? fileName,
  }) async {
    final token = await _storage.read(key: 'token');
    final uri = Uri.parse('${AppConstants.baseUrl}/recipes/from-video');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'video',
        filePath,
        filename: fileName,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al analizar el vídeo (${response.statusCode})');
  }
}
