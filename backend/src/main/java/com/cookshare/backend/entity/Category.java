package com.cookshare.backend.entity;

/**
 * Categorías de receta predefinidas.
 * Se usa para los filtros del feed y para clasificar las recetas
 * en el momento de la creación.
 *
 * "OTRA" sirve como categoría por defecto si el usuario no elige nada.
 */
public enum Category {
    ITALIANA("Italiana"),
    MEDITERRANEA("Mediterránea"),
    VEGANA("Vegana"),
    VEGETARIANA("Vegetariana"),
    FRIA("Fría"),
    POSTRE("Postre"),
    CARNE("Carne"),
    PESCADO("Pescado"),
    SOPA("Sopa"),
    PASTA("Pasta"),
    ASIATICA("Asiática"),
    MEXICANA("Mexicana"),
    TRADICIONAL("Tradicional"),
    OTRA("Otra");

    private final String displayName;

    Category(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
