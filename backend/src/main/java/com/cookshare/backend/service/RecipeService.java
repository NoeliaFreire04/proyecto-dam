package com.cookshare.backend.service;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.dto.RecipeIngredientDTO;
import com.cookshare.backend.entity.Category;
import com.cookshare.backend.entity.Ingredient;
import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.RecipeIngredient;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.IngredientRepository;
import com.cookshare.backend.repository.RecipeIngredientRepository;
import com.cookshare.backend.repository.RecipeRepository;
import com.cookshare.backend.repository.UserRepository;
import com.cookshare.backend.util.UnitNormalizer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio encargado de la lógica de negocio del recetario.
 * Gestiona la creación, edición, eliminación y consulta de recetas,
 * incluyendo la relación con sus ingredientes.
 */
@Service
public class RecipeService {
    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final UserRepository userRepository;
    private final IngredientRepository ingredientRepository;

    /**
     * Constructor con inyección de dependencias.
     * @param recipeRepository repositorio de recetas
     * @param recipeIngredientRepository repositorio de ingredientes de receta
     * @param userRepository repositorio de usuarios
     * @param ingredientRepository repositorio del catálogo de ingredientes
     */
    public RecipeService(RecipeRepository recipeRepository, RecipeIngredientRepository recipeIngredientRepository, UserRepository userRepository, IngredientRepository ingredientRepository) {
        this.recipeRepository = recipeRepository;
        this.recipeIngredientRepository = recipeIngredientRepository;
        this.userRepository = userRepository;
        this.ingredientRepository = ingredientRepository;
    }

    /**
     * Crea una receta nueva y la asocia al usuario autenticado.
     * Para cada ingrediente del DTO, lo busca en el catálogo o lo crea si no existe.
     *
     * @Transactional para que si falla un ingrediente a mitad, se haga rollback
     * y no quede una receta a medias en BD.
     */
    @Transactional
    public RecipeDTO create(RecipeDTO dto, String email){
        // Buscar el usuario por email
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty()){
            throw new RuntimeException("Usuario no encontrado.");
        }

        User user = userOpt.get();

        // Construir y guardar la receta
        Recipe recipe = Recipe.builder()
                .user(user)
                .description(dto.getDescription())
                .title(dto.getTitle())
                .imageUrl(dto.getImageUrl())
                .instructions(dto.getInstructions())
                .servingsBase(dto.getServingsBase())
                .isPublic(dto.getIsPublic())
                .category(parseCategory(dto.getCategory()))
                .build();
        Recipe recipeSave = recipeRepository.save(recipe);

        // Vamos a construir la lista de DTOs a la vez que guardamos, así
        // no tenemos que recargar la receta de BD (que puede no ver los
        // ingredientes aún dentro de la misma transacción).
        List<RecipeIngredientDTO> savedDtos = new ArrayList<>();

        // Procesar los ingredientes si vienen en el DTO
        if (dto.getRecipeIngredients() != null){
            // Catalogo de ingredientes ya añadidos en ESTA receta, para
            // evitar duplicados (la tabla recipe_ingredient tiene
            // UNIQUE (recipe_id, ingredient_id)).
            java.util.Set<Long> alreadyAddedIngredientIds = new java.util.HashSet<>();

            for (RecipeIngredientDTO ingredientDto : dto.getRecipeIngredients()){
                if (ingredientDto.getIngredientName() == null
                        || ingredientDto.getIngredientName().isBlank()) {
                    continue;
                }
                // Normalizar el nombre a minúsculas y sin espacios extra
                String nombre = ingredientDto.getIngredientName().trim().toLowerCase();

                // Buscar en el catálogo; si no existe, crearlo
                Optional<Ingredient> ingredientOpt = ingredientRepository.findByName(nombre);
                Ingredient ingredient;

                if(ingredientOpt.isEmpty()){
                    ingredient = ingredientRepository.save(Ingredient.builder().name(nombre).build());
                }else {
                    ingredient = ingredientOpt.get();
                }

                // Si ya añadimos este ingrediente en esta receta, skip
                // (evitamos violar la UniqueConstraint).
                if (!alreadyAddedIngredientIds.add(ingredient.getId())) {
                    continue;
                }

                // Defaults seguros para evitar fallo por @NotNull/@Positive
                BigDecimal quantity = ingredientDto.getQuantity();
                if (quantity == null || quantity.signum() <= 0) {
                    quantity = BigDecimal.ONE;
                }
                String unit = ingredientDto.getUnit();
                if (unit == null || unit.isBlank()) {
                    unit = "uds";
                }
                // Normaliza variantes a códigos canónicos del enum Unit
                // del frontend (ej: "gramos" → "g", "kilo" → "kg").
                unit = UnitNormalizer.normalize(unit);

                // Crear la relación receta-ingrediente
                RecipeIngredient ri = RecipeIngredient.builder().recipe(recipeSave).ingredient(ingredient).quantity(quantity).unit(unit).build();

                recipeIngredientRepository.save(ri);

                // Lo añadimos al DTO de respuesta directamente
                savedDtos.add(RecipeIngredientDTO.builder()
                        .ingredientName(ingredient.getName())
                        .quantity(quantity)
                        .unit(unit)
                        .build());
            }
        }

