package com.cookshare.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO con los datos devueltos por el servidor tras un registro o login exitoso.
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SessionDTO {
    /** Token JWT de sesión para autenticar las siguientes peticiones. */
    private String tokenJWT;

    /** Email del usuario. */
    private String email;
}
