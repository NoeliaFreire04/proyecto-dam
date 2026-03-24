package com.cookshare.backend.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;

/**
 * Servicio encargado de la generación, validación y lectura de tokens JWT.
 * Usa la clave secreta y la expiracion definida en application.properties.
 */
@Service
public class JWTService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    /** Convierte la clave secreta del properties en un objeto SecretKey
     * para firmar y verificar los tokens JWT.
     * @return SecretKey lista para usar con la librería JJWT */
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret));
    }

    /** Genera un token a partir de un email
     * @param email Email del usuario
     * @return String con el token generado*/
    public String generateToken(String email) {
        return Jwts.builder()
                .subject(email)        // email identificativo del usuario
                .issuedAt(new Date())  // fecha generación del token
                .expiration(new Date(System.currentTimeMillis() + expiration)) // fecha expiración token
                .signWith(getSigningKey())       // firma con la clave secreta
                .compact();            // convierte el token en el String final
    }

    /** Extrae el email de un token
     * @param token Token ha leer
     * @return String del email que contiene el token*/
    public String extractEmail(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())     // verifica la firma
                .build()
                .parseSignedClaims(token)  // abre el token
                .getPayload()          // obtiene el contenido
                .getSubject();         // devuelve el email
    }

    /** Verifica que un token sea valido
     * @param token Token generado
     * @return boolean Si el token a sido manipulado o ha expirado el parser lanza una excepción y el metodo devuelve false*/
    public Boolean isTokenValid(String token) {
        try{
            Jwts.parser()
                    .verifyWith(getSigningKey())    //verifica la firma
                    .build()
                    .parseSignedClaims(token);     // verifica la firma
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
