import 'package:flutter/material.dart';

import '../models/shopping_list_item_model.dart';
import '../services/shopping_list_service.dart';

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
  final TextEditingController _addCtrl = TextEditingController();

  List<ShoppingListItem> _items = [];
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addCtrl.dispose();
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
    final text = _addCtrl.text.trim();
    if (text.isEmpty || _adding) return;

    setState(() => _adding = true);
    try {
      // Acepta formatos como "Pomelo 100g" o solo "Pomelo".
      final parsed = _splitNameAndQuantity(text);
      final created = await _service.add(
        itemName: parsed['name'] as String,
        quantity: parsed['quantity'] as double?,
        unit: parsed['unit'] as String?,
      );
      if (!mounted) return;
      setState(() {
        _items.insert(0, created);
        _addCtrl.clear();
      });
    } catch (_) {
      _toast('No se pudo añadir el ítem');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  /// Parsea "Pomelo 100 g" → name=Pomelo, quantity=100, unit=g.
  Map<String, dynamic> _splitNameAndQuantity(String input) {
    final regex = RegExp(r'^(.*?)\s+([\d.,]+)\s*([A-Za-zµ]*)$');
    final match = regex.firstMatch(input.trim());
    if (match == null) {
      return {'name': input.trim(), 'quantity': null, 'unit': null};
    }
    final name = match.group(1)!.trim();
    final qty = double.tryParse(match.group(2)!.replaceAll(',', '.'));
    final unit = match.group(3);
    return {
      'name': name.isEmpty ? input.trim() : name,
      'quantity': qty,
      'unit': (unit == null || unit.isEmpty) ? null : unit,
    };
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _addCtrl,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
            maxLength: 80,
            style: const TextStyle(color: Color(0xFF0C2D4E)),
            decoration: InputDecoration(
              hintText: 'Añadir ítem... (ej: Tomate 200g)',
              hintStyle:
                  TextStyle(color: const Color(0xFF0C2D4E).withOpacity(0.4)),
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
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
                borderSide: const BorderSide(
                  color: Color(0xFFF5C518),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
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
