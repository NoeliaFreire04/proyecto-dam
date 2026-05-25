/// Modelo del frontend para un ítem de la lista de la compra.
/// Coincide con `ShoppingListItemDTO` del backend.
class ShoppingListItem {
  final int id;
  final String itemName;
  final double? quantity;
  final String? unit;
  final bool isChecked;
  /// Emoji asociado al producto. Si es null la UI usa un icono genérico.
  final String? emoji;
  final String? createdAt;

  ShoppingListItem({
    required this.id,
    required this.itemName,
    this.quantity,
    this.unit,
    required this.isChecked,
    this.emoji,
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
      emoji: json['emoji'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  /// Devuelve "200 g", "2 uds" o cadena vacía si no hay cantidad/unidad.
  /// Para unidades cualitativas ("pizca", "al gusto") devuelve solo la unidad
  /// sin la cantidad numérica (no tiene sentido decir "1 al gusto").
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

/// Catálogo de emojis sugeridos por categoría para el picker.
/// El usuario también puede escribir uno propio.
class FoodEmojis {
  static const List<String> common = [
    '🍅', '🥒', '🥕', '🌽', '🥔', '🧅', '🧄', '🥦', '🥬', '🍆',
    '🫑', '🌶️', '🍄', '🥑', '🍋', '🍊', '🍎', '🍐', '🍌', '🍓',
    '🍇', '🍉', '🍒', '🥝', '🍑', '🍍', '🥭', '🥥', '🍯', '🥛',
    '🧀', '🥚', '🥓', '🍗', '🍖', '🥩', '🐟', '🦐', '🦞', '🥖',
    '🍞', '🥐', '🥨', '🧈', '🌾', '🍚', '🍝', '🍕', '🌮', '🌯',
    '🥗', '🍲', '🍜', '🍣', '🍙', '🍰', '🧁', '🍪', '🍫', '☕',
    '🍵', '🍷', '🍺', '🥤', '🧃', '🧂', '🌿', '🫒', '🥜',
  ];
}
