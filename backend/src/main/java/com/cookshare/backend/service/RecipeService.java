package com.cookshare.backend.service;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.dto.RecipeIngredientDTO;
import com.cookshare.backend.entity.Ingredient;
import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.RecipeIngredient;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.IngredientRepository;
import com.cookshare.backend.repository.RecipeIngredientRepository;
import com.cookshare.backend.repository.RecipeRepository;
import com.cookshare.backend.repository.UserRepository;
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
     */
    public RecipeDTO create(RecipeDTO dto, String email){
        // Buscar el usuario por email
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty()){
            throw new RuntimeException("Usuario no encontrado.");
        }

        User user = userOpt.get();

        // Construir y guardar la receta
        Recipe recipe = Recipe.builder().user(user).description(dto.getDescription()).title(dto.getTitle()).imageUrl(dto.getImageUrl()).instructions(dto.getInstructions()).servingsBase(dto.getServingsBase()).isPublic(dto.getIsPublic()).build();
        Recipe recipeSave = recipeRepository.save(recipe);

        // Procesar los ingredientes si vienen en el DTO
        if (dto.getRecipeIngredients() != null){
            for (RecipeIngredientDTO ingredientDto : dto.getRecipeIngredients()){
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

                BigDecimal quantity = ingredientDto.getQuantity();
                String unit = ingredientDto.getUnit();

                // Crear la relación receta-ingrediente
                RecipeIngredient ri = RecipeIngredient.builder().recipe(recipeSave).ingredient(ingredient).quantity(quantity).unit(unit).build();

                recipeIngredientRepository.save(ri);
            }
        }

        return toDTO(recipeSave);
    }

    /**
     * Convierte una entidad Recipe a DTO para no exponer entidades JPA en las respuestas.
     */
    private RecipeDTO toDTO(Recipe recipe){
        // Mapear cada RecipeIngredient a su DTO
        List<RecipeIngredientDTO> ingredientDTOs = new ArrayList<>();
        for (RecipeIngredient ri : recipe.getRecipeIngredients()) {
            RecipeIngredientDTO ingDTO = RecipeIngredientDTO.builder()
                    .ingredientName(ri.getIngredient().getName())
                    .quantity(ri.getQuantity())
                    .unit(ri.getUnit())
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
    public void delete(Long recipeId, String username) {
        Optional<Recipe> optional = recipeRepository.findById(recipeId);
        if (optional.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optional.get();

        // Verificar que el usuario sea el autor
        if (!recipe.getUser().getUsername().equals(username)) {
            throw new RuntimeException("No tienes permiso para eliminar esta receta");
        }

        // Borrar primero los ingredientes de la receta, luego la receta
        recipeIngredientRepository.deleteByRecipeId(recipeId);
        recipeRepository.delete(recipe);
    }

    /**
     * Busca una receta por ID. Si es privada, solo el autor puede verla.
     */
    public RecipeDTO findById(Long recipeId, String username) {
        Optional<Recipe> optional = recipeRepository.findById(recipeId);
        if (optional.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optional.get();

        // Las recetas privadas solo son visibles para su autor
        if (!recipe.getIsPublic() && !recipe.getUser().getUsername().equals(username)) {
            throw new RuntimeException("No tienes acceso a esta receta");
        }
        return toDTO(recipe);
    }

    /**
     * Devuelve todas las recetas de un usuario (públicas y privadas).
     */
    public List<RecipeDTO> findByUser(String username) {
        List<Recipe> recipes = recipeRepository.findByAuthorUsername(username);
        List<RecipeDTO> dtos = new ArrayList<>();
        for (Recipe recipe : recipes) {
            dtos.add(toDTO(recipe));
        }
        return dtos;
    }

    /**
     * Feed público: devuelve recetas públicas paginadas, ordenadas por fecha de creación.
     */
    public Page<RecipeDTO> findPublic(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Recipe> recipes = recipeRepository.findByIsPublicTrue(pageable);
        return recipes.map(recipe -> toDTO(recipe));
    }
}