import 'package:flutter/material.dart';

/// Toggle entre los dos modos de creación de receta:
/// "+ Desde vídeo" (con IA) y "Manualmente".
///
/// Sigue el estilo del mockup: pill redondeada con fondo crema
/// y la opción activa destacada en azul oscuro con texto blanco.
class CreateModeToggle extends StatelessWidget {
  final bool isVideoMode;
  final ValueChanged<bool> onChanged;

  const CreateModeToggle({
    super.key,
    required this.isVideoMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: '+ Desde vídeo',
              selected: isVideoMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Manualmente',
              selected: !isVideoMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C2D4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0C2D4E),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
