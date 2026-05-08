import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/inventory_item_model.dart';

//servicio HTTP para la gestión del inventario doméstico del usuario
class InventoryService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  //devuelve todos los productos del inventario del usuario autenticado
  Future<List<InventoryItem>> getAll() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/inventory'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al cargar el inventario');
  }

  //añade un producto al inventario del usuario y devuelve el ítem guardado
  Future<InventoryItem> add({
    required String itemName,
    double? quantity,
    String? unit,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/inventory'),
      headers: headers,
      body: jsonEncode({
        'itemName': itemName,
        'quantity': quantity,
        'unit': unit,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return InventoryItem.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    }
    throw Exception('Error al añadir el producto');
  }

  //elimina un producto del inventario por su ID
  Future<void> delete(int itemId) async {
    final headers = await _authHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/inventory/$itemId'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el producto');
    }
  }
}
