import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/shopping_list_item_model.dart';

/// Servicio HTTP para la gestión de la lista de la compra.
/// Todos los endpoints requieren autenticación.
class ShoppingListService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Lista todos los ítems del usuario autenticado.
  Future<List<ShoppingListItem>> getAll() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/shopping-list'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar la lista de la compra');
  }

  /// Añade un ítem manual.
  Future<ShoppingListItem> add({
    required String itemName,
    double? quantity,
    String? unit,
    String? emoji,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/shopping-list'),
      headers: headers,
      body: jsonEncode({
        'itemName': itemName,
        'quantity': quantity,
        'unit': unit,
        'emoji': emoji,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ShoppingListItem.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al añadir el ítem');
  }

  /// Añade los ingredientes de una receta a la lista.
  /// El backend usa el endpoint `/generate/{recipeId}` y solo añade los
  /// ingredientes que el usuario aún no tiene en su inventario.
  Future<List<ShoppingListItem>> addFromRecipe(int recipeId) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/shopping-list/generate/$recipeId'),
      headers: headers,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al añadir los ingredientes a la lista');
  }

  /// Marca o desmarca un ítem como comprado (toggle).
  Future<ShoppingListItem> toggle(int itemId) async {
    final headers = await _authHeaders();
    final response = await http.patch(
      Uri.parse('${AppConstants.baseUrl}/shopping-list/$itemId/toggle'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return ShoppingListItem.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al actualizar el ítem');
  }

  /// Elimina un ítem.
  Future<void> delete(int itemId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/shopping-list/$itemId'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el ítem');
    }
  }

  /// Elimina todos los ítems marcados como comprados.
  Future<int> clearChecked() async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/shopping-list/checked'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['deleted'] as num?)?.toInt() ?? 0;
    }
    throw Exception('Error al limpiar la lista');
  }
}
