//modelo que representa un ingrediente dentro de una receta
class RecipeIngredient {
  final String ingredientName;
  final double? quantity;
  final String? unit;

  RecipeIngredient({
    required this.ingredientName,
    this.quantity,
    this.unit,
  });

  //construye el ingrediente a partir del JSON de la API
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientName: json['ingredientName'] ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
    );
  }
}

//modelo principal que representa una receta completa con todos sus datos
class Recipe {
  final int id;
  final String title;
  final String? description;
  final String? instructions;
  final int servingsBase;
  final bool isPublic;
  final String? imageUrl;
  final String authorUsername;
  final String? createdAt;
  final List<RecipeIngredient> recipeIngredients;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.instructions,
    required this.servingsBase,
    required this.isPublic,
    this.imageUrl,
    required this.authorUsername,
    this.createdAt,
    required this.recipeIngredients,
  });

  //convierte el JSON de la API en un objeto Recipe, incluyendo la lista de ingredientes
  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredients = (json['recipeIngredients'] as List<dynamic>? ?? [])
        .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
        .toList();

    return Recipe(
      id: (json['id'] as num).toInt(),
      title: json['title'] ?? '',
      description: json['description'],
      instructions: json['instructions'],
      servingsBase: (json['servingsBase'] as num?)?.toInt() ?? 1,
      isPublic: json['isPublic'] ?? false,
      imageUrl: json['imageUrl'],
      authorUsername: json['authorUsername'] ?? '',
      createdAt: json['createdAt']?.toString(),
      recipeIngredients: ingredients,
    );
  }
}
