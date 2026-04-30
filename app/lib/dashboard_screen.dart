import 'package:flutter/material.dart';

import 'design_preset.dart';

/// Dashboard page with modern responsive layout.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final sidePadding = isWide ? 28.0 : 16.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 28),
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Finansal durumunu tek ekranda takip et.',
                  style: TextStyle(color: Color(0xFF616161)),
                ),
                const SizedBox(height: 16),
                _PortfolioCard(accent: preset.primary),
                const SizedBox(height: 12),
                isWide
                    ? Row(
                        children: const [
                          Expanded(child: _StatCard(title: 'Gelir', value: '₺28.450', trend: '+12%')),
                          SizedBox(width: 12),
                          Expanded(child: _StatCard(title: 'Gider', value: '₺14.980', trend: '-4%')),
                          SizedBox(width: 12),
                          Expanded(child: _StatCard(title: 'Tasarruf', value: '₺13.470', trend: '+18%')),
                        ],
                      )
                    : const Column(
                        children: [
                          _StatCard(title: 'Gelir', value: '₺28.450', trend: '+12%'),
                          SizedBox(height: 10),
                          _StatCard(title: 'Gider', value: '₺14.980', trend: '-4%'),
                          SizedBox(height: 10),
                          _StatCard(title: 'Tasarruf', value: '₺13.470', trend: '+18%'),
                        ],
                      ),
                const SizedBox(height: 12),
                const _SectionCard(
                  title: 'Hızlı Eylemler',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ActionChip(icon: Icons.add_card, label: 'Para Yatır'),
                      _ActionChip(icon: Icons.send_outlined, label: 'Transfer'),
                      _ActionChip(icon: Icons.receipt_long_outlined, label: 'Fatura Öde'),
                      _ActionChip(icon: Icons.savings_outlined, label: 'Hedef Oluştur'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionCard(
                  title: 'Son İşlemler',
                  child: Column(
                    children: [
                      _TransactionRow(title: 'Market Alışverişi', date: 'Bugün, 10:45', amount: '-₺460'),
                      _TransactionRow(title: 'Maaş Ödemesi', date: 'Dün, 09:00', amount: '+₺23.000'),
                      _TransactionRow(title: 'Elektrik Faturası', date: 'Dün, 20:10', amount: '-₺780'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Toplam Varlık', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text(
                  '₺186.420',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
                ),
                SizedBox(height: 6),
                Text('+₺8.240 bu ay', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withValues(alpha: 0.25),
            child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.trend});

  final String title;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        '$title\n$value\n$trend',
        style: const TextStyle(height: 1.45, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.black),
      label: Text(label),
      side: const BorderSide(color: Colors.black12),
      backgroundColor: const Color(0xFFF1F1F1),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.title, required this.date, required this.amount});

  final String title;
  final String date;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith('+');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF1F1F1),
        child: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.black),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}
