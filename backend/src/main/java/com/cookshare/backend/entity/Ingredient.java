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
     * Indica si el ingrediente ha sido introducido por un usuario y
     * todavía no ha sido validado por un administrador del catálogo.
     * Los ingredientes pendientes de revisión pueden aparecer en recetas
     * pero no se exportan al catálogo oficial hasta su aprobación.
     * La columna es nullable para que MySQL pueda añadirla sin problemas
     * a una tabla con filas existentes cuando ddl-auto=update.
     */
    @Builder.Default
    @Column(name = "pendiente_revision")
    private Boolean pendienteRevision = true;

    /**
     * Recetas en las que aparece este ingrediente.
     * Relación One-to-Many con RecipeIngredient.
     * No se elimina en cascada — el ingrediente pertenece al catálogo global.
     */
    @OneToMany(mappedBy = "ingredient")
    @Builder.Default
    private List<RecipeIngredient> recipeIngredients = new ArrayList<>();
}