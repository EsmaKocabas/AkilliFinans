import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Shared placeholder card used by all wireframe screens.
class WireframeBlock extends StatelessWidget {
  const WireframeBlock({
    super.key,
    required this.preset,
    required this.label,
    this.height = 90,
    this.icon = Icons.crop_square_outlined,
    this.trailing,
  });

  final DesignPreset preset;
  final String label;
  final double height;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: preset.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: preset.accent.withValues(alpha: 0.35), width: 1.2),
      ),
      child: ListTile(
        leading: Icon(icon, color: preset.primary),
        title: Text(label, style: TextStyle(color: preset.onSurface)),
        subtitle: Text(
          'Wireframe bileseni',
          style: TextStyle(color: preset.accent),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: preset.primary),
      ),
    );
  }
}
