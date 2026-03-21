package com.cookshare.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa una receta guardada en favoritos por un usuario.
 * Un usuario no puede guardar la misma receta dos veces.
 * Se mapea a la tabla "favorite" en la base de datos.
 */
@Entity
@Table(name = "favorite",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"user_id", "recipe_id"})
        })
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Favorite {

    /** Identificador único autogenerado. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Usuario que guardó la receta en favoritos.
     * Relación Many-to-One: un usuario puede tener muchos favoritos.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Receta guardada en favoritos.
     * Relación Many-to-One: una receta puede estar en favoritos de muchos usuarios.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    /** Fecha y hora en que se guardó la receta en favoritos. */
    @Column(name = "saved_at", updatable = false)
    private LocalDateTime savedAt;

    /**
     * Asigna automáticamente la fecha de guardado
     * antes de persistir la entidad por primera vez.
     */
    @PrePersist
    protected void onCreate() {
        this.savedAt = LocalDateTime.now();
    }
}