package com.cookshare.backend.repository;

import com.cookshare.backend.entity.ShoppingListItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio JPA para la entidad ShoppingListItem.
 */
@Repository
public interface ShoppingListItemRepository extends JpaRepository<ShoppingListItem,Long> {
    /**Devuelve todos los items de un usuario, ordenados por fecha de creación descendente.
     *@param userId Id del usuario sobre el que se quiere filtrar
     * @return Lista de items de un usuario*/
    List<ShoppingListItem> findByUserIdOrderByCreatedAtDesc(Long userId);

    /** Mantenemos la versión sin orden por compatibilidad. */
    List<ShoppingListItem> findByUserId(Long userId);

    /** Elimina todos los items marcados como comprados de un usuario. */
    long deleteByUserIdAndIsCheckedTrue(Long userId);
}
