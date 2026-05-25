package com.cookshare.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO público del perfil del usuario.
 * NO incluye la contraseña — nunca debe salir de la BD al cliente.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserProfileDTO {
    private Long id;
    private String username;
    private String email;
    /** URL de la imagen de perfil. Nullable. */
    private String profilePicture;
}
