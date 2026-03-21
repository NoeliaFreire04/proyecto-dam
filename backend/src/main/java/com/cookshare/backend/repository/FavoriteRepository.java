package com.cookshare.backend.repository;

import com.cookshare.backend.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio JPA para la entidad Favorite.
 */
@Repository
public interface FavoriteRepository extends JpaRepository<Favorite,Long> {
    /**Elimina un favorito de la lista de un usuario concreto
     *@param recipeId Id de la receta a eliminar
     *@param userId Id del usuario con la receta guardada */
    void deleteByUserIdAndRecipeId(Long userId, Long recipeId);

    /**Busca si una receta ya existe en la lista de un usario
     *@param recipeId Id de la receta a buscar
     *@param userId Id del usuario con la receta guardada
     *@return boolean según su existencia*/
    boolean existsByRecipeIdAndUserId(Long recipeId, Long userId);
}
