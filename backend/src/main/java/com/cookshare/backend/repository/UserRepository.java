package com.cookshare.backend.repository;

import com.cookshare.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User,Long> {

    /**Filtra los usuarios por email
     * @param email por el que filtrar los usuarios
     * @return Opcional con el usuario buscado*/
    Optional<User> findByEmail(String email);

    /**Busca si un email ya está registrado
     * @param email filtro de usuarios
     * @return boolean según existencia*/
    Boolean existsByEmail(String email);

    /**Busca si un nombre de usuario ya está registrado
     * @param username filtro de usuarios
     * @return boolean según existencia*/
    Boolean existsByUsername(String username);

    Optional<User> findByUsername(String username);
}
