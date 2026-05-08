import 'package:flutter/material.dart';

/// Una fila editable del listado de ingredientes en el formulario manual.
/// Incluye campo de nombre, campo de cantidad+unidad y botón para borrar.
class IngredientFormRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final VoidCallback? onRemove;
  final bool canRemove;

  const IngredientFormRow({
    super.key,
    required this.nameController,
    required this.quantityController,
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
          Expanded(
            flex: 3,
            child: _RecipeTextField(
              controller: nameController,
              hint: 'Ingrediente...',
              maxLength: 80,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _RecipeTextField(
              controller: quantityController,
              hint: 'cant.',
              maxLength: 30,
            ),
          ),
          if (canRemove)
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.close,
                  color: Color(0xFF0C2D4E), size: 20),
              onPressed: onRemove,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _RecipeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int? maxLength;

  const _RecipeTextField({
    required this.controller,
    required this.hint,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
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
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
