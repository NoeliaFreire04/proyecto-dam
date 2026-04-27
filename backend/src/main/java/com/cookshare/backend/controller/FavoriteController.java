package com.cookshare.backend.controller;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.service.FavoriteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión de favoritos.
 * Permite guardar, eliminar y listar recetas favoritas.
 */
@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param favoriteService servicio de favoritos
     */
    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /**
     * Guarda una receta en favoritos (CU-10).
     *
     * @param recipeId ID de la receta a guardar
     * @param authentication usuario autenticado
     * @return respuesta con código 201
     */
    @PostMapping("/{recipeId}")
    public ResponseEntity<Void> addFavorite(@PathVariable Long recipeId,
                                            Authentication authentication) {
        String username = authentication.getName();
        favoriteService.addFavorite(recipeId, username);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    /**
     * Elimina una receta de favoritos (CU-11).
     *
     * @param recipeId ID de la receta a eliminar
     * @param authentication usuario autenticado
     * @return respuesta vacía con código 204
     */
    @DeleteMapping("/{recipeId}")
    public ResponseEntity<Void> removeFavorite(@PathVariable Long recipeId,
                                               Authentication authentication) {
        String username = authentication.getName();
        favoriteService.removeFavorite(recipeId, username);
        return ResponseEntity.noContent().build();
    }

    /**
     * Lista las recetas favoritas del usuario autenticado.
     *
     * @param authentication usuario autenticado
     * @return lista de recetas favoritas
     */
    @GetMapping
    public ResponseEntity<List<RecipeDTO>> getFavorites(Authentication authentication) {
        String username = authentication.getName();
        List<RecipeDTO> favorites = favoriteService.getFavorites(username);
        return ResponseEntity.ok(favorites);
    }
}