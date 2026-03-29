package com.cookshare.backend.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Filtro que intercepta cada petición HTTP para validar el token JWT.
 * Se ejecuta una vez por petición antes de llegar al controlador.
 * Extiende OncePerRequestFilter para garantizar que se ejecuta
 * exactamente una vez por petición.
 */
@Component
public class JwtFilter extends OncePerRequestFilter {

    /** Servicio para validar y leer tokens JWT. */
    private final JWTService jwtService;

    /**
     * Constructor.
     * @param jwtService servicio de tokens JWT
     */
    public JwtFilter(JWTService jwtService) {
        this.jwtService = jwtService;
    }

    /**
     * Lógica principal del filtro. Se ejecuta en cada petición HTTP.
     * 1. Lee el header Authorization de la petición.
     * 2. Extrae el token JWT del header.
     * 3. Valida el token con JwtService.
     * 4. Si es válido, autentica al usuario en Spring Security.
     * 5. Deja pasar la petición al siguiente filtro o controlador.
     * @param request petición HTTP entrante
     * @param response respuesta HTTP saliente
     * @param filterChain cadena de filtros de Spring Security
     * @throws ServletException si hay error en el procesamiento
     * @throws IOException si hay error de entrada/salida
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        // 1. Lee el header Authorization
        String authHeader = request.getHeader("Authorization");

        // 2. Si no hay header o no empieza por "Bearer ", deja pasar sin autenticar
        // Los endpoints públicos (/api/auth/**) no necesitan token
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 3. Extrae el token quitando "Bearer " (7 caracteres)
        String token = authHeader.substring(7);

        // 4. Valida el token con JwtService
        if (jwtService.isTokenValid(token)) {

            // 5. Extrae el email del token
            String email = jwtService.extractEmail(token);

            // 6. Crea un objeto de autenticación y lo registra en Spring Security
            // List.of() indica que no tiene roles asignados de momento
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(email, null, List.of());
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        // 7. Deja pasar la petición al siguiente filtro o controlador
        filterChain.doFilter(request, response);
    }
}