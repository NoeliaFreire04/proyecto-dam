package com.cookshare.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO para los ítems de la lista de la compra.
 * Se utiliza tanto para entrada (alta de un ítem) como para salida (listado).
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ShoppingListItemDTO {

    /** Identificador único del ítem. */
    private Long id;

    /** Nombre del producto a comprar. */
    private String itemName;

    /** Cantidad necesaria del producto. */
    private Double quantity;

    /** Unidad de medida del producto (g, kg, ml, l, uds...). */
    private String unit;

    /** Indica si el ítem ya ha sido comprado. */
    private Boolean isChecked;

    /** Emoji asociado al producto (1-4 chars). Nullable. */
    private String emoji;

    /** Fecha y hora en que se añadió el ítem. */
    private LocalDateTime createdAt;
}
