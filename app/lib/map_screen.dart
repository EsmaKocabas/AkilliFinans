import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Location-focused responsive page.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Harita', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('ATM, şube ve rota planlaması.', style: TextStyle(color: Color(0xFF616161))),
            const SizedBox(height: 16),
            Container(
              height: 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.map_outlined, size: 72, color: Colors.black54)),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('Canlı Harita Önizleme', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Card(
              title: 'Harita Filtreleri',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(label: 'ATM'),
                  _FilterChip(label: 'Şube'),
                  _FilterChip(label: '24 Saat'),
                  _FilterChip(label: 'Yatırım Merkezi'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Card(
              title: 'Yakındaki Noktalar',
              child: Column(
                children: [
                  _LocationRow(title: 'Akıllı Finans ATM - Ataşehir', distance: '0.8 km'),
                  _LocationRow(title: 'Akıllı Finans Şube - Kozyatağı', distance: '1.4 km'),
                  _LocationRow(title: 'Akıllı Finans ATM - Kadıköy', distance: '2.1 km'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Card(
              title: 'Rota Önerisi',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.route_outlined),
                title: Text('En kısa rota ile 7 dk'),
                subtitle: Text('Yoğunluk düşük, yürüyerek önerilir.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: const BorderSide(color: Colors.black12),
      backgroundColor: const Color(0xFFF1F1F1),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.title, required this.distance});
  final String title;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFF1F1F1),
        child: Icon(Icons.place_outlined, color: Colors.black),
      ),
      title: Text(title),
      trailing: Text(distance, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
