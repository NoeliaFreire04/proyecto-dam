import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../../widgets/recipe/ingredient_form_row.dart';
import '../../widgets/recipe/recipe_text_field.dart';
import '../../widgets/recipe/visibility_selector.dart';
import '../recipe_detail_screen.dart';

/// Vista del modo "Formulario manual" para crear receta.
/// Valida campos obligatorios y construye el payload para el backend.
class ManualModeView extends StatefulWidget {
  const ManualModeView({super.key});

  @override
  State<ManualModeView> createState() => _ManualModeViewState();
}

class _ManualModeViewState extends State<ManualModeView> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _service = RecipeService();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '4');
  final _timeCtrl = TextEditingController(text: '30 min');

  bool _isPublic = true;
  bool _saving = false;

  // Cada ingrediente tiene dos controladores (nombre y cantidad).
  final List<_IngredientControllers> _ingredients = [
    _IngredientControllers(name: 'Espaguetis', quantity: '200 g'),
    _IngredientControllers(name: 'Huevos', quantity: '2 uds'),
    _IngredientControllers(),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _instructionsCtrl.dispose();
    _servingsCtrl.dispose();
    _timeCtrl.dispose();
    for (final i in _ingredients) {
      i.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() => _ingredients.add(_IngredientControllers()));
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  /// Convierte el texto "200 g" → {quantity: 200, unit: "g"}.
  /// Si no se puede parsear, deja la cantidad como null.
  Map<String, dynamic> _parseQuantity(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return {'quantity': null, 'unit': null};

    final match = RegExp(r'^([\d.,]+)\s*(.*)$').firstMatch(clean);
    if (match == null) {
      return {'quantity': null, 'unit': clean};
    }
    final raw = match.group(1)!.replaceAll(',', '.');
    final qty = double.tryParse(raw);
    final unit = match.group(2)?.trim();
    return {
      'quantity': qty,
      'unit': (unit == null || unit.isEmpty) ? null : unit,
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = <Map<String, dynamic>>[];
    for (final i in _ingredients) {
      final name = i.nameController.text.trim();
      if (name.isEmpty) continue;
      final parsed = _parseQuantity(i.quantityController.text);
      ingredients.add({
        'ingredientName': name,
        'quantity': parsed['quantity'],
        'unit': parsed['unit'],
      });
    }

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos un ingrediente')),
      );
      return;
    }

    final servings = int.tryParse(_servingsCtrl.text.trim());
    if (servings == null || servings <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comensales debe ser un número positivo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final time = _timeCtrl.text.trim();
      final description = _descriptionCtrl.text.trim();
      final fullDescription = time.isEmpty
          ? description
          : (description.isEmpty ? 'Tiempo: $time' : '$description\n\nTiempo: $time');

      final Recipe created = await _service.createRecipe(
        title: _titleCtrl.text.trim(),
        description: fullDescription.isEmpty ? null : fullDescription,
        instructions: _instructionsCtrl.text.trim().isEmpty
            ? null
            : _instructionsCtrl.text.trim(),
        servingsBase: servings,
        isPublic: _isPublic,
        ingredients: ingredients,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta creada')),
      );

      // Reseteamos el formulario antes de navegar al detalle, para que
      // si el usuario vuelve atrás encuentre el formulario vacío y no
      // los datos de la receta que ya creó.
      _resetForm();

      // Usamos push (no pushReplacement) porque esta vista vive dentro
      // del tab "Crear" del IndexedStack del HomeScreen. Si hicieramos
      // pushReplacement, reemplazaríamos el HomeScreen entero y al hacer
      // back se quedaría la app en blanco.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: created),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la receta')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Limpia todos los campos para dejar el formulario listo para una
  /// nueva receta tras crear una.
  void _resetForm() {
    _titleCtrl.clear();
    _descriptionCtrl.clear();
    _instructionsCtrl.clear();
    _servingsCtrl.text = '4';
    _timeCtrl.text = '30 min';
    setState(() {
      _isPublic = true;
      for (final i in _ingredients) {
        i.dispose();
      }
      _ingredients
        ..clear()
        ..addAll([
          _IngredientControllers(),
          _IngredientControllers(),
          _IngredientControllers(),
        ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecipeTextField(
            controller: _titleCtrl,
            labelOnTop: 'TÍTULO *',
            hint: 'Ej: Tortilla española',
            maxLength: 200,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'El título es obligatorio';
              if (v.trim().length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 14),
          RecipeTextField(
            controller: _descriptionCtrl,
            labelOnTop: 'DESCRIPCIÓN',
            hint: 'Breve introducción de la receta...',
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RecipeTextField(
                  controller: _servingsCtrl,
                  labelOnTop: 'COMENSALES *',
                  hint: '4',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatorio';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RecipeTextField(
                  controller: _timeCtrl,
                  labelOnTop: 'TIEMPO',
                  hint: '30 min',
                  maxLength: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'VISIBILIDAD',
            style: TextStyle(
              color: Color(0xFF0C2D4E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          VisibilitySelector(
            isPublic: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INGREDIENTES *',
                style: TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: _addIngredient,
                child: const Text(
                  '+ añadir',
                  style: TextStyle(
                    color: Color(0xFFF5C518),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'NOMBRE',
                    style: TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CANT. / UD.',
                    style: TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
          ),
          ..._ingredients.asMap().entries.map((entry) {
            final i = entry.key;
            final ctrls = entry.value;
            return IngredientFormRow(
              key: ValueKey(ctrls.id),
              nameController: ctrls.nameController,
              quantityController: ctrls.quantityController,
              canRemove: _ingredients.length > 1,
              onRemove: () => _removeIngredient(i),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C2D4E),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF0C2D4E).withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar receta'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pareja de controladores para una fila de ingrediente.
class _IngredientControllers {
  final String id = UniqueKey().toString();
  final TextEditingController nameController;
  final TextEditingController quantityController;

  _IngredientControllers({String? name, String? quantity})
      : nameController = TextEditingController(text: name ?? ''),
        quantityController = TextEditingController(text: quantity ?? '');

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}
