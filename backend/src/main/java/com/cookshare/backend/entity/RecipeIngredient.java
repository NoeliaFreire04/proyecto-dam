package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Entidad intermedia que representa la relación Many-to-Many
 * entre Recipe e Ingredient.
 * Se mapea a la tabla "recipe_ingredient" en la base de datos MySQL.
 */
@Entity
@Table(name = "recipe_ingredient",
        //Se marcan juntos, ya que no deben duplicarse ingredientes en una receta
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"recipe_id", "ingredient_id"})
        })
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeIngredient {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Receta a la que pertenece este ingrediente.
     * Relación Many-to-One: muchos recipe_ingredients pertenecen a una receta.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    /**
     * Ingrediente del catálogo asociado a esta línea.
     * Relación Many-to-One: muchos recipe_ingredients apuntan al mismo ingrediente.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ingredient_id", nullable = false)
    private Ingredient ingredient;

    /**
     * Cantidad del ingrediente para el número base de comensales.
     * Se usa junto a servingsBase de Recipe para el algoritmo de escalado.
     */
    @NotNull
    @Positive
    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal quantity;

    /**
     * Unidad de medida del ingrediente (g, kg, ml, l, uds, cdta...).
     */
    @NotBlank
    @Column(nullable = false, length = 50)
    private String unit;
}