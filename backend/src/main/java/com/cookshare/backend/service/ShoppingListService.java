package com.cookshare.backend.service;

import com.cookshare.backend.dto.ShoppingListItemDTO;
import com.cookshare.backend.entity.InventoryItem;
import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.RecipeIngredient;
import com.cookshare.backend.entity.ShoppingListItem;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.InventoryItemRepository;
import com.cookshare.backend.repository.RecipeRepository;
import com.cookshare.backend.repository.ShoppingListItemRepository;
import com.cookshare.backend.repository.UserRepository;
import com.cookshare.backend.util.UnitNormalizer;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión de la lista de la compra.
 * Permite generar la lista automáticamente desde una receta
 * comparando con el inventario, añadir ítems manualmente,
 * marcar productos como comprados, eliminar y limpiar.
 */
@Service
public class ShoppingListService {

    private final ShoppingListItemRepository shoppingListItemRepository;
    private final RecipeRepository recipeRepository;
    private final InventoryItemRepository inventoryItemRepository;
    private final UserRepository userRepository;

    public ShoppingListService(ShoppingListItemRepository shoppingListItemRepository,
                               RecipeRepository recipeRepository,
                               InventoryItemRepository inventoryItemRepository,
                               UserRepository userRepository) {
        this.shoppingListItemRepository = shoppingListItemRepository;
        this.recipeRepository = recipeRepository;
        this.inventoryItemRepository = inventoryItemRepository;
        this.userRepository = userRepository;
    }

