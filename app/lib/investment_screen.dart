import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Investment planning page with modern responsive sections.
class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Yatırım', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Portföy dağılımı ve önerileri tek ekranda yönet.', style: TextStyle(color: Color(0xFF616161))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toplam Yatırım', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text('₺124.900', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Bu ay getiri: +%4.8', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _InvestCard(
              title: 'Portföy Dağılımı',
              child: Column(
                children: [
                  _AllocRow(label: 'Fonlar', ratio: 0.45),
                  _AllocRow(label: 'Hisse', ratio: 0.30),
                  _AllocRow(label: 'Altın', ratio: 0.15),
                  _AllocRow(label: 'Nakit', ratio: 0.10),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _InvestCard(
              title: 'Öneriler',
              child: Column(
                children: [
                  _SuggestionRow(title: 'Düşük riskli fon sepeti', subtitle: 'Beklenen yıllık getiri: %28'),
                  _SuggestionRow(title: 'Altın ağırlığını %5 artır', subtitle: 'Volatiliteyi dengelemek için'),
                  _SuggestionRow(title: 'Acil durum fonu oluştur', subtitle: '3 aylık gider hedefleniyor'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _InvestCard(
              title: 'Risk Profili',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.shield_outlined),
                title: Text('Orta Risk'),
                subtitle: Text('Portföy dengesi korunuyor, uzun vadeli uygun.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestCard extends StatelessWidget {
  const _InvestCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AllocRow extends StatelessWidget {
  const _AllocRow({required this.label, required this.ratio});

  final String label;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final percent = (ratio * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: ratio,
                backgroundColor: const Color(0xFFEAEAEA),
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('%$percent', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFF1F1F1),
        child: Icon(Icons.lightbulb_outline, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    );
  }
}
