import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/inventory_item_model.dart';
import '../models/unit.dart';
import '../services/inventory_service.dart';
import '../widgets/unit_dropdown.dart';

//pantalla que muestra y gestiona el inventario doméstico del usuario
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _service = InventoryService();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  // Unidad seleccionada al añadir un producto al inventario.
  Unit _selectedUnit = Unit.uds;

  List<InventoryItem> _items = [];
  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

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
      _toast('Error al cargar el inventario');
    }
  }

  Future<void> _add() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _adding) return;

    setState(() => _adding = true);
    try {
      final qty = double.tryParse(_quantityCtrl.text.replaceAll(',', '.'));
      final created = await _service.add(
        itemName: name,
        quantity: qty,
        unit: _selectedUnit.code,
      );
      if (!mounted) return;
      setState(() {
        _items.insert(0, created);
        _nameCtrl.clear();
        _quantityCtrl.clear();
        _selectedUnit = Unit.uds;
      });
      Navigator.of(context).pop();
    } catch (_) {
      _toast('No se pudo añadir el producto');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _delete(InventoryItem item) async {
    try {
      await _service.delete(item.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((i) => i.id == item.id));
    } catch (_) {
      _toast('No se pudo eliminar el producto');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  //abre el diálogo para añadir un producto nuevo al inventario
  void _showAddDialog() {
    _nameCtrl.clear();
    _quantityCtrl.clear();
    setState(() => _selectedUnit = Unit.uds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddItemSheet(
        nameCtrl: _nameCtrl,
        quantityCtrl: _quantityCtrl,
        unit: _selectedUnit,
        onUnitChanged: (u) => setState(() => _selectedUnit = u),
        adding: _adding,
        onAdd: _add,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi despensa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFF5C518),
        foregroundColor: const Color(0xFF0C2D4E),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0C2D4E)))
          : RefreshIndicator(
              color: const Color(0xFFF5C518),
              onRefresh: _load,
              child: _items.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: _items.length,
                      itemBuilder: (_, i) => _buildTile(_items[i]),
                    ),
            ),
    );
  }

  //tarjeta deslizable para eliminar un producto del inventario
  Widget _buildTile(InventoryItem item) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0C2D4E).withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C518).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.kitchen_outlined,
                color: Color(0xFF0C2D4E),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      color: Color(0xFF0C2D4E),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (item.displayQuantity.isNotEmpty)
                    Text(
                      item.displayQuantity,
                      style: const TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFE57373), size: 20),
              onPressed: () => _delete(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.kitchen_outlined,
                size: 64,
                color: const Color(0xFF0C2D4E).withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu despensa está vacía',
                style: TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Añade los productos que tienes en casa\npara que la lista de la compra sea más precisa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7E8A99), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//hoja inferior para añadir un nuevo producto al inventario
class _AddItemSheet extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController quantityCtrl;
  final Unit unit;
  final ValueChanged<Unit> onUnitChanged;
  final bool adding;
  final VoidCallback onAdd;

  const _AddItemSheet({
    required this.nameCtrl,
    required this.quantityCtrl,
    required this.unit,
    required this.onUnitChanged,
    required this.adding,
    required this.onAdd,
  });

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C2D4E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Añadir producto',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(
            controller: widget.nameCtrl,
            hint: 'Nombre del producto (ej: Tomate)',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildField(
                  controller: widget.quantityCtrl,
                  hint: 'Cantidad',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Dropdown estandarizado de unidades (sustituye al TextField).
              // Modo dark para encajar con el fondo azul del bottom sheet.
              Expanded(
                flex: 3,
                child: UnitDropdown(
                  value: widget.unit,
                  onChanged: widget.onUnitChanged,
                  dark: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.adding ? null : widget.onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C518),
                foregroundColor: const Color(0xFF0C2D4E),
                disabledBackgroundColor:
                    const Color(0xFFF5C518).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: widget.adding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0C2D4E),
                      ),
                    )
                  : const Text(
                      'Añadir a la despensa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0A2240),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFF5C518), width: 1.5),
        ),
      ),
    );
  }
}
