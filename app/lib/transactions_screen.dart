import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Transaction history page with responsive cards and filters.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('İşlem Geçmişi', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Gelir-gider hareketlerini filtreleyerek incele.', style: TextStyle(color: Color(0xFF616161))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniFilter(label: 'Bugün'),
                  _MiniFilter(label: 'Bu Hafta'),
                  _MiniFilter(label: 'Gelir'),
                  _MiniFilter(label: 'Gider'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...const [
              _TxCard(title: 'Maaş Ödemesi', date: '30 Nisan, 09:00', category: 'Gelir', amount: '+₺23.000'),
              _TxCard(title: 'Market Alışverişi', date: '30 Nisan, 10:45', category: 'Gider', amount: '-₺460'),
              _TxCard(title: 'Elektrik Faturası', date: '29 Nisan, 20:10', category: 'Fatura', amount: '-₺780'),
              _TxCard(title: 'Fon Satışı', date: '29 Nisan, 14:32', category: 'Yatırım', amount: '+₺2.250'),
              _TxCard(title: 'Kira Ödemesi', date: '28 Nisan, 08:12', category: 'Gider', amount: '-₺8.000'),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniFilter extends StatelessWidget {
  const _MiniFilter({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: const Color(0xFFF1F1F1),
      side: const BorderSide(color: Colors.black12),
    );
  }
}

class _TxCard extends StatelessWidget {
  const _TxCard({
    required this.title,
    required this.date,
    required this.category,
    required this.amount,
  });

  final String title;
  final String date;
  final String category;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final positive = amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F1F1),
            child: Icon(
              positive ? Icons.call_received_rounded : Icons.call_made_rounded,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('$date · $category', style: const TextStyle(color: Color(0xFF616161))),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: positive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
