package com.cookshare.backend.controller;

import com.cookshare.backend.entity.InventoryItem;
import com.cookshare.backend.service.InventoryService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión del inventario doméstico.
 * Permite listar, añadir y eliminar productos de la despensa del usuario.
 */
@RestController
@RequestMapping("/api/inventory")
public class InventoryController {

    private final InventoryService inventoryService;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param inventoryService servicio de inventario
     */
    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    /**
     * Lista todos los productos del inventario del usuario.
     *
     * @param authentication usuario autenticado
     * @return lista de ítems del inventario
     */
    @GetMapping
    public ResponseEntity<List<InventoryItem>> getInventory(Authentication authentication) {
        String username = authentication.getName();
        List<InventoryItem> items = inventoryService.getInventory(username);
        return ResponseEntity.ok(items);
    }

    /**
     * Añade un producto al inventario del usuario.
     *
     * @param item datos del producto a añadir
     * @param authentication usuario autenticado
     * @return el producto añadido con código 201
     */
    @PostMapping
    public ResponseEntity<InventoryItem> addItem(@RequestBody InventoryItem item,
                                                 Authentication authentication) {
        String username = authentication.getName();
        InventoryItem saved = inventoryService.addItem(item, username);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    /**
     * Elimina un producto del inventario del usuario.
     *
     * @param id ID del producto a eliminar
     * @param authentication usuario autenticado
     * @return respuesta vacía con código 204
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id,
                                           Authentication authentication) {
        String username = authentication.getName();
        inventoryService.deleteItem(id, username);
        return ResponseEntity.noContent().build();
    }
}