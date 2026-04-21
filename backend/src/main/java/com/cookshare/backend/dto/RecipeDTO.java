package com.cookshare.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO principal para recetas.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RecipeDTO {
    /**
     * Id de la receta
     */
    private Long id;

    /** Título de la receta. */
    private String title;

    /** Descripción breve de la receta. */
    private String description;

    /** Pasos de elaboración de la receta. */
    private String instructions;

    /**
     * Número de comensales base para el que está calculada la receta.
     * Se usa para el algoritmo de escalado de ingredientes.
     */
    private Integer servingsBase;

    /** Visibilidad de la receta. */
    private Boolean isPublic;

    /** URL de la imagen de portada de la receta. */
    private String imageUrl;

    /**
     * Nombre del autor.
     */
    private String authorUsername;

    /** Fecha y hora de creación. Se asigna automáticamente. */
    private LocalDateTime createdAt;

    /** Lista de ingredientes de la receta usando RecipeIngredientDTO para evitar exponer la entidad y sus relaciones. */
    private List<RecipeIngredientDTO> recipeIngredients = new ArrayList<>();
}
