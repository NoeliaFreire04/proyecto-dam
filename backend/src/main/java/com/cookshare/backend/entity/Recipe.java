package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entidad que representa una receta.
 * Se mapea a la tabla "recipe" en la base de datos MySQL.
 */
@Entity
@Table(name = "recipe")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Recipe {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario propietario de la receta.
     * Relación Many-to-One: muchas recetas pertenecen a un usuario.
     * Si se elimina el usuario, se eliminan sus recetas (CASCADE).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Título de la receta. */
    @NotBlank
    @Column(nullable = false, length = 200)
    private String title;

    /** Descripción breve de la receta. */
    @Column(columnDefinition = "TEXT")
    private String description;

    /** Pasos de elaboración de la receta. */
    @Column(columnDefinition = "LONGTEXT")
    private String instructions;

    /**
     * Número de comensales base para el que está calculada la receta.
     * Se usa para el algoritmo de escalado de ingredientes.
     */
    @NotNull
    @Positive
    @Column(name = "servings_base", nullable = false)
    private Integer servingsBase;

    /**
     * Indica si la receta es visible en el feed público.
     * Por defecto es privada (false).
     */
    @Column(name = "is_public", nullable = false)
    @Builder.Default
    private Boolean isPublic = false;

    /** URL de la imagen de portada de la receta. Puede ser nulo. */
    @Column(name = "image_url")
    private String imageUrl;

    /** Fecha y hora de creación. Se asigna automáticamente. */
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    /**
     * Lista de ingredientes de la receta.
     * Relación One-to-Many con RecipeIngredient.
     * Se eliminan en cascada si se elimina la receta.
     */
    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RecipeIngredient> recipeIngredients = new ArrayList<>();

    /**
     * Asigna automáticamente la fecha de creación
     * antes de persistir la entidad por primera vez.
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}