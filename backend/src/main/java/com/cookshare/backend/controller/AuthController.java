package com.cookshare.backend.controller;

import com.cookshare.backend.dto.LoginDTO;
import com.cookshare.backend.dto.RegisterDTO;
import com.cookshare.backend.dto.SessionDTO;
import com.cookshare.backend.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador para la autenticación de usuarios.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    /** Servicio que contiene la lógica de registro e inicio de sesión. */
    private final UserService userService;

    /**
     * Constructor.
     * @param userService servicio de autenticación de usuarios
     */
    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Registra un nuevo usuario en la aplicación.
     * @param dto datos del nuevo usuario (username, email, password)
     * @return 201 Created con el token JWT y el email del usuario
     */
    @PostMapping("/register")
    public ResponseEntity<SessionDTO> register(@RequestBody @Valid RegisterDTO dto) {
        SessionDTO session = userService.register(dto);
        return ResponseEntity.status(201).body(session);
    }

    /**
     * Inicia sesión de un usuario existente.
     * @param dto credenciales del usuario (email, password)
     * @return 200 OK con el token JWT y el email del usuario
     */
    @PostMapping("/login")
    public ResponseEntity<SessionDTO> login(@RequestBody @Valid LoginDTO dto) {
        SessionDTO session = userService.login(dto);
        return ResponseEntity.status(200).body(session);
    }
}