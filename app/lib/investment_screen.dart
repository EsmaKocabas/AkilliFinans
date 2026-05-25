import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'design_preset.dart';
import 'services/session_service.dart';

/// Investment planning page with modern responsive sections.
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  bool _isLoading = true;
  String? _error;
  double _totalInvestment = 0.0;
  List<dynamic> _allocation = [];
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final portfolioUrl = Uri.parse('${AppSession.baseUrl}/api/investments/portfolio');
      final suggestionsUrl = Uri.parse('${AppSession.baseUrl}/api/investments/suggestions');

      final portfolioRes = await http.get(portfolioUrl, headers: session.headers);
      final suggestionsRes = await http.get(suggestionsUrl, headers: session.headers);

      if (portfolioRes.statusCode == 200 && suggestionsRes.statusCode == 200) {
        final portfolioData = jsonDecode(portfolioRes.body)['data'];
        final suggestionsData = jsonDecode(suggestionsRes.body)['data'];

        if (mounted) {
          setState(() {
            _totalInvestment = (portfolioData['totalInvestment'] as num).toDouble();
            _allocation = portfolioData['allocation'] ?? [];
            _suggestions = suggestionsData ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Yatırım verileri alınamadı.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Sunucu bağlantı hatası: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Toplam Yatırım', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('₺${_totalInvestment.round()}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Bu ay getiri: +%4.8', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _InvestCard(
              title: 'Portföy Dağılımı',
              child: _allocation.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Henüz yatırımınız bulunmuyor.', style: TextStyle(color: Colors.grey)),
                    )
                  : Column(
                      children: _allocation.map((item) {
                        final label = '${item['symbol']} (${item['assetType'].toString().toUpperCase()})';
                        final ratio = (item['ratio'] as num).toDouble();
                        return _AllocRow(label: label, ratio: ratio);
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 12),
            _InvestCard(
              title: 'Öneriler',
              child: Column(
                children: _suggestions.map((item) {
                  return _SuggestionRow(
                    title: item['title'] ?? '',
                    subtitle: item['subtitle'] ?? '',
                  );
                }).toList(),
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
            _TradePanelCard(onTradeExecuted: _fetchData),
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
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis))),
          const SizedBox(width: 4),
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
  const _TradePanelCard({required this.onTradeExecuted});

  final VoidCallback onTradeExecuted;

  @override
  State<_TradePanelCard> createState() => _TradePanelCardState();
}

class _TradePanelCardState extends State<_TradePanelCard> {
  _TradeAssetType _assetType = _TradeAssetType.fon;
  _TradeActionType _actionType = _TradeActionType.al;
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _amountController.dispose();
    super.dispose();
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

  Future<void> _submitTrade() async {
    final symbol = _symbolController.text.trim();
    final amountText = _amountController.text.trim();
    if (symbol.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ürün kodu ve tutar/adet alanını doldurun.')),
      );
      return;
    }

    final amountVal = double.tryParse(amountText);
    if (amountVal == null || amountVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar/adet girin.')),
      );
      return;
    }

    setState(() => _submitting = true);

    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/investments/trade');
      final assetTypeStr = switch (_assetType) {
        _TradeAssetType.fon => 'fon',
        _TradeAssetType.hisse => 'hisse',
        _TradeAssetType.altin => 'altin',
        _TradeAssetType.gumus => 'gumus',
      };
      final actionStr = _actionType == _TradeActionType.al ? 'al' : 'sat';

      final response = await http.post(
        url,
        headers: session.headers,
        body: jsonEncode({
          'assetType': assetTypeStr,
          'action': actionStr,
          'symbol': symbol,
          'amount': amountVal,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final remainingBudget = (body['data']['remainingBudget'] as num).toDouble();
        session.updateBudget(remainingBudget);

        if (mounted) {
          _symbolController.clear();
          _amountController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'İşlem tamamlandı.')),
          );
          widget.onTradeExecuted();
        }
      } else {
        final err = jsonDecode(response.body)['message'] ?? 'İşlem başarısız.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $err')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
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
            'Yatırım ürününü seçip hızlıca alım veya satım emri oluşturabilirsiniz.',
            style: TextStyle(color: Color(0xFF616161)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_TradeAssetType>(
                  initialValue: _assetType,
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
                  initialValue: _actionType,
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
              onPressed: _submitting ? null : _submitTrade,
              style: FilledButton.styleFrom(
                backgroundColor: isBuy ? Colors.black : const Color(0xFF37474F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(isBuy ? Icons.add_shopping_cart_outlined : Icons.sell_outlined),
              label: Text(isBuy ? 'Alım Emri Ver' : 'Satım Emri Ver'),
            ),
          ),
        ],
      ),
    );
  }
}
