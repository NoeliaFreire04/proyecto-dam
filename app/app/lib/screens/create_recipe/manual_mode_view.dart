import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/recipe_model.dart';
import '../../models/unit.dart';
import '../../services/recipe_service.dart';
import '../../widgets/recipe/ingredient_form_row.dart';
import '../../widgets/recipe/recipe_text_field.dart';
import '../../widgets/recipe/visibility_selector.dart';
import '../recipe_detail_screen.dart';

/// Vista del modo "Formulario manual" para crear o editar una receta.
/// Si se pasa [initialRecipe], el formulario se rellena con sus datos y
/// al guardar se llama al endpoint PUT en lugar de POST.
class ManualModeView extends StatefulWidget {
  final Recipe? initialRecipe;

  const ManualModeView({super.key, this.initialRecipe});

  @override
  State<ManualModeView> createState() => _ManualModeViewState();
}

class _ManualModeViewState extends State<ManualModeView> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _service = RecipeService();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '4');
  final _timeCtrl = TextEditingController(text: '30 min');

  bool _isPublic = true;
  bool _saving = false;
  String _category = 'OTRA';

  // Cada ingrediente tiene nombre + cantidad numérica + unidad (enum).
  final List<_IngredientControllers> _ingredients = [
    _IngredientControllers(name: 'Espaguetis', quantity: '200', unit: Unit.g),
    _IngredientControllers(name: 'Huevos', quantity: '2', unit: Unit.uds),
    _IngredientControllers(),
  ];

  @override
  void initState() {
    super.initState();
    _imageUrlCtrl.addListener(() => setState(() {}));

    // Modo edición: rellenar todos los campos con los datos de la receta.
    final r = widget.initialRecipe;
    if (r != null) {
      _titleCtrl.text = r.title;
      _descriptionCtrl.text = r.description ?? '';
      _instructionsCtrl.text = r.instructions ?? '';
      _imageUrlCtrl.text = r.imageUrl ?? '';
      _servingsCtrl.text = '${r.servingsBase}';
      _timeCtrl.text = '';
      _isPublic = r.isPublic;
      _category = r.category;

      if (r.recipeIngredients.isNotEmpty) {
        for (final c in _ingredients) c.dispose();
        _ingredients
          ..clear()
          ..addAll(r.recipeIngredients.map((ing) => _IngredientControllers(
                name: ing.ingredientName,
                quantity: ing.quantity != null
                    ? _fmtQty(ing.quantity!)
                    : '',
                unit: Unit.fromCode(ing.unit),
              )));
      }
    }
  }

  /// Formatea la cantidad numérica suprimiendo decimales .0 innecesarios.
  static String _fmtQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _instructionsCtrl.dispose();
    _imageUrlCtrl.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = <Map<String, dynamic>>[];
    for (final i in _ingredients) {
      final name = i.nameController.text.trim();
      if (name.isEmpty) continue;
      // La cantidad es numérica directa. Si está vacía, default 1.
      // La unidad ya es un enum, no hay que parsear nada.
      final qtyRaw = i.quantityController.text.trim().replaceAll(',', '.');
      final qty = double.tryParse(qtyRaw);
      ingredients.add({
        'ingredientName': name,
        'quantity': (qty == null || qty <= 0) ? 1 : qty,
        'unit': i.unit.code,
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
      final imageUrl = _imageUrlCtrl.text.trim();

      if (widget.initialRecipe != null) {
        // ── MODO EDICIÓN ──
        final Recipe updated = await _service.updateRecipe(
          id: widget.initialRecipe!.id,
          title: _titleCtrl.text.trim(),
          description: fullDescription.isEmpty ? null : fullDescription,
          instructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          servingsBase: servings,
          isPublic: _isPublic,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          category: _category,
          ingredients: ingredients,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta actualizada')),
        );
        Navigator.pop(context, updated);
      } else {
        // ── MODO CREACIÓN ──
        final Recipe created = await _service.createRecipe(
          title: _titleCtrl.text.trim(),
          description: fullDescription.isEmpty ? null : fullDescription,
          instructions: _instructionsCtrl.text.trim().isEmpty
              ? null
              : _instructionsCtrl.text.trim(),
          servingsBase: servings,
          isPublic: _isPublic,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          category: _category,
          ingredients: ingredients,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta creada')),
        );
        _resetForm();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: created),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo guardar la receta')),
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
    _imageUrlCtrl.clear();
    _servingsCtrl.text = '4';
    _timeCtrl.text = '30 min';
    setState(() {
      _isPublic = true;
      _category = 'OTRA';
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
          RecipeTextField(
            controller: _imageUrlCtrl,
            labelOnTop: 'IMAGEN (URL)',
            hint: 'https://... (opcional)',
            maxLength: 500,
          ),
          if (_imageUrlCtrl.text.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildImagePreview(),
          ],
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
          const Text(
            'CATEGORÍA',
            style: TextStyle(
              color: Color(0xFF0C2D4E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          _buildCategoryDropdown(),
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
                  flex: 4,
                  child: Text(
                    'NOMBRE',
                    style: TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CANT.',
                    style: TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: Text(
                    'UNIDAD',
                    style: TextStyle(
                        color: Color(0xFF7E8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                SizedBox(width: 32),
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
              unit: ctrls.unit,
              onUnitChanged: (u) => setState(() => ctrls.unit = u),
              canRemove: _ingredients.length > 1,
              onRemove: () => _removeIngredient(i),
            );
          }),
          const SizedBox(height: 14),
          RecipeTextField(
            controller: _instructionsCtrl,
            labelOnTop: 'PASOS',
            hint: '1. Pica la cebolla...\n2. Sofríe en la sartén...\n3. ...',
            maxLines: 8,
            maxLength: 5000,
          ),
          const SizedBox(height: 16),
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
                  : Text(widget.initialRecipe != null
                      ? 'Actualizar receta'
                      : 'Guardar receta'),
            ),
          ),
        ],
      ),
    );
  }

  /// Previsualización de la imagen URL si está rellena.
  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        _imageUrlCtrl.text.trim(),
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 140,
          color: const Color(0xFFE8E0D2),
          alignment: Alignment.center,
          child: const Text(
            'URL de imagen inválida',
            style: TextStyle(color: Color(0xFF0C2D4E)),
          ),
        ),
      ),
    );
  }

  /// Dropdown con todas las categorías predefinidas del enum backend.
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0C2D4E).withOpacity(0.15),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Color(0xFF0C2D4E)),
          style: const TextStyle(color: Color(0xFF0C2D4E), fontSize: 15),
          dropdownColor: const Color(0xFFF5F0E8),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
          items: RecipeCategories.values.entries
              .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Estado de una fila de ingrediente: nombre + cantidad + unidad seleccionada.
class _IngredientControllers {
  final String id = UniqueKey().toString();
  final TextEditingController nameController;
  final TextEditingController quantityController;
  Unit unit;

  _IngredientControllers({String? name, String? quantity, Unit? unit})
      : nameController = TextEditingController(text: name ?? ''),
        quantityController = TextEditingController(text: quantity ?? ''),
        unit = unit ?? Unit.uds;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
  }
}
