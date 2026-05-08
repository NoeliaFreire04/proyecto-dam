package com.cookshare.backend.service;

import com.cookshare.backend.entity.InventoryItem;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.InventoryItemRepository;
import com.cookshare.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión del inventario doméstico del usuario.
 * Permite listar, añadir y eliminar productos de la despensa.
 */
@Service
public class InventoryService {

    private final InventoryItemRepository inventoryItemRepository;
    private final UserRepository userRepository;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param inventoryItemRepository repositorio de ítems de inventario
     * @param userRepository repositorio de usuarios
     */
    public InventoryService(InventoryItemRepository inventoryItemRepository,
                            UserRepository userRepository) {
        this.inventoryItemRepository = inventoryItemRepository;
        this.userRepository = userRepository;
    }

    /**
     * Devuelve todos los productos del inventario del usuario.
     *
     * @param username nombre del usuario autenticado
     * @return lista de ítems del inventario
     */
    public List<InventoryItem> getInventory(String username) {
        User user = findUser(username);
        return inventoryItemRepository.findByUserId(user.getId());
    }

    /**
     * Añade un producto al inventario del usuario.
     *
     * @param item ítem a añadir (sin usuario asignado)
     * @param username nombre del usuario autenticado
     * @return el ítem guardado con ID generado
     */
    public InventoryItem addItem(InventoryItem item, String username) {
        User user = findUser(username);
        item.setUser(user);
        return inventoryItemRepository.save(item);
    }

    /**
     * Elimina un producto del inventario verificando que pertenezca al usuario.
     *
     * @param itemId ID del ítem a eliminar
     * @param username nombre del usuario autenticado
     */
    public void deleteItem(Long itemId, String username) {
        User user = findUser(username);

        Optional<InventoryItem> optionalItem = inventoryItemRepository.findById(itemId);
        if (optionalItem.isEmpty()) {
            throw new RuntimeException("Producto no encontrado en el inventario");
        }
        InventoryItem item = optionalItem.get();

        if (!item.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para eliminar este producto");
        }

        inventoryItemRepository.delete(item);
    }

    /**
     * Busca el usuario por email (lo que el filtro JWT pone como principal).
     *
     * @param email email del usuario autenticado
     * @return entidad User correspondiente
     */
    private User findUser(String email) {
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        return optionalUser.get();
    }
}