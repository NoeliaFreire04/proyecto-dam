package com.cookshare.backend.controller;

import com.cookshare.backend.dto.UserProfileDTO;
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

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Devuelve los datos del usuario autenticado (sin password).
     * Útil al cargar la pantalla de perfil.
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileDTO> me(Authentication authentication) {
        String email = authentication.getName();
        User user = findUserOrThrow(email);
        return ResponseEntity.ok(toDTO(user));
    }

    /**
     * Actualiza el perfil del usuario autenticado.
     * Permite cambiar username, email y profilePicture.
     */
    @PutMapping("/profile")
    public ResponseEntity<UserProfileDTO> updateProfile(@RequestBody UserProfileDTO updates,
                                                        Authentication authentication) {
        String email = authentication.getName();
        User user = findUserOrThrow(email);

        if (updates.getUsername() != null && !updates.getUsername().isBlank()) {
            user.setUsername(updates.getUsername().trim());
        }
        if (updates.getEmail() != null && !updates.getEmail().isBlank()) {
            user.setEmail(updates.getEmail().trim());
        }
        // profilePicture: permitimos null/blanco para BORRAR la imagen, así
        // que diferenciamos "no incluida en el payload" de "valor vacío".
        // Como el JSON puede no traer la clave, ambos casos llegan como null
        // y no podemos distinguirlos sin un wrapper Optional. Solución
        // pragmática: si viene null, ignoramos; si viene "" se borra; si
        // viene texto se asigna.
        if (updates.getProfilePicture() != null) {
            user.setProfilePicture(
                    updates.getProfilePicture().isBlank() ? null : updates.getProfilePicture().trim());
        }

        userRepository.save(user);
        return ResponseEntity.ok(toDTO(user));
    }

    private User findUserOrThrow(String email) {
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("Usuario no encontrado");
        }
        return optionalUser.get();
    }

    private UserProfileDTO toDTO(User user) {
        return UserProfileDTO.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .profilePicture(user.getProfilePicture())
                .build();
    }
}
