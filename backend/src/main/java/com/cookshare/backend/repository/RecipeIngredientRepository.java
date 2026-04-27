package com.cookshare.backend.repository;

import com.cookshare.backend.entity.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Repositorio JPA para la entidad RecipeIngredient.
 */
@Repository
public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient,Long> {
    /**Devuelve todos los ingredientes de una receta
     *@param recipeId Id de la receta sobre la que se quiere filtrar
     * @return Lista de ingredientes de una receta*/
    List<RecipeIngredient> findByRecipeId(Long recipeId);

    /** Elimina todos los ingredientes de una receta. */
    @Transactional
    void deleteByRecipeId(Long recipeId);
}
