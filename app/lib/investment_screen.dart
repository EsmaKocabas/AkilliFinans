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
            const SizedBox(height: 12),
            const _TradePanelCard(),
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

enum _TradeAssetType { fon, hisse, altin, gumus }

enum _TradeActionType { al, sat }

class _TradePanelCard extends StatefulWidget {
  const _TradePanelCard();

  @override
  State<_TradePanelCard> createState() => _TradePanelCardState();
}

class _TradePanelCardState extends State<_TradePanelCard> {
  _TradeAssetType _assetType = _TradeAssetType.fon;
  _TradeActionType _actionType = _TradeActionType.al;
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _assetLabel(_TradeAssetType assetType) {
    return switch (assetType) {
      _TradeAssetType.fon => 'Fon',
      _TradeAssetType.hisse => 'Hisse',
      _TradeAssetType.altin => 'Altın',
      _TradeAssetType.gumus => 'Gümüş',
    };
  }

  String _symbolLabel(_TradeAssetType assetType) {
    return switch (assetType) {
      _TradeAssetType.fon => 'Fon kodu',
      _TradeAssetType.hisse => 'Hisse kodu',
      _TradeAssetType.altin => 'Altın ürünü',
      _TradeAssetType.gumus => 'Gümüş ürünü',
    };
  }

  String _symbolHint(_TradeAssetType assetType) {
    return switch (assetType) {
      _TradeAssetType.fon => 'Örn: AFT',
      _TradeAssetType.hisse => 'Örn: THYAO',
      _TradeAssetType.altin => 'Örn: XAU/TRY',
      _TradeAssetType.gumus => 'Örn: XAG/TRY',
    };
  }

  String _amountLabel(_TradeAssetType assetType) {
    return switch (assetType) {
      _TradeAssetType.hisse => 'Adet',
      _TradeAssetType.fon || _TradeAssetType.altin || _TradeAssetType.gumus => 'Tutar (₺)',
    };
  }

  void _submitTrade() {
    final symbol = _symbolController.text.trim();
    final amount = _amountController.text.trim();
    if (symbol.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ürün kodu ve tutar/adet alanını doldurun.')),
      );
      return;
    }

    final assetLabel = _assetLabel(_assetType);
    final actionLabel = _actionType == _TradeActionType.al ? 'alım' : 'satım';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$assetLabel $actionLabel emri alındı: $symbol · $amount (demo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = _actionType == _TradeActionType.al;
    return _InvestCard(
      title: 'Fon / Hisse Al-Sat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yatırım ürününü seçip hızlıca alım veya satım emri oluşturabilirsiniz (demo).',
            style: TextStyle(color: Color(0xFF616161)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_TradeAssetType>(
                  value: _assetType,
                  decoration: const InputDecoration(
                    labelText: 'Ürün tipi',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: _TradeAssetType.fon, child: Text('Fon')),
                    DropdownMenuItem(value: _TradeAssetType.hisse, child: Text('Hisse')),
                    DropdownMenuItem(value: _TradeAssetType.altin, child: Text('Altın')),
                    DropdownMenuItem(value: _TradeAssetType.gumus, child: Text('Gümüş')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _assetType = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<_TradeActionType>(
                  value: _actionType,
                  decoration: const InputDecoration(
                    labelText: 'İşlem',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: _TradeActionType.al, child: Text('Al')),
                    DropdownMenuItem(value: _TradeActionType.sat, child: Text('Sat')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _actionType = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _symbolController,
            decoration: InputDecoration(
              labelText: _symbolLabel(_assetType),
              hintText: _symbolHint(_assetType),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _amountLabel(_assetType),
              border: const OutlineInputBorder(),
              prefixText: _assetType == _TradeAssetType.hisse ? null : '₺ ',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              isBuy
                  ? 'Alım emri seçildi. Piyasa açıkken fiyat anlık değişebilir.'
                  : 'Satım emri seçildi. Portföy bakiyesi kontrol edilerek işlenir.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitTrade,
              style: FilledButton.styleFrom(
                backgroundColor: isBuy ? Colors.black : const Color(0xFF37474F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(isBuy ? Icons.add_shopping_cart_outlined : Icons.sell_outlined),
              label: Text(isBuy ? 'Alım Emri Ver' : 'Satım Emri Ver'),
            ),
          ),
        ],
      ),
    );
  }
}
