import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';

//lista de ingredientes con ajuste de cantidad según el número de comensales
class IngredientList extends StatefulWidget {
  final List<RecipeIngredient> ingredients;

  //número de comensales base de la receta original
  final int baseServings;

  const IngredientList({
    super.key,
    required this.ingredients,
    required this.baseServings,
  });

  @override
  State<IngredientList> createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.baseServings;
  }

  //calcula la cantidad escalada según los comensales actuales
  double _scaled(double baseQuantity) {
    return baseQuantity * _servings / widget.baseServings;
  }

  //sin decimales si el resultado es entero, con 1 decimal si no
  String _format(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //control para subir o bajar el número de comensales
        Row(
          children: [
            const Text(
              'Comensales',
              style: TextStyle(
                color: Color(0xFFF5F0E8),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _StepButton(
              icon: Icons.remove,
              onTap: _servings > 1 ? () => setState(() => _servings--) : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$_servings',
                style: const TextStyle(
                  color: Color(0xFFE8C55A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add,
              onTap: () => setState(() => _servings++),
            ),
          ],
        ),
        const SizedBox(height: 12),
        //fila por cada ingrediente con su cantidad ajustada
        ...widget.ingredients.map((i) {
          final qtyStr = i.quantity != null ? _format(_scaled(i.quantity!)) : '';
          final unitStr = i.unit ?? '';
          final amount = [qtyStr, unitStr].where((s) => s.isNotEmpty).join(' ');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    i.ingredientName,
                    style: const TextStyle(
                      color: Color(0xFFF5F0E8),
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF7A8FA3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

//botón circular para incrementar o decrementar el número de comensales
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null
              ? const Color(0xFFE8C55A)
              : const Color(0xFF7A8FA3).withValues(alpha: 0.3),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null
              ? const Color(0xFF0C2D4E)
              : const Color(0xFF7A8FA3),
        ),
      ),
    );
  }
}