    /**
     * Genera la lista de la compra a partir de una receta.
     * Compara los ingredientes de la receta con el inventario del usuario
     * y añade a la lista solo los que no tiene en la despensa.
     */
    public List<ShoppingListItemDTO> generateFromRecipe(Long recipeId, String username) {
        User user = findUser(username);

        Optional<Recipe> optionalRecipe = recipeRepository.findById(recipeId);
        if (optionalRecipe.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optionalRecipe.get();

        // Obtiene los nombres del inventario del usuario para comparar.
        // Normalizamos a minúsculas para comparar sin distinguir mayúsculas.
        List<InventoryItem> inventory = inventoryItemRepository.findByUserId(user.getId());
        List<String> inventoryNames = new ArrayList<>();
        for (InventoryItem inv : inventory) {
            if (inv.getItemName() != null) {
                inventoryNames.add(inv.getItemName().toLowerCase().trim());
            }
        }

        // Obtenemos los items YA existentes en la lista de la compra del
        // usuario para no duplicar — si ya está, sumamos la cantidad.
        List<ShoppingListItem> existing =
                shoppingListItemRepository.findByUserIdOrderByCreatedAtDesc(user.getId());

        // Recorre los ingredientes de la receta y añade los que faltan
        List<ShoppingListItemDTO> generated = new ArrayList<>();
        for (RecipeIngredient ri : recipe.getRecipeIngredients()) {
            String ingredientName = ri.getIngredient().getName().toLowerCase().trim();

            // Comparación flexible con la despensa:
            //  - Coincidencia exacta: "tomate" == "tomate"
            //  - Plural/singular: si uno contiene al otro
            //  - Compuestos: "tomate cherry" cubre "tomate"
            // Así evitamos añadir a la lista lo que el usuario YA tiene.
            boolean inPantry = false;
            for (String invName : inventoryNames) {
                if (invName.equals(ingredientName)
                        || invName.contains(ingredientName)
                        || ingredientName.contains(invName)) {
                    inPantry = true;
                    break;
                }
            }
            if (inPantry) {
                continue;
            }

            BigDecimal qty = ri.getQuantity();
            Double qtyDouble = qty != null ? qty.doubleValue() : null;
            String unit = ri.getUnit();

            // ¿Ya hay un item en la lista con el mismo nombre y misma unidad?
            // Si sí, sumamos cantidades y desmarcamos como comprado.
            ShoppingListItem match = null;
            for (ShoppingListItem it : existing) {
                if (it.getItemName() != null
                        && it.getItemName().equalsIgnoreCase(ri.getIngredient().getName())
                        && ((unit == null && it.getUnit() == null)
                            || (unit != null && unit.equalsIgnoreCase(it.getUnit())))) {
                    match = it;
                    break;
                }
            }

            if (match != null) {
                Double current = match.getQuantity();
                if (current != null && qtyDouble != null) {
                    match.setQuantity(current + qtyDouble);
                } else if (qtyDouble != null) {
                    match.setQuantity(qtyDouble);
                }
                match.setIsChecked(false);
                generated.add(toDTO(shoppingListItemRepository.save(match)));
            } else {
                ShoppingListItem item = ShoppingListItem.builder()
                        .user(user)
                        .itemName(ri.getIngredient().getName())
                        .quantity(qtyDouble)
                        .unit(unit)
                        .isChecked(false)
                        .build();
                ShoppingListItem saved = shoppingListItemRepository.save(item);
                existing.add(saved);
                generated.add(toDTO(saved));
            }
        }

        return generated;
    }

    /**
     * Añade un ítem manualmente a la lista de la compra.
     */
    public ShoppingListItemDTO addItem(ShoppingListItemDTO dto, String username) {
        User user = findUser(username);
        if (dto.getItemName() == null || dto.getItemName().isBlank()) {
            throw new RuntimeException("El nombre del ítem es obligatorio");
        }

        ShoppingListItem item = ShoppingListItem.builder()
                .user(user)
                .itemName(dto.getItemName().trim())
                .quantity(dto.getQuantity())
                .unit(UnitNormalizer.normalize(dto.getUnit()))
                .isChecked(Boolean.TRUE.equals(dto.getIsChecked()))
                .emoji(dto.getEmoji())
                .build();
        return toDTO(shoppingListItemRepository.save(item));
    }

    /**
     * Cambia el estado "comprado" de un ítem (toggle).
     */
    public ShoppingListItemDTO toggleChecked(Long itemId, String username) {
        User user = findUser(username);
        Optional<ShoppingListItem> optionalItem = shoppingListItemRepository.findById(itemId);
        if (optionalItem.isEmpty()) {
            throw new RuntimeException("Ítem no encontrado en la lista de la compra");
        }
        ShoppingListItem item = optionalItem.get();

        if (!item.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para modificar este ítem");
        }
        item.setIsChecked(!Boolean.TRUE.equals(item.getIsChecked()));
        return toDTO(shoppingListItemRepository.save(item));
    }

    /**
     * Elimina un ítem concreto.
     */
    public void deleteItem(Long itemId, String username) {
        User user = findUser(username);
        Optional<ShoppingListItem> optionalDelete = shoppingListItemRepository.findById(itemId);
        if (optionalDelete.isEmpty()) {
            throw new RuntimeException("Ítem no encontrado");
        }
        ShoppingListItem item = optionalDelete.get();
        if (!item.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para eliminar este ítem");
        }
        shoppingListItemRepository.delete(item);
    }

    /**
     * Elimina todos los ítems marcados como comprados.
     * @return número de ítems eliminados.
     */
    @Transactional
    public long clearChecked(String username) {
        User user = findUser(username);
        return shoppingListItemRepository.deleteByUserIdAndIsCheckedTrue(user.getId());
    }

    /**
     * Devuelve todos los ítems de la lista de la compra del usuario,
     * ordenados por fecha de creación descendente.
     */
    public List<ShoppingListItemDTO> getList(String username) {
        User user = findUser(username);
        return shoppingListItemRepository.findByUserIdOrderByCreatedAtDesc(user.getId())
                .stream()
                .map(this::toDTO)
                .toList();
    }

    /** Convierte la entidad a DTO. Normaliza unidad por si viene legacy. */
    public ShoppingListItemDTO toDTO(ShoppingListItem item) {
        return ShoppingListItemDTO.builder()
                .id(item.getId())
                .itemName(item.getItemName())
                .quantity(item.getQuantity())
                .unit(UnitNormalizer.normalize(item.getUnit()))
                .isChecked(item.getIsChecked())
                .emoji(item.getEmoji())
                .createdAt(item.getCreatedAt())
                .build();
    }

    /**
     * Busca el usuario autenticado por su email (lo que viene en el JWT
     * a través de authentication.getName()).
     */
    private User findUser(String email) {
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        return optionalUser.get();
    }
}
