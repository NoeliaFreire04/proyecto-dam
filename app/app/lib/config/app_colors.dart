import 'package:flutter/material.dart';

//paleta de colores centralizada del proyecto CookShare
class AppColors {
  AppColors._();

  //fondo principal de pantallas con tema oscuro (azul marino)
  static const Color backgroundDark = Color(0xFF0C2D4E);

  //fondo de pantallas con tema claro (blanco cálido)
  static const Color backgroundLight = Color(0xFFF5F0E8);

  //color de acento principal: amarillo dorado para botones y selecciones
  static const Color accent = Color(0xFFF5C518);

  //variante del acento usada en formularios de autenticación
  static const Color accentAlt = Color(0xFFE8C55A);

  //fondo secundario de campos de texto sobre pantalla oscura
  static const Color fieldBackground = Color(0xFF0A2240);

  //color para iconos, etiquetas y textos secundarios sobre fondo oscuro
  static const Color textMuted = Color(0xFF7A8FA3);

  //color de separadores, bordes sutiles y elementos deshabilitados
  static const Color divider = Color(0xFF4A6A84);

  //color de error y acciones destructivas (eliminar, cerrar sesión)
  static const Color error = Color(0xFFE57373);

  //texto principal sobre fondo claro
  static const Color textOnLight = Color(0xFF0C2D4E);

  //texto secundario sobre fondo claro
  static const Color textSecondaryOnLight = Color(0xFF7E8A99);
}
