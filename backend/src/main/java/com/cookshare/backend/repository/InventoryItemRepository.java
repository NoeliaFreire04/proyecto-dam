package com.cookshare.backend.repository;

import com.cookshare.backend.entity.InventoryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio JPA para la entidad InventoryItem.
 */
@Repository
public interface InventoryItemRepository extends JpaRepository<InventoryItem,Long> {
    /**Devuelve todos los items del inventario un usuario
     *@param userId Id del usuario sobre el que se quiere filtrar
     * @return Lista de items de un usuario*/
    List<InventoryItem> findByUserId(Long userId);
}
