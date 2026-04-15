import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'wireframe_block.dart';

/// Main landing page wireframe for account overview.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            color: preset.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        const _DashboardSectionsInfo(),
        WireframeBlock(
          preset: preset,
          label: 'Toplam Portfoy Karti',
          height: 120,
          icon: Icons.account_balance_wallet_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: WireframeBlock(
                preset: preset,
                label: 'Gelir',
                height: 110,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WireframeBlock(
                preset: preset,
                label: 'Gider',
                height: 110,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
        WireframeBlock(
          preset: preset,
          label: 'Son Islem Ozetleri',
          icon: Icons.insights_outlined,
        ),
        WireframeBlock(
          preset: preset,
          label: 'Hizli Eylemler',
          icon: Icons.flash_on_outlined,
        ),
      ],
    );
  }
}

/// Small helper widget to explain wireframe intent.
class _DashboardSectionsInfo extends StatelessWidget {
  const _DashboardSectionsInfo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        'Bu sayfa, ana finans ozet kartlarini ve hizli aksiyon alanlarini temsil eder.',
      ),
    );
  }
}
