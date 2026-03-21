package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa un ítem de la lista de la compra del usuario.
 * Puede generarse automáticamente desde una receta o añadirse manualmente.
 * Se mapea a la tabla "shopping_list_item" en la base de datos MySQL.
 */
@Entity
@Table(name = "shopping_list_item")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShoppingListItem {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario propietario de este ítem de la lista.
     * Relación Many-to-One: un usuario puede tener muchos ítems.
     * Si se elimina el usuario, se eliminan sus ítems (CASCADE).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Nombre del producto a comprar.
     * Se genera a partir del nombre del ingrediente de la receta
     * o se introduce manualmente por el usuario.
     */
    @NotBlank
    @Column(name = "item_name", nullable = false)
    private String itemName;

    /**
     * Cantidad necesaria del producto.
     * Puede ser nulo si se añade manualmente sin especificar cantidad.
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

    /**
     * Indica si el ítem ya ha sido comprado.
     * Por defecto es false al crearse.
     */
    @Column(name = "is_checked", nullable = false)
    @Builder.Default
    private Boolean isChecked = false;

    /** Fecha y hora en que se añadió el ítem a la lista. */
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    /**
     * Asigna automáticamente la fecha de creación
     * antes de persistir la entidad por primera vez.
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}