package com.cookshare.backend.controller;

import com.cookshare.backend.entity.ShoppingListItem;
import com.cookshare.backend.service.ShoppingListService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la lista de la compra.
 * Permite generar la lista desde una receta, añadir ítems
 * manualmente, marcar como comprados y listar todos los ítems.
 */
@RestController
@RequestMapping("/api/shopping-list")
public class ShoppingListController {

    private final ShoppingListService shoppingListService;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param shoppingListService servicio de lista de la compra
     */
    public ShoppingListController(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    /**
     * Genera la lista de la compra a partir de una receta.
     * Compara ingredientes con el inventario y añade los que faltan.
     *
     * @param recipeId ID de la receta
     * @param authentication usuario autenticado
     * @return lista de ítems generados con código 201
     */
    @PostMapping("/generate/{recipeId}")
    public ResponseEntity<List<ShoppingListItem>> generateFromRecipe(
            @PathVariable Long recipeId,
            Authentication authentication) {
        String username = authentication.getName();
        List<ShoppingListItem> items = shoppingListService.generateFromRecipe(recipeId, username);
        return new ResponseEntity<>(items, HttpStatus.CREATED);
    }

    /**
     * Añade un ítem manualmente a la lista de la compra.
     *
     * @param item datos del ítem a añadir
     * @param authentication usuario autenticado
     * @return el ítem añadido con código 201
     */
    @PostMapping
    public ResponseEntity<ShoppingListItem> addItem(@RequestBody ShoppingListItem item,
                                                    Authentication authentication) {
        String username = authentication.getName();
        ShoppingListItem saved = shoppingListService.addItem(item, username);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    /**
     * Marca un ítem como comprado.
     *
     * @param id ID del ítem a marcar
     * @param authentication usuario autenticado
     * @return el ítem actualizado
     */
    @PatchMapping("/{id}")
    public ResponseEntity<ShoppingListItem> checkItem(@PathVariable Long id,
                                                      Authentication authentication) {
        String username = authentication.getName();
        ShoppingListItem updated = shoppingListService.checkItem(id, username);
        return ResponseEntity.ok(updated);
    }

    /**
     * Lista todos los ítems de la lista de la compra del usuario.
     *
     * @param authentication usuario autenticado
     * @return lista de ítems
     */
    @GetMapping
    public ResponseEntity<List<ShoppingListItem>> getList(Authentication authentication) {
        String username = authentication.getName();
        List<ShoppingListItem> items = shoppingListService.getList(username);
        return ResponseEntity.ok(items);
    }
}