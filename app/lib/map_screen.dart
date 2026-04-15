import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'wireframe_block.dart';

/// Location-focused wireframe page.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Harita',
          style: TextStyle(
            color: preset.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: preset.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: preset.accent.withValues(alpha: 0.35), width: 1.2),
          ),
          // Placeholder map area until map SDK integration.
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 56, color: preset.primary),
                const SizedBox(height: 10),
                Text(
                  'Harita Wireframe Alani',
                  style: TextStyle(color: preset.onSurface),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        WireframeBlock(
          preset: preset,
          label: 'Yakindaki ATM ve Subeler',
          icon: Icons.location_on_outlined,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Harita Filtreleri',
          icon: Icons.filter_alt_outlined,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Rota ve Navigasyon',
          icon: Icons.route_outlined,
        ),
      ],
    );
  }
}
