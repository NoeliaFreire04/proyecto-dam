package com.cookshare.backend.controller;

import com.cookshare.backend.dto.ShoppingListItemDTO;
import com.cookshare.backend.service.ShoppingListService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controlador REST para la lista de la compra.
 * Permite generar la lista desde una receta, añadir ítems
 * manualmente, marcar/desmarcar como comprados, listar,
 * eliminar y limpiar todos los comprados.
 */
@RestController
@RequestMapping("/api/shopping-list")
public class ShoppingListController {

    private final ShoppingListService shoppingListService;

    public ShoppingListController(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    /**
     * Genera la lista de la compra a partir de una receta.
     * Compara ingredientes con el inventario y añade los que faltan.
     */
    @PostMapping("/generate/{recipeId}")
    public ResponseEntity<List<ShoppingListItemDTO>> generateFromRecipe(
            @PathVariable Long recipeId,
            Authentication authentication) {
        String username = authentication.getName();
        List<ShoppingListItemDTO> items =
                shoppingListService.generateFromRecipe(recipeId, username);
        return new ResponseEntity<>(items, HttpStatus.CREATED);
    }

    /**
     * Añade un ítem manualmente a la lista de la compra.
     */
    @PostMapping
    public ResponseEntity<ShoppingListItemDTO> addItem(
            @RequestBody ShoppingListItemDTO item,
            Authentication authentication) {
        String username = authentication.getName();
        ShoppingListItemDTO saved = shoppingListService.addItem(item, username);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    /**
     * Cambia el estado "comprado" de un ítem (toggle).
     */
    @PatchMapping("/{id}/toggle")
    public ResponseEntity<ShoppingListItemDTO> toggle(
            @PathVariable Long id,
            Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(shoppingListService.toggleChecked(id, username));
    }

    /**
     * Elimina un ítem.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id,
            Authentication authentication) {
        String username = authentication.getName();
        shoppingListService.deleteItem(id, username);
        return ResponseEntity.noContent().build();
    }

    /**
     * Elimina todos los ítems marcados como comprados.
     */
    @DeleteMapping("/checked")
    public ResponseEntity<Map<String, Long>> clearChecked(Authentication authentication) {
        String username = authentication.getName();
        long deleted = shoppingListService.clearChecked(username);
        return ResponseEntity.ok(Map.of("deleted", deleted));
    }

    /**
     * Lista todos los ítems del usuario autenticado, más recientes primero.
     */
    @GetMapping
    public ResponseEntity<List<ShoppingListItemDTO>> getList(Authentication authentication) {
        String username = authentication.getName();
        return ResponseEntity.ok(shoppingListService.getList(username));
    }
}
