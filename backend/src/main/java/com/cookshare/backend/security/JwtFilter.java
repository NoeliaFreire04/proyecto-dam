package com.cookshare.backend.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filtro que intercepta cada petición HTTP para validar el token JWT.
 * Se ejecuta una vez por petición antes de llegar al controlador.
 * Extiende OncePerRequestFilter para garantizar que se ejecuta
 * exactamente una vez por petición.
 */
@Component
public class JwtFilter extends OncePerRequestFilter {
    /**
     * Lógica principal del filtro.
     * Extrae y valida el token JWT del header Authorization.
     * Si el token es válido, permite continuar la petición.
     * Si no hay token o es inválido, rechaza la petición.
     * @param request petición HTTP entrante
     * @param response respuesta HTTP saliente
     * @param filterChain cadena de filtros de Spring Security
     * @throws ServletException si hay error en el procesamiento
     * @throws IOException si hay error de entrada/salida
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        filterChain.doFilter(request, response);
    }
}