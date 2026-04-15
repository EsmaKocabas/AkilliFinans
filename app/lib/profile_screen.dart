import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'wireframe_block.dart';

/// Profile and preferences wireframe page.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Profil',
          style: TextStyle(
            color: preset.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: preset.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: preset.accent.withValues(alpha: 0.35), width: 1.2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: preset.primary.withValues(alpha: 0.2),
                radius: 28,
                child: Icon(Icons.person, color: preset.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanici Adi',
                      style: TextStyle(
                        color: preset.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'kullanici@akillifinans.app',
                      style: TextStyle(color: preset.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WireframeBlock(
          preset: preset,
          label: 'Guvenlik Ayarlari',
          icon: Icons.lock_outline,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Bildirim Tercihleri',
          icon: Icons.notifications_outlined,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Hedef ve Butce Ayarlari',
          icon: Icons.flag_outlined,
        ),
      ],
    );
  }
}
