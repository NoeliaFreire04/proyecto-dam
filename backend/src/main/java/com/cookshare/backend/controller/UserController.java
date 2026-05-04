package com.cookshare.backend.controller;

import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

/**
 * Controlador REST para la gestión del perfil del usuario.
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    /**
     * Constructor con inyección de dependencias.
     *
     * @param userRepository repositorio de usuarios
     */
    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Actualiza el perfil del usuario autenticado.
     * Permite cambiar el username y el email.
     *
     * @param updates datos nuevos del perfil
     * @param authentication usuario autenticado
     * @return el usuario actualizado
     */
    @PutMapping("/profile")
    public ResponseEntity<User> updateProfile(@RequestBody User updates,
                                              Authentication authentication) {
        String username = authentication.getName();

        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        User user = optionalUser.get();

        if (updates.getUsername() != null) {
            user.setUsername(updates.getUsername());
        }
        if (updates.getEmail() != null) {
            user.setEmail(updates.getEmail());
        }

        userRepository.save(user);
        return ResponseEntity.ok(user);
    }
}