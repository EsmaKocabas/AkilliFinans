import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'wireframe_block.dart';

/// Investment planning wireframe page.
class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Yatirim',
          style: TextStyle(
            color: preset.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        WireframeBlock(
          preset: preset,
          label: 'Portfoy Dagilimi',
          icon: Icons.pie_chart_outline,
          height: 120,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Populer Fonlar',
          icon: Icons.stacked_line_chart_outlined,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Risk Profili Simulasyonu',
          icon: Icons.analytics_outlined,
        ),
        // Extra sections requested for future expansion.
        WireframeBlock(
          preset: preset,
          label: 'Ekstra Ekran: Yatirim Onerileri',
          icon: Icons.lightbulb_outline,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Ekstra Ekran: Finansal Hedefler',
          icon: Icons.rocket_launch_outlined,
        ),
      ],
    );
  }
}
