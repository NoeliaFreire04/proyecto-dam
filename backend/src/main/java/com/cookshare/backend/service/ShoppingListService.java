package com.cookshare.backend.service;

import com.cookshare.backend.entity.InventoryItem;
import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.RecipeIngredient;
import com.cookshare.backend.entity.ShoppingListItem;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.InventoryItemRepository;
import com.cookshare.backend.repository.RecipeRepository;
import com.cookshare.backend.repository.ShoppingListItemRepository;
import com.cookshare.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión de la lista de la compra.
 * Permite generar la lista automáticamente desde una receta
 * comparando con el inventario, añadir ítems manualmente
 * y marcar productos como comprados.
 */
@Service
public class ShoppingListService {

    private final ShoppingListItemRepository shoppingListItemRepository;
    private final RecipeRepository recipeRepository;
    private final InventoryItemRepository inventoryItemRepository;
    private final UserRepository userRepository;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param shoppingListItemRepository repositorio de ítems de la lista
     * @param recipeRepository repositorio de recetas
     * @param inventoryItemRepository repositorio de inventario
     * @param userRepository repositorio de usuarios
     */
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
     *
     * @param recipeId ID de la receta
     * @param username nombre del usuario autenticado
     * @return lista de ítems generados
     */
    public List<ShoppingListItem> generateFromRecipe(Long recipeId, String username) {
        User user = findUser(username);

        Optional<Recipe> optionalRecipe = recipeRepository.findById(recipeId);
        if (optionalRecipe.isEmpty()) {
            throw new RuntimeException("Receta no encontrada");
        }
        Recipe recipe = optionalRecipe.get();

        // Obtiene los nombres del inventario del usuario en minúsculas para comparar
        List<InventoryItem> inventory = inventoryItemRepository.findByUserId(user.getId());
        List<String> inventoryNames = new ArrayList<>();
        for (InventoryItem inv : inventory) {
            inventoryNames.add(inv.getItemName().toLowerCase());
        }

        // Recorre los ingredientes de la receta y añade los que faltan
        List<ShoppingListItem> generated = new ArrayList<>();
        for (RecipeIngredient ri : recipe.getRecipeIngredients()) {
            String ingredientName = ri.getIngredient().getName().toLowerCase();

            if (!inventoryNames.contains(ingredientName)) {
                ShoppingListItem item = ShoppingListItem.builder()
                        .user(user)
                        .itemName(ri.getIngredient().getName())
                        .quantity(ri.getQuantity().doubleValue())
                        .unit(ri.getUnit())
                        .build();
                generated.add(shoppingListItemRepository.save(item));
            }
        }

        return generated;
    }

    /**
     * Añade un ítem manualmente a la lista de la compra.
     *
     * @param item ítem a añadir (sin usuario asignado)
     * @param username nombre del usuario autenticado
     * @return el ítem guardado
     */
    public ShoppingListItem addItem(ShoppingListItem item, String username) {
        User user = findUser(username);
        item.setUser(user);
        return shoppingListItemRepository.save(item);
    }

    /**
     * Marca un ítem de la lista como comprado.
     * Al marcarlo, no se borra — simplemente deja de mostrarse en la lista activa.
     *
     * @param itemId ID del ítem a marcar
     * @param username nombre del usuario autenticado
     * @return el ítem actualizado
     */
    public ShoppingListItem checkItem(Long itemId, String username) {
        User user = findUser(username);

        Optional<ShoppingListItem> optionalItem = shoppingListItemRepository.findById(itemId);
        if (optionalItem.isEmpty()) {
            throw new RuntimeException("Ítem no encontrado en la lista de la compra");
        }
        ShoppingListItem item = optionalItem.get();

        if (!item.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("No tienes permiso para modificar este ítem");
        }

        item.setIsChecked(true);
        return shoppingListItemRepository.save(item);
    }

    /**
     * Devuelve todos los ítems de la lista de la compra del usuario.
     *
     * @param username nombre del usuario autenticado
     * @return lista de ítems
     */
    public List<ShoppingListItem> getList(String username) {
        User user = findUser(username);
        return shoppingListItemRepository.findByUserId(user.getId());
    }

    // Busca el usuario por username o lanza excepción
    private User findUser(String username) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        return optionalUser.get();
    }
}