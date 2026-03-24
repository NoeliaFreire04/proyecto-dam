package com.cookshare.backend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO con los datos necesarios para registrar un nuevo usuario.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RegisterDTO {
    /** Nombre de usuario elegido por el nuevo usuario. */
    @NotBlank
    @Size(min = 3, max = 50)
    private String username;

    /** Correo electrónico con el que el usuario iniciará sesión.  */
    @NotBlank
    @Email
    private String email;

    /** Contraseña en texto plano. Se hasheará con BCrypt antes de guardarse. */
    @NotBlank
    private String password;

}
