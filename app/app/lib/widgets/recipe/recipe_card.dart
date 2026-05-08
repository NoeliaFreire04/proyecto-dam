import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';

//tarjeta de receta con imagen, usada en favoritos y perfil
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final Widget? trailing;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C2D4E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            //imagen de la receta o placeholder si no tiene foto
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            //información principal: título, autor y datos rápidos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.authorUsername,
                      style: const TextStyle(
                        color: Color(0xFFF5C518),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    //porciones e ingredientes en una fila compacta
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servingsBase} pers.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        if (recipe.recipeIngredients.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.kitchen_outlined,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.recipeIngredients.length} ingredientes',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //acción opcional al final de la tarjeta, por ejemplo quitar de favoritos
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }

  //imagen de sustitución cuando la receta no tiene foto
  Widget _placeholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFF0A2240),
      child: const Icon(Icons.restaurant, color: Colors.white38, size: 32),
    );
  }
}
