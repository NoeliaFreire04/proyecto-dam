package com.cookshare.backend.service;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.entity.Favorite;
import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.FavoriteRepository;
import com.cookshare.backend.repository.RecipeRepository;
import com.cookshare.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión de recetas favoritas.
 * Permite guardar, eliminar y listar las recetas favoritas de un usuario.
 */
@Service
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final RecipeRepository recipeRepository;
    private final UserRepository userRepository;
    private final RecipeService recipeService;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param favoriteRepository repositorio de favoritos
     * @param recipeRepository repositorio de recetas
     * @param userRepository repositorio de usuarios
     * @param recipeService servicio de recetas (para reutilizar toDTO)
     */
    public FavoriteService(FavoriteRepository favoriteRepository,
                           RecipeRepository recipeRepository,
                           UserRepository userRepository,
                           RecipeService recipeService) {
        this.favoriteRepository = favoriteRepository;
        this.recipeRepository = recipeRepository;
        this.userRepository = userRepository;
        this.recipeService = recipeService;
    }

    /**
     * Guarda una receta en favoritos del usuario (CU-10).
     * Comprueba que la receta exista y que no esté ya guardada.
     *
     * @param recipeId ID de la receta a guardar
     * @param username nombre del usuario autenticado
     */
    public void addFavorite(Long recipeId, String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        User user = optionalUser.get();

        Optional<Recipe> optionalRecipe = recipeRepository.findById(recipeId);
        if (optionalRecipe.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optionalRecipe.get();

        if (favoriteRepository.existsByRecipeIdAndUserId(recipeId, user.getId())) {
            throw new RuntimeException("La receta ya está en favoritos");
        }

        Favorite favorite = Favorite.builder()
                .user(user)
                .recipe(recipe)
                .build();

        favoriteRepository.save(favorite);
    }

    /**
     * Elimina una receta de favoritos del usuario (CU-11).
     *
     * @param recipeId ID de la receta a eliminar de favoritos
     * @param username nombre del usuario autenticado
     */
    @Transactional
    public void removeFavorite(Long recipeId, String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        User user = optionalUser.get();

        favoriteRepository.deleteByUserIdAndRecipeId(user.getId(), recipeId);
    }

    /**
     * Lista todas las recetas favoritas del usuario.
     *
     * @param username nombre del usuario autenticado
     * @return lista de RecipeDTO de sus favoritos
     */
    public List<RecipeDTO> getFavorites(String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        User user = optionalUser.get();

        List<Favorite> favorites = favoriteRepository.findByUserId(user.getId());
        List<RecipeDTO> result = new ArrayList<>();
        for (Favorite fav : favorites) {
            result.add(recipeService.toDTO(fav.getRecipe()));
        }
        return result;
    }
}