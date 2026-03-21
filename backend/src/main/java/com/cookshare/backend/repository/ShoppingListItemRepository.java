package com.cookshare.backend.repository;

import com.cookshare.backend.entity.ShoppingListItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio JPA para la entidad ShoppingListItemRepository.
 */
@Repository
public interface ShoppingListItemRepository extends JpaRepository<ShoppingListItem,Long> {
    /**Devuelve todos los items de un usuario
     *@param userId Id del usuario sobre el que se quiere filtrar
     * @return Lista de items de un usuario*/
    List<ShoppingListItem> findByUserId(Long userId);
}
