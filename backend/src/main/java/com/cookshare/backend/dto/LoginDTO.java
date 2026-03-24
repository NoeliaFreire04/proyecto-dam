package com.cookshare.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO con los datos necesarios para el inicio de sesión de un usuario.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class LoginDTO {
    /** Correo electrónico con el que el usuario iniciará sesión.  */
    @NotBlank
    @Email
    private String email;

    /** Contraseña en texto plano. Se compara con el hash BCrypt almacenado. */
    @NotBlank
    private String password;
}

