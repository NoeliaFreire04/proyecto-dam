import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  Future<List<Recipe>> getFeed({
    int page = 0,
    int size = 10,
    String? category,
  }) async {
    final token = await _storage.read(key: 'token');
    final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
    // Construimos la URL con ?category=XYZ solo si se pasa un filtro real.
    final params = <String, String>{
      'page': '$page',
      'size': '$size',
      if (category != null && category.isNotEmpty && category != 'TODAS')
        'category': category,
    };
    final uri = Uri.parse('${AppConstants.baseUrl}/recipes/feed')
        .replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
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

  /// Actualiza una receta existente (PUT /api/recipes/{id}).
  Future<Recipe> updateRecipe({
    required int id,
    required String title,
    String? description,
    String? instructions,
    required int servingsBase,
    required bool isPublic,
    String? imageUrl,
    String? category,
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
      'category': category ?? 'OTRA',
      'recipeIngredients': ingredients,
    });

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/recipes/$id'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al actualizar la receta (${response.statusCode})');
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
    String? category,
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
      'category': category ?? 'OTRA',
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
  ///
  /// En **móvil/desktop** se pasa `filePath` (file_picker expone path).
  /// En **web** se debe pasar `bytes` (file_picker no expone path en web).
  Future<Recipe> createFromVideo({
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    final token = await _storage.read(key: 'token');
    if (token == null || token.isEmpty) {
      throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
    }

    final uri = Uri.parse('${AppConstants.baseUrl}/recipes/from-video');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'video',
          bytes,
          filename: fileName ?? 'video',
          contentType: MediaType.parse(_mimeTypeFromName(fileName ?? 'video.mp4')),
        ),
      );
    } else if (filePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          filePath,
          filename: fileName,
        ),
      );
    } else {
      throw ArgumentError('Hay que pasar filePath o bytes');
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sesión expirada. Por favor, cierra la app e inicia sesión de nuevo.');
    }
    // Intentamos extraer el mensaje real del error del backend para
    // mostrarlo al usuario (p.ej. "Has alcanzado el límite de Gemini").
    String detail = '';
    try {
      final body = utf8.decode(response.bodyBytes);
      // Si es JSON, sacamos message; si es texto, lo usamos directamente.
      if (body.isNotEmpty) {
        try {
          final json = jsonDecode(body);
          detail = (json is Map && json['message'] != null)
              ? json['message'].toString()
              : body;
        } catch (_) {
          detail = body;
        }
      }
    } catch (_) {}
    throw Exception(detail.isEmpty
        ? 'Error al analizar el vídeo (${response.statusCode})'
        : detail);
  }

  String _mimeTypeFromName(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'webm':
        return 'video/webm';
      default:
        return 'video/mp4';
    }
  }
}
