import 'package:flutter/material.dart';

import '../models/unit.dart';

/// Dropdown estandarizado para seleccionar unidad de medida.
///
/// Se usa en todos los formularios que introducen cantidades:
/// crear receta (ingredientes), lista de la compra y despensa.
///
/// Tiene dos modos visuales:
///   * Claro (por defecto): fondo crema, texto azul. Encaja con los
///     formularios sobre fondo crema/claro.
///   * Oscuro (`dark: true`): fondo azul oscuro, texto blanco. Encaja
///     con los bottom sheets sobre fondo azul (como añadir a despensa).
class UnitDropdown extends StatelessWidget {
  /// Unidad seleccionada actualmente.
  final Unit value;

  /// Callback cuando cambia la selección.
  final ValueChanged<Unit> onChanged;

  /// Si true, el dropdown se renderiza más compacto (para filas de
  /// ingrediente donde el espacio es limitado).
  final bool compact;

  /// Si true, usa la paleta oscura (fondo azul oscuro, texto blanco)
  /// para que encaje en formularios sobre fondo azul.
  final bool dark;

  const UnitDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    // Colores según modo.
    final bg = dark ? const Color(0xFF0A2240) : const Color(0xFFF5F0E8);
    final fg = dark ? Colors.white : const Color(0xFF0C2D4E);
    final borderColor = dark
        ? Colors.transparent
        : const Color(0xFF0C2D4E).withOpacity(0.15);

    // Padding interno: igualamos al TextField estándar (h:10 v:12 en compacto,
    // h:14 v:12 en modo normal) para que las alturas/anchos coincidan en
    // los formularios donde se mezcla con campos de texto.
    final horizontalPadding = compact ? 10.0 : 14.0;

    return Container(
      // Altura fija para que coincida con la altura del TextField (~48px),
      // así no se descompensa la fila visualmente.
      height: compact ? 46 : 50,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Unit>(
          value: value,
          isExpanded: true,
          isDense: compact,
          icon: Icon(Icons.expand_more, color: fg, size: 18),
          style: TextStyle(
            color: fg,
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: bg,
          onChanged: (u) {
            if (u != null) onChanged(u);
          },
          items: Unit.values
              .map((u) => DropdownMenuItem<Unit>(
                    value: u,
                    child: Text(
                      u.label,
                      style: TextStyle(color: fg),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
