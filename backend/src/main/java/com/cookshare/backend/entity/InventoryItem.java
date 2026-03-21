package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Entidad que representa un producto disponible en el inventario
 * doméstico del usuario. El usuario lo gestiona manualmente.
 * Se mapea a la tabla "inventory_item" en la base de datos.
 */
@Entity
@Table(name = "inventory_item")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryItem {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario propietario de este ítem de inventario.
     * Relación Many-to-One: un usuario puede tener muchos ítems.
     * Si se elimina el usuario, se eliminan sus ítems (CASCADE).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Nombre del producto en el inventario.
     * Se normaliza a minúsculas para facilitar la comparación
     * con los ingredientes de las recetas al generar la lista de la compra.
     */
    @NotBlank
    @Column(name = "item_name", nullable = false)
    private String itemName;

    /**
     * Cantidad disponible del producto.
     * Puede ser nulo si el usuario solo indica que tiene el producto
     * sin especificar cantidad.
     */
    @Positive
    @Column
    private Double quantity;

    /**
     * Unidad de medida del producto (g, kg, ml, l, uds...).
     * Puede ser nulo si no se especifica cantidad.
     */
    @Column(length = 50)
    private String unit;
}