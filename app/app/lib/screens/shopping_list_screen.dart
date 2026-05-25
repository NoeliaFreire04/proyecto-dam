import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/shopping_list_item_model.dart';
import '../models/unit.dart';
import '../services/shopping_list_service.dart';
import '../widgets/unit_dropdown.dart';

/// Pantalla "Mi compra": gestiona la lista de la compra del usuario.
/// Permite añadir items manuales, marcarlos como comprados y limpiar
/// los ya marcados.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => ShoppingListScreenState();
}

// Estado público para poder recargar desde HomeScreen vía GlobalKey
// cuando el usuario vuelve a este tab después de añadir desde una receta.
class ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListService _service = ShoppingListService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();

  List<ShoppingListItem> _items = [];
  bool _loading = true;
  bool _adding = false;
  // Unidad seleccionada para el próximo ítem que se añada.
  Unit _selectedUnit = Unit.uds;
  // Emoji que se aplicará al próximo ítem añadido. Null = sin emoji
  // (la UI muestra el icono genérico de carrito).
  String? _selectedEmoji;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  // Permite que HomeScreen fuerce una recarga al volver a este tab.
  void reload() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.getAll();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Error al cargar la lista');
    }
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _adding) return;

    setState(() => _adding = true);
    try {
      // Nombre + cantidad numérica + unidad del dropdown.
      // La cantidad puede ir vacía (ej. "pizca de sal").
      final qtyRaw = _qtyCtrl.text.trim().replaceAll(',', '.');
      final qty = double.tryParse(qtyRaw);
      final created = await _service.add(
        itemName: name,
        quantity: qty,
        unit: _selectedUnit.code,
        emoji: _selectedEmoji,
      );
      if (!mounted) return;
      setState(() {
        _items.insert(0, created);
        _nameCtrl.clear();
        _qtyCtrl.clear();
        _selectedEmoji = null;
        _selectedUnit = Unit.uds;
      });
    } catch (_) {
      _toast('No se pudo añadir el ítem');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  /// Abre un selector de emoji en bottom sheet.
  Future<void> _pickEmoji() async {
    final picked = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: const Color(0xFF0C2D4E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EmojiPickerSheet(currentEmoji: _selectedEmoji),
    );
    // Diferenciamos "no eligió nada (cerrar)" de "eligió quitar emoji".
    if (!mounted) return;
    if (picked != null) {
      // Pasamos string vacío como sentinela de "quitar".
      setState(() => _selectedEmoji = picked.isEmpty ? null : picked);
    }
  }


  Future<void> _toggle(ShoppingListItem item) async {
    // Optimista: actualiza UI antes de la respuesta.
    final original = item;
    setState(() {
      _items = _items
          .map((i) => i.id == item.id
              ? ShoppingListItem(
                  id: i.id,
                  itemName: i.itemName,
                  quantity: i.quantity,
                  unit: i.unit,
                  isChecked: !i.isChecked,
                  emoji: i.emoji,
                  createdAt: i.createdAt,
                )
              : i)
          .toList();
    });
    try {
      await _service.toggle(item.id);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = _items.map((i) => i.id == item.id ? original : i).toList();
      });
      _toast('No se pudo actualizar');
    }
  }

  Future<void> _delete(ShoppingListItem item) async {
    try {
      await _service.delete(item.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((i) => i.id == item.id));
    } catch (_) {
      _toast('No se pudo eliminar');
    }
  }

  Future<void> _clearChecked() async {
    if (_checkedItems.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2D4E),
        title: const Text('Limpiar comprados',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            '¿Eliminar todos los ítems marcados como comprados?',
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
    if (confirm != true) return;
    try {
      await _service.clearChecked();
      if (!mounted) return;
      setState(() => _items.removeWhere((i) => i.isChecked));
    } catch (_) {
      _toast('No se pudo limpiar');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<ShoppingListItem> get _pendingItems =>
      _items.where((i) => !i.isChecked).toList();
  List<ShoppingListItem> get _checkedItems =>
      _items.where((i) => i.isChecked).toList();

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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C2D4E)),
              )
            : RefreshIndicator(
                color: const Color(0xFFF5C518),
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildAddItem(),
                    const SizedBox(height: 20),
                    if (_pendingItems.isNotEmpty) ...[
                      _sectionTitle('PENDIENTES', _pendingItems.length),
                      ..._pendingItems.map((i) => _buildItemTile(i)),
                      const SizedBox(height: 16),
                    ],
                    if (_checkedItems.isNotEmpty) ...[
                      _sectionTitle('COMPRADOS', _checkedItems.length),
                      ..._checkedItems.map((i) => _buildItemTile(i)),
                    ],
                    if (_items.isEmpty) _buildEmptyState(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mi compra',
                style: TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_pendingItems.length} pendientes · ${_checkedItems.length} comprados',
                style: const TextStyle(color: Color(0xFF7E8A99), fontSize: 12),
              ),
            ],
          ),
        ),
        if (_checkedItems.isNotEmpty)
          GestureDetector(
            onTap: _clearChecked,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E0D2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Limpiar',
                style: TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddItem() {
    // Layout en 2 filas:
    //   Fila 1: [emoji]  [nombre del producto............]  [+ añadir]
    //   Fila 2: [cantidad]                          [dropdown unidad]
    // Así cabe bien en móvil y cada campo tiene espacio.
    return Column(
      children: [
        Row(
          children: [
            // Botón cuadrado para elegir emoji
            SizedBox(
              width: 52,
              height: 52,
              child: ElevatedButton(
                onPressed: _adding ? null : _pickEmoji,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF0C2D4E).withOpacity(0.15),
                    ),
                  ),
                ),
                child: Text(
                  _selectedEmoji ?? '😀',
                  style: TextStyle(
                    fontSize: _selectedEmoji != null ? 24 : 22,
                    color: _selectedEmoji != null
                        ? null
                        : const Color(0xFF0C2D4E).withOpacity(0.35),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nombre del producto
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                style: const TextStyle(color: Color(0xFF0C2D4E)),
                decoration: _whiteFieldDecoration('Nombre del producto'),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de añadir
            SizedBox(
              width: 52,
              height: 52,
              child: ElevatedButton(
                onPressed: _adding ? null : _add,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5C518),
                  foregroundColor: const Color(0xFF0C2D4E),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _adding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0C2D4E),
                        ),
                      )
                    : const Icon(Icons.add, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Cantidad numérica
            Expanded(
              flex: 2,
              child: TextField(
                controller: _qtyCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                maxLength: 10,
                style: const TextStyle(color: Color(0xFF0C2D4E)),
                decoration: _whiteFieldDecoration('Cantidad'),
              ),
            ),
            const SizedBox(width: 8),
            // Dropdown de unidad
            Expanded(
              flex: 3,
              child: UnitDropdown(
                value: _selectedUnit,
                onChanged: (u) => setState(() => _selectedUnit = u),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Estilo común para los TextField del formulario "añadir".
  InputDecoration _whiteFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF0C2D4E).withOpacity(0.4)),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF0C2D4E).withOpacity(0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF0C2D4E).withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5C518), width: 2),
      ),
    );
  }

  Widget _sectionTitle(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label  $count',
        style: const TextStyle(
          color: Color(0xFF7E8A99),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildItemTile(ShoppingListItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE57373),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _delete(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0C2D4E).withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: item.isChecked,
              onChanged: (_) => _toggle(item),
              activeColor: const Color(0xFFF5C518),
              checkColor: const Color(0xFF0C2D4E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Emoji a la izquierda del nombre. Si no hay, mostramos un
            // icono pequeño en gris para que la fila sea uniforme.
            SizedBox(
              width: 28,
              child: item.emoji != null && item.emoji!.isNotEmpty
                  ? Text(item.emoji!, style: const TextStyle(fontSize: 20))
                  : const Icon(Icons.shopping_basket_outlined,
                      color: Color(0xFF7E8A99), size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.itemName,
                style: TextStyle(
                  color: const Color(0xFF0C2D4E),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: const Color(0xFF7E8A99),
                ),
              ),
            ),
            Text(
              item.displayQuantity,
              style: TextStyle(
                color: const Color(0xFF0C2D4E).withOpacity(
                    item.isChecked ? 0.4 : 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 56,
            color: const Color(0xFF0C2D4E).withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tu lista de la compra está vacía',
            style: TextStyle(
              color: Color(0xFF0C2D4E),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Añade ítems manualmente o desde una receta',
            style: TextStyle(color: Color(0xFF7E8A99), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet con el grid de emojis sugeridos. Devuelve el emoji elegido
/// vía `Navigator.pop`, o `""` (string vacío) si el usuario pulsa "Quitar".
class _EmojiPickerSheet extends StatelessWidget {
  final String? currentEmoji;
  const _EmojiPickerSheet({this.currentEmoji});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Elige un emoji',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (currentEmoji != null && currentEmoji!.isNotEmpty)
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ''),
                  icon: const Icon(Icons.close, color: Color(0xFFE57373)),
                  label: const Text('Quitar',
                      style: TextStyle(color: Color(0xFFE57373))),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Grid en 8 columnas con los emojis sugeridos.
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: FoodEmojis.common.length,
              itemBuilder: (_, i) {
                final e = FoodEmojis.common[i];
                final selected = e == currentEmoji;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, e),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFF5C518).withOpacity(0.3)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: selected
                          ? Border.all(
                              color: const Color(0xFFF5C518), width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 22)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
