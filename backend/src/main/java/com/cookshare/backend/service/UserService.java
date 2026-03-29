package com.cookshare.backend.service;

import com.cookshare.backend.dto.LoginDTO;
import com.cookshare.backend.dto.RegisterDTO;
import com.cookshare.backend.dto.SessionDTO;
import com.cookshare.backend.entity.User;
import com.cookshare.backend.repository.UserRepository;
import com.cookshare.backend.security.JWTService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Servicio encargado de la lógica de negocio de autenticación de usuarios.
 * Gestiona el registro e inicio de sesión, incluyendo el hasheo de contraseñas
 * y la generación de tokens JWT.
 */
@Service
public class UserService {

    /** Repositorio para acceder a los datos de usuarios en la BD. */
    private final UserRepository userRepository;

    /** Servicio para generar y validar tokens JWT. */
    private final JWTService jwtService;

    /** Encoder para hashear y comparar contraseñas con BCrypt. */
    private final PasswordEncoder passwordEncoder;

    /**
     * Constructor.
     * @param userRepository repositorio de usuarios
     * @param jwtService servicio de tokens JWT
     * @param passwordEncoder encoder de contraseñas BCrypt
     */
    public UserService(UserRepository userRepository, JWTService jwtService, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Registra un nuevo usuario en la aplicación.
     * Comprueba que el email y el username no estén ya en uso,
     * hashea la contraseña con BCrypt y genera un token JWT.
     * @param dto datos del nuevo usuario (username, email, password)
     * @return SessionDTO con el token JWT y el email del usuario registrado
     * @throws RuntimeException si el email o el username ya están registrados
     */
    public SessionDTO register(RegisterDTO dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("El email ya está registrado.");
        }
        if (userRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("El nombre de usuario ya está registrado.");
        }
        // Hashea la contraseña antes de guardarla en la BD
        String hashedPassword = passwordEncoder.encode(dto.getPassword());

        // Construye el objeto User con los datos del DTO
        User user = User.builder()
                .username(dto.getUsername())
                .email(dto.getEmail())
                .password(hashedPassword)
                .build();

        userRepository.save(user);

        // Genera el token JWT con el email como identificador
        String token = jwtService.generateToken(dto.getEmail());
        return SessionDTO.builder().email(dto.getEmail()).tokenJWT(token).build();
    }

    /**
     * Inicia sesión de un usuario existente.
     * Busca el usuario por email, compara la contraseña con el hash guardado
     * y genera un token JWT si las credenciales son correctas.
     * @param dto credenciales del usuario (email, password)
     * @return SessionDTO con el token JWT y el email del usuario
     * @throws RuntimeException si el email no existe o la contraseña es incorrecta
     */
    public SessionDTO login(LoginDTO dto) {
        // Busca el usuario por email, lanza error si no existe
        Optional<User> optionalUser = userRepository.findByEmail(dto.getEmail());
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("El email no está registrado");
        }
        User user = optionalUser.get();

        // Compara la contraseña en texto plano con el hash guardado en la BD
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new RuntimeException("La contraseña no es correcta");
        }

        // Genera el token JWT con el email como identificador
        String token = jwtService.generateToken(user.getEmail());
        return SessionDTO.builder().email(dto.getEmail()).tokenJWT(token).build();
    }
}