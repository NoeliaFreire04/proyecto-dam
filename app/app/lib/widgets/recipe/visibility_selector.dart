import 'package:flutter/material.dart';

/// Selector de visibilidad de la receta: Pública o Privada.
/// Renderiza dos tarjetas seleccionables; la activa se enmarca en amarillo.
class VisibilitySelector extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;

  const VisibilitySelector({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VisibilityCard(
            icon: Icons.public,
            label: 'Pública',
            selected: isPublic,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VisibilityCard(
            icon: Icons.lock_outline,
            label: 'Privada',
            selected: !isPublic,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F0E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFF5C518)
                : const Color(0xFF0C2D4E).withOpacity(0.15),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0C2D4E), size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0C2D4E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
