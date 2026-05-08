import 'package:flutter/material.dart';
import '../../models/recipe_model.dart';

//tarjeta de resumen de receta para mostrar en el feed
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C2D4E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7A8FA3).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //título de la receta e indicador de si es pública o privada
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Color(0xFFE8C55A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  //icono de candado o globo según visibilidad de la receta
                  Icon(
                    recipe.isPublic ? Icons.public : Icons.lock_outline,
                    color: const Color(0xFF7A8FA3),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '@${recipe.authorUsername}',
                style: const TextStyle(
                  color: Color(0xFF7A8FA3),
                  fontSize: 12,
                ),
              ),
              //descripción corta si la receta la tiene
              if (recipe.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF5F0E8),
                    fontSize: 14,
                  ),
                ),
              ],
              //número de ingredientes de la receta
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: Color(0xFF7A8FA3),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.ingredients.length} ingredientes',
                    style: const TextStyle(
                      color: Color(0xFF7A8FA3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
