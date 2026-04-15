import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'wireframe_block.dart';

/// Transaction history page with list placeholders.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Islem Gecmisi',
          style: TextStyle(
            color: preset.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 12),
        WireframeBlock(
          preset: preset,
          label: 'Arama ve Tarih Filtreleri',
          icon: Icons.search_outlined,
        ),
        ...List.generate(
          6,
          (index) => WireframeBlock(
            preset: preset,
            label: 'Islem Kaydi #${index + 1}',
            icon: index.isEven ? Icons.call_received : Icons.call_made,
            trailing: Text(
              index.isEven ? '+ 2.450 TL' : '- 670 TL',
              style: TextStyle(
                color: index.isEven ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
