/// Catálogo central de unidades de medida usadas en la app.
///
/// Se utiliza en todos los formularios que introducen cantidades:
/// crear receta (ingredientes), lista de la compra y despensa.
///
/// Estructura: code → cómo se guarda en BD; label → cómo se muestra.
/// El `code` es estable (no debería cambiar nunca para no romper datos
/// existentes). El `label` puede cambiarse libremente.
enum Unit {
  // Peso
  g('g', 'g'),
  kg('kg', 'kg'),
  mg('mg', 'mg'),

  // Volumen
  ml('ml', 'ml'),
  l('L', 'L'),
  cl('cl', 'cl'),

  // Unidades sueltas
  uds('uds', 'uds'),

  // Cocina (medidas con utensilio)
  cda('cda', 'cda'),
  cdta('cdta', 'cdta'),
  taza('taza', 'taza'),
  vaso('vaso', 'vaso'),

  // Aproximadas (sin cantidad numérica real)
  pizca('pizca', 'pizca'),
  alGusto('al gusto', 'al gusto');

  /// Identificador estable que se guarda en BD.
  final String code;

  /// Cómo se muestra al usuario.
  final String label;

  const Unit(this.code, this.label);

  /// Devuelve la enum a partir del code (case-insensitive).
  /// Si no hay match, devuelve [Unit.uds] como fallback seguro.
  static Unit fromCode(String? code) {
    if (code == null || code.isEmpty) return Unit.uds;
    final normalized = _normalize(code);
    for (final u in Unit.values) {
      if (u.code.toLowerCase() == normalized) return u;
    }
    return Unit.uds;
  }

  /// Acepta también unidades antiguas/variantes y las normaliza.
  /// Por ejemplo "gramos" → "g", "litro" → "L", "GR" → "g".
  static String _normalize(String raw) {
    final clean = raw.trim().toLowerCase();
    const aliases = {
      'gr': 'g',
      'gramo': 'g',
      'gramos': 'g',
      'kilo': 'kg',
      'kilos': 'kg',
      'kilogramo': 'kg',
      'kilogramos': 'kg',
      'mililitro': 'ml',
      'mililitros': 'ml',
      'litro': 'l',
      'litros': 'l',
      'centilitro': 'cl',
      'centilitros': 'cl',
      'unidad': 'uds',
      'unidades': 'uds',
      'ud': 'uds',
      'cucharada': 'cda',
      'cucharadas': 'cda',
      'cucharaditas': 'cdta',
      'cucharadita': 'cdta',
      'tazas': 'taza',
      'vasos': 'vaso',
      'pizcas': 'pizca',
      'agusto': 'al gusto',
    };
    return aliases[clean] ?? clean;
  }
}
