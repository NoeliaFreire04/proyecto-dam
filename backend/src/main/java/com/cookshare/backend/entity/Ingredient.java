package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Entidad que representa un ingrediente del catálogo global.
 * Los ingredientes son compartidos entre recetas — no pertenecen
 * a un usuario concreto sino al catálogo general de la aplicación.
 * Se mapea a la tabla "ingredient" en la base de datos.
 */
@Entity
@Table(name = "ingredient",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = "name")
        })
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Ingredient {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Nombre del ingrediente. Único en el catálogo.
     * Se normaliza a minúsculas antes de guardar para evitar duplicados.
     */
    @NotBlank
    @Column(nullable = false, unique = true, length = 150)
    private String name;

    /**
     * Recetas en las que aparece este ingrediente.
     * Relación One-to-Many con RecipeIngredient.
     * No se elimina en cascada — el ingrediente pertenece al catálogo global.
     */
    @OneToMany(mappedBy = "ingredient")
    @Builder.Default
    private List<RecipeIngredient> recipeIngredients = new ArrayList<>();
}