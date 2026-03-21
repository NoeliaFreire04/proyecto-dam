package com.cookshare.backend.repository;

import com.cookshare.backend.entity.Ingredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio JPA para la entidad Ingredient.
 */
@Repository
public interface IngredientRepository extends JpaRepository<Ingredient,Long> {
    /**Busca si un ingrediente existe en el catalogo
     *@param name Nombre del ingrediente a buscar
     *@return Opcional de ingrediente si existe*/
    Optional<Ingredient> findByName(String name);
}
