package com.cookshare.backend.repository;

import com.cookshare.backend.entity.Recipe;
import com.cookshare.backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio JPA para la entidad Recipe.
 */
@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    /**
     * Devuelve todas las recetas públicas paginadas para el feed.
     * @param pageable configuración de paginación
     * @return página de recetas públicas
     */
    Page<Recipe> findByIsPublicTrue(Pageable pageable);

    /**
     * Devuelve todas las recetas de un usuario concreto.
     * @param userId id del usuario propietario
     * @return lista de recetas del usuario
     */
    List<Recipe> findByUserId(Long userId);

    List<Recipe> findByAuthorUsername(String username);

    /** Recetas de un autor concreto. */
    List<Recipe> findByAuthor(User author);

}