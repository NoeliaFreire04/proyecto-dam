//modelo del frontend para un ítem del inventario doméstico del usuario
class InventoryItem {
  final int id;
  final String itemName;
  final double? quantity;
  final String? unit;

  InventoryItem({
    required this.id,
    required this.itemName,
    this.quantity,
    this.unit,
  });

  //construye el modelo a partir del JSON devuelto por la API
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: (json['id'] as num).toInt(),
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
    );
  }

  //devuelve "200 g", "2 uds" o cadena vacía si no hay cantidad ni unidad
  //Para unidades cualitativas ("pizca", "al gusto") solo muestra la unidad.
  String get displayQuantity {
    final u = unit ?? '';
    const qualitative = {'pizca', 'al gusto'};
    if (qualitative.contains(u.toLowerCase())) return u;
    final q = quantity;
    if (q == null) return u;
    final clean = q == q.roundToDouble()
        ? q.toInt().toString()
        : q.toStringAsFixed(1);
    return '$clean${u.isEmpty ? '' : ' $u'}';
  }
}
