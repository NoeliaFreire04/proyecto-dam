package com.cookshare.backend.dto;

import com.cookshare.backend.entity.Ingredient;
import com.cookshare.backend.entity.Recipe;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * DTO principal para ingredientes de cada receta.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RecipeIngredientDTO {
    /**
     * Ingrediente del catálogo asociado a esta línea.
     */
    private String ingredientName;

    /**
     * Cantidad del ingrediente para el número base de comensales.
     */
    private BigDecimal quantity;

    /**
     * Unidad de medida del ingrediente (g, kg, ml, l, uds, cdta...).
     */
    private String unit;
}
