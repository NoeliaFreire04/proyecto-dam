package com.cookshare.backend.util;

import java.util.Map;

/**
 * Normaliza unidades de medida a los códigos canónicos del frontend.
 *
 * El frontend tiene un enum `Unit` con 12 unidades. Antes de implementarlo
 * cada usuario escribía unidades a mano ("gramos", "GR", "kg", "kilo")
 * y esto creaba inconsistencias en BD.
 *
 * Esta clase convierte cualquier variante reconocida a su forma canónica
 * (g, kg, mg, ml, L, cl, uds, cda, cdta, taza, vaso, pizca, al gusto).
 * Si no reconoce el valor, lo devuelve tal cual (preferimos no perder dato).
 */
public final class UnitNormalizer {

    private UnitNormalizer() {}

    private static final Map<String, String> ALIASES = Map.ofEntries(
            // peso
            Map.entry("g", "g"),
            Map.entry("gr", "g"),
            Map.entry("gramo", "g"),
            Map.entry("gramos", "g"),
            Map.entry("kg", "kg"),
            Map.entry("kilo", "kg"),
            Map.entry("kilos", "kg"),
            Map.entry("kilogramo", "kg"),
            Map.entry("kilogramos", "kg"),
            Map.entry("mg", "mg"),
            // volumen
            Map.entry("ml", "ml"),
            Map.entry("mililitro", "ml"),
            Map.entry("mililitros", "ml"),
            Map.entry("l", "L"),
            Map.entry("litro", "L"),
            Map.entry("litros", "L"),
            Map.entry("cl", "cl"),
            Map.entry("centilitro", "cl"),
            Map.entry("centilitros", "cl"),
            // sueltas
            Map.entry("uds", "uds"),
            Map.entry("ud", "uds"),
            Map.entry("unidad", "uds"),
            Map.entry("unidades", "uds"),
            // cocina
            Map.entry("cda", "cda"),
            Map.entry("cucharada", "cda"),
            Map.entry("cucharadas", "cda"),
            Map.entry("cdta", "cdta"),
            Map.entry("cucharadita", "cdta"),
            Map.entry("cucharaditas", "cdta"),
            Map.entry("taza", "taza"),
            Map.entry("tazas", "taza"),
            Map.entry("vaso", "vaso"),
            Map.entry("vasos", "vaso"),
            // cualitativas
            Map.entry("pizca", "pizca"),
            Map.entry("pizcas", "pizca"),
            Map.entry("al gusto", "al gusto"),
            Map.entry("agusto", "al gusto")
    );

    /**
     * Devuelve la unidad normalizada al código canónico.
     * Si no es reconocida, devuelve el valor original (sin modificar)
     * para no perder información de recetas legacy.
     */
    public static String normalize(String raw) {
        if (raw == null) return null;
        String key = raw.trim().toLowerCase();
        if (key.isEmpty()) return raw;
        return ALIASES.getOrDefault(key, raw);
    }
}
