package com.cookshare.backend.controller;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.service.GeminiService;
import com.cookshare.backend.service.RecipeService;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Controlador REST para la gestión de recetas.
 * Maneja los endpoints de creación, edición, eliminación,
 * consulta individual, listado del usuario y feed público.
 */
@RestController
@RequestMapping("/api/recipes")
public class RecipeController {

    private final RecipeService recipeService;
    private final GeminiService geminiService;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param recipeService servicio de recetas
     * @param geminiService servicio de integración con Gemini
     */
    public RecipeController(RecipeService recipeService,  GeminiService geminiService) {
        this.recipeService = recipeService;
        this.geminiService = geminiService;
    }

    /**
     * Crea una nueva receta (CU-03).
     *
     * @param recipeDTO datos de la receta a crear
     * @param authentication usuario autenticado
     * @return la receta creada con código 201
     */
    @PostMapping
    public ResponseEntity<RecipeDTO> create(@RequestBody RecipeDTO recipeDTO,
                                            Authentication authentication) {
        String username = authentication.getName();
        RecipeDTO created = recipeService.create(recipeDTO, username);
        return new ResponseEntity<>(created, HttpStatus.CREATED);
    }

    /**
     * Obtiene el detalle de una receta por ID.
     * Si es privada, solo el autor puede verla.
     *
     * @param id ID de la receta
     * @param authentication usuario autenticado
     * @return la receta encontrada
     */
    @GetMapping("/{id}")
    public ResponseEntity<RecipeDTO> findById(@PathVariable Long id,
                                              Authentication authentication) {
        String username = authentication.getName();
        RecipeDTO recipe = recipeService.findById(id, username);
        return ResponseEntity.ok(recipe);
    }

    /**
     * Actualiza una receta existente (CU-04).
     *
     * @param id ID de la receta a actualizar
     * @param recipeDTO nuevos datos de la receta
     * @param authentication usuario autenticado
     * @return la receta actualizada
     */
    @PutMapping("/{id}")
    public ResponseEntity<RecipeDTO> update(@PathVariable Long id,
                                            @RequestBody RecipeDTO recipeDTO,
                                            Authentication authentication) {
        String username = authentication.getName();
        RecipeDTO updated = recipeService.update(id, recipeDTO, username);
        return ResponseEntity.ok(updated);
    }

    /**
     * Elimina una receta propia (CU-05).
     *
     * @param id ID de la receta a eliminar
     * @param authentication usuario autenticado
     * @return respuesta vacía con código 204
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id,
                                       Authentication authentication) {
        String username = authentication.getName();
        recipeService.delete(id, username);
        return ResponseEntity.noContent().build();
    }

    /**
     * Lista todas las recetas del usuario autenticado.
     *
     * @param authentication usuario autenticado
     * @return lista de recetas del usuario
     */
    @GetMapping("/mine")
    public ResponseEntity<List<RecipeDTO>> findByUser(Authentication authentication) {
        String username = authentication.getName();
        List<RecipeDTO> recipes = recipeService.findByUser(username);
        return ResponseEntity.ok(recipes);
    }

    /**
     * Feed público de recetas paginado.
     * Devuelve recetas públicas ordenadas por fecha de creación descendente.
     *
     * @param page número de página (por defecto 0)
     * @param size tamaño de página (por defecto 10)
     * @return página de recetas públicas
     */
    @GetMapping("/feed")
    public ResponseEntity<Page<RecipeDTO>> findPublic(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<RecipeDTO> recipes = recipeService.findPublic(page, size);
        return ResponseEntity.ok(recipes);
    }

    /**
     * Crea una receta a partir de un vídeo usando Google Gemini.
     * El vídeo se envía como multipart y Gemini extrae título,
     * descripción, instrucciones e ingredientes automáticamente.
     * La receta se guarda como privada del usuario autenticado.
     *
     * @param video archivo de vídeo subido
     * @param authentication usuario autenticado
     * @return la receta creada con código 201
     */
    @PostMapping(value = "/from-video", consumes = "multipart/form-data")
    public ResponseEntity<RecipeDTO> createFromVideo(
            @RequestParam("video") MultipartFile video,
            Authentication authentication) {
        try {
            String username = authentication.getName();
            RecipeDTO extracted = geminiService.extractRecipeFromVideo(video);
            RecipeDTO created = recipeService.create(extracted, username);
            return new ResponseEntity<>(created, HttpStatus.CREATED);
        } catch (Exception e) {
            throw new RuntimeException("Error al procesar el vídeo: " + e.getMessage());
        }
    }
}