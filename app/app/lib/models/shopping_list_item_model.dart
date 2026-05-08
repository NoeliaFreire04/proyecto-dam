/// Modelo del frontend para un ítem de la lista de la compra.
/// Coincide con `ShoppingListItemDTO` del backend.
class ShoppingListItem {
  final int id;
  final String itemName;
  final double? quantity;
  final String? unit;
  final bool isChecked;
  final String? createdAt;

  ShoppingListItem({
    required this.id,
    required this.itemName,
    this.quantity,
    this.unit,
    required this.isChecked,
    this.createdAt,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: (json['id'] as num).toInt(),
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
      isChecked: json['isChecked'] ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }

  /// Devuelve "200 g", "2 uds" o cadena vacía si no hay cantidad/unidad.
  String get displayQuantity {
    final q = quantity;
    final u = unit ?? '';
    if (q == null) return u;
    final clean = q == q.roundToDouble()
        ? q.toInt().toString()
        : q.toStringAsFixed(1);
    return '$clean${u.isEmpty ? '' : ' $u'}';
  }
}
