import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/unit.dart';
import '../unit_dropdown.dart';

/// Una fila editable del listado de ingredientes en el formulario manual.
///
/// Estructura: [nombre]  [cantidad numérica]  [dropdown unidad]  [✕]
///
/// La unidad se selecciona de un dropdown único en toda la app (Unit
/// enum). Así evitamos que cada usuario escriba "g" / "gr" / "gramos"
/// y rompa los matchings con la despensa.
class IngredientFormRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final Unit unit;
  final ValueChanged<Unit> onUnitChanged;
  final VoidCallback? onRemove;
  final bool canRemove;

  const IngredientFormRow({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.unit,
    required this.onUnitChanged,
    this.onRemove,
    this.canRemove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del ingrediente
          Expanded(
            flex: 4,
            child: _RecipeTextField(
              controller: nameController,
              hint: 'Ingrediente...',
              maxLength: 80,
            ),
          ),
          const SizedBox(width: 6),
          // Cantidad numérica (solo dígitos + coma/punto)
          Expanded(
            flex: 2,
            child: _RecipeTextField(
              controller: quantityController,
              hint: 'cant.',
              maxLength: 10,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Dropdown de unidad
          Expanded(
            flex: 3,
            child: UnitDropdown(
              value: unit,
              onChanged: onUnitChanged,
              compact: true,
            ),
          ),
          if (canRemove)
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.close,
                  color: Color(0xFF0C2D4E), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onRemove,
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _RecipeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _RecipeTextField({
    required this.controller,
    required this.hint,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF0C2D4E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF0C2D4E).withOpacity(0.4),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F0E8),
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF0C2D4E).withOpacity(0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF0C2D4E).withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFF5C518),
            width: 2,
          ),
        ),
      ),
    );
  }
}
