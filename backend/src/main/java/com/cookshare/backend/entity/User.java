package com.cookshare.backend.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Entidad que representa a un usuario registrado en CookShare.
 * Se mapea a la tabla "user" en la base de datos.
 */
@Entity
@Table(name = "user",
        uniqueConstraints = {
            @UniqueConstraint(columnNames = "email"),
                @UniqueConstraint(columnNames = "username")
        })
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class User {
    /** Identificador único autogenerado*/
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Nombre de usuario único visible en la plataforma. */
    @NotBlank
    @Size(min = 3, max = 50)
    @Column(nullable = false, unique = true,length = 50)
    private String username;

    /** Correo electrónico único usado para autenticación. */
    @NotBlank
    @Email
    @Column(nullable = false, unique = true,length = 255)
    private String email;

    /** Contraseña almacenada con hash BCrypt. Nunca en texto plano. */
    @NotBlank
    @Column(nullable = false)
    private String password;

    /** URL de la imagen de perfil del usuario. Puede ser nulo. */
    @Column(name = "profile_picture")
    private String profilePicture;

    /** Fecha y hora de registro. Se asigna automáticamente. */
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