        // Construimos el DTO de respuesta directamente con los datos en
        // memoria, sin depender de recargar la receta de BD.
        return RecipeDTO.builder()
                .id(recipeSave.getId())
                .title(recipeSave.getTitle())
                .description(recipeSave.getDescription())
                .instructions(recipeSave.getInstructions())
                .servingsBase(recipeSave.getServingsBase())
                .isPublic(recipeSave.getIsPublic())
                .imageUrl(recipeSave.getImageUrl())
                .category(recipeSave.getCategory() != null ? recipeSave.getCategory().name() : Category.OTRA.name())
                .authorUsername(user.getUsername())
                .createdAt(recipeSave.getCreatedAt())
                .recipeIngredients(savedDtos)
                .build();
    }

    /**
     * Convierte un nombre de categoría (case-insensitive) al enum.
     * Si el valor es nulo o no coincide, devuelve OTRA por defecto.
     */
    private Category parseCategory(String value) {
        if (value == null || value.isBlank()) return Category.OTRA;
        try {
            return Category.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return Category.OTRA;
        }
    }

    /**
     * Convierte una entidad Recipe a DTO para no exponer entidades JPA en las respuestas.
     */
    public RecipeDTO toDTO(Recipe recipe){
        // Mapear cada RecipeIngredient a su DTO, normalizando la unidad
        // por si en BD hay variantes antiguas ("gramos" → "g").
        List<RecipeIngredientDTO> ingredientDTOs = new ArrayList<>();
        for (RecipeIngredient ri : recipe.getRecipeIngredients()) {
            RecipeIngredientDTO ingDTO = RecipeIngredientDTO.builder()
                    .ingredientName(ri.getIngredient().getName())
                    .quantity(ri.getQuantity())
                    .unit(UnitNormalizer.normalize(ri.getUnit()))
                    .build();
            ingredientDTOs.add(ingDTO);
        }

        // Construir el DTO completo con todos los campos
        return  RecipeDTO.builder().id(recipe.getId())
                .title(recipe.getTitle())
                .authorUsername(recipe.getUser().getUsername())
                .recipeIngredients(ingredientDTOs)
                .description(recipe.getDescription())
                .isPublic(recipe.getIsPublic())
                .servingsBase(recipe.getServingsBase())
                .instructions(recipe.getInstructions())
                .imageUrl(recipe.getImageUrl())
                .category(recipe.getCategory() != null ? recipe.getCategory().name() : Category.OTRA.name())
                .createdAt(recipe.getCreatedAt())
                .build();
    }

    /**
     * Actualiza una receta existente. Verifica que el usuario sea el autor.
     * Reemplaza los ingredientes anteriores por los nuevos del DTO.
     */
    public RecipeDTO update(Long id, RecipeDTO dto, String email) {
        Optional<Recipe> recipeOpt = recipeRepository.findById(id);
        if (recipeOpt.isEmpty()) {
            throw new RuntimeException("Receta no encontrada.");
        }
        Recipe recipe = recipeOpt.get();

        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado.");
        }
        User user = userOpt.get();

        // Solo el autor puede editar su receta
        if (!recipe.getUser().getId().equals(user.getId())) {
            throw new SecurityException("No tienes permiso para editar esta receta.");
        }

        // Actualizar los campos básicos
        recipe.setTitle(dto.getTitle());
        recipe.setDescription(dto.getDescription());
        recipe.setInstructions(dto.getInstructions());
        recipe.setServingsBase(dto.getServingsBase());
        recipe.setIsPublic(dto.getIsPublic() != null ? dto.getIsPublic() : recipe.getIsPublic());
        recipe.setImageUrl(dto.getImageUrl());

        recipeRepository.save(recipe);

        // Eliminar ingredientes antiguos y crear los nuevos
        recipeIngredientRepository.deleteByRecipeId(recipe.getId());

        if (dto.getRecipeIngredients() != null) {
            for (RecipeIngredientDTO ingredientDto : dto.getRecipeIngredients()) {
                String nombre = ingredientDto.getIngredientName().trim().toLowerCase();

                Optional<Ingredient> ingredientOpt = ingredientRepository.findByName(nombre);
                Ingredient ingredient;

                if (ingredientOpt.isEmpty()) {
                    ingredient = ingredientRepository.save(Ingredient.builder().name(nombre).build());
                } else {
                    ingredient = ingredientOpt.get();
                }

                RecipeIngredient ri = RecipeIngredient.builder()
                        .recipe(recipe)
                        .ingredient(ingredient)
                        .quantity(ingredientDto.getQuantity())
                        .unit(ingredientDto.getUnit())
                        .build();

                recipeIngredientRepository.save(ri);
            }
        }

        // Recargar la receta para que incluya los ingredientes nuevos
        Recipe updated = recipeRepository.findById(recipe.getId()).get();
        return toDTO(updated);
    }

    /**
     * Elimina una receta y sus ingredientes asociados.
     * Usa @Transactional porque hace dos borrados: si falla uno, se deshace el otro.
     */
    @Transactional
    public void delete(Long recipeId, String email) {
        Optional<Recipe> optional = recipeRepository.findById(recipeId);
        if (optional.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optional.get();

        // Verificar que el usuario sea el autor (el JWT trae el email)
        if (!recipe.getUser().getEmail().equals(email)) {
            throw new RuntimeException("No tienes permiso para eliminar esta receta");
        }

        // Borrar primero los ingredientes de la receta, luego la receta
        recipeIngredientRepository.deleteByRecipeId(recipeId);
        recipeRepository.delete(recipe);
    }

    /**
     * Busca una receta por ID. Si es privada, solo el autor puede verla.
     */
    public RecipeDTO findById(Long recipeId, String email) {
        Optional<Recipe> optional = recipeRepository.findById(recipeId);
        if (optional.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optional.get();

        // Las recetas privadas solo son visibles para su autor (JWT trae email)
        if (!recipe.getIsPublic() && !recipe.getUser().getEmail().equals(email)) {
            throw new RuntimeException("No tienes acceso a esta receta");
        }
        return toDTO(recipe);
    }

    /**
     * Devuelve todas las recetas de un usuario (públicas y privadas).
     * El parámetro es el email del autenticado (subject del JWT).
     */
    public List<RecipeDTO> findByUser(String email) {
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        List<Recipe> recipes = recipeRepository.findByUserUsername(userOpt.get().getUsername());
        List<RecipeDTO> dtos = new ArrayList<>();
        for (Recipe recipe : recipes) {
            dtos.add(toDTO(recipe));
        }
        return dtos;
    }

    /**
     * Feed público: devuelve recetas públicas paginadas, ordenadas por fecha de creación.
     * Si se pasa una categoría válida, filtra solo recetas de esa categoría.
     */
    public Page<RecipeDTO> findPublic(int page, int size, String categoryParam) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Recipe> recipes;
        if (categoryParam != null && !categoryParam.isBlank()
                && !"TODAS".equalsIgnoreCase(categoryParam)) {
            try {
                Category cat = Category.valueOf(categoryParam.trim().toUpperCase());
                recipes = recipeRepository.findByIsPublicTrueAndCategory(cat, pageable);
            } catch (IllegalArgumentException e) {
                // Categoría desconocida → devolvemos feed sin filtro
                recipes = recipeRepository.findByIsPublicTrue(pageable);
            }
        } else {
            recipes = recipeRepository.findByIsPublicTrue(pageable);
        }
        return recipes.map(recipe -> toDTO(recipe));
    }
}