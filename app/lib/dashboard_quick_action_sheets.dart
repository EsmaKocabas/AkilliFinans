import 'package:flutter/material.dart';

import 'theme/design_tokens.dart';

/// Dashboard Hızlı Eylemler — modallar controller ömrü StatefulWidget içinde (dışarı tıklanınca güvenli dispose).
abstract final class DashboardQuickActionSheets {
  static Widget _pillHandle() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
      );

  static Future<void> showParaYatir(BuildContext scaffoldContext) {
    return showModalBottomSheet<void>(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ParaYatirSheet(scaffoldContext: scaffoldContext),
      ),
    );
  }

  static Future<void> showTransfer(BuildContext scaffoldContext) {
    return showModalBottomSheet<void>(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _TransferSheet(scaffoldContext: scaffoldContext),
      ),
    );
  }

  static Future<void> showFaturaOde(
    BuildContext scaffoldContext, {
    required void Function(int tabIndex) navigateToTab,
  }) {
    return showModalBottomSheet<void>(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final pad = MediaQuery.of(ctx).padding.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.52,
            minChildSize: 0.38,
            maxChildSize: 0.92,
            builder: (_, scroll) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Center(child: _pillHandle()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Fatura öde', style: AppTypography.sectionTitle.copyWith(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        'Vadesi yakın fatura özeti.',
                        style: AppTypography.sectionHint,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scroll,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + pad),
                        children: [
                          _invoiceRow(ctx, title: 'Elektrik Mart', subtitle: 'Son gün yarın · Tedarikçi A', trailing: '-₺780'),
                          _invoiceRow(ctx, title: 'Doğalgaz', subtitle: 'Otomatik ödeme bekliyor', trailing: '-₺412'),
                          _invoiceRow(ctx, title: 'İnternet / TV', subtitle: 'Ay sonu kesim', trailing: '-₺219'),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              navigateToTab(2);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                  const SnackBar(content: Text('İşlem geçmişi sekmesine geçildi.')),
                                );
                              });
                            },
                            icon: const Icon(Icons.receipt_long_outlined),
                            label: const Text('Tüm işlemleri gör (Geçmiş)'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _invoiceRow(
    BuildContext ctx, {
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.tile),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.listTitle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.listSubtitle),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trailing, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red.shade700)),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$title ödemesi başlatıldı (demo).')));
                  },
                  child: const Text('Öde'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showHedefOlustur(
    BuildContext scaffoldContext, {
    required void Function(int tabIndex) navigateToTab,
  }) {
    return showModalBottomSheet<void>(
      context: scaffoldContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _HedefSheet(scaffoldContext: scaffoldContext, navigateToTab: navigateToTab),
      ),
    );
  }
}

class _ParaYatirSheet extends StatefulWidget {
  const _ParaYatirSheet({required this.scaffoldContext});

  final BuildContext scaffoldContext;

  @override
  State<_ParaYatirSheet> createState() => _ParaYatirSheetState();
}

class _ParaYatirSheetState extends State<_ParaYatirSheet> {
  late final TextEditingController _amount;
  String _account = 'Ana Hesap **** 7821';

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: DashboardQuickActionSheets._pillHandle()),
            Text('Para yatır', style: AppTypography.sectionTitle.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Hesabına tutar yükleme (demo arayüz).',
              style: AppTypography.sectionHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tutar (₺)',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hedef hesap',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _account,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Ana Hesap **** 7821', child: Text('Ana Hesap **** 7821')),
                    DropdownMenuItem(value: 'Euro Hesap **** 9912', child: Text('Euro Hesap **** 9912')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _account = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                  const SnackBar(content: Text('Para yatırma isteği alındı (demo).')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.heroDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Devam et'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ],
        ),
      ),
    );
  }
}

class _TransferSheet extends StatefulWidget {
  const _TransferSheet({required this.scaffoldContext});

  final BuildContext scaffoldContext;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  late final TextEditingController _iban;
  late final TextEditingController _amount;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _iban = TextEditingController();
    _amount = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _iban.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + pad),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: DashboardQuickActionSheets._pillHandle()),
              Text('Transfer', style: AppTypography.sectionTitle.copyWith(fontSize: 20)),
              const SizedBox(height: AppSpacing.xs),
              const Text('Başka hesaba FAST/EFT ile gönder (demo).', style: AppTypography.sectionHint),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _iban,
                decoration: const InputDecoration(
                  labelText: 'Alıcı IBAN veya cep',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺)',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _note,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (isteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Transfer onay ekranına yönlendirileceksiniz (demo).')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.heroDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Gönder'),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ],
          ),
        ),
      ),
    );
  }
}

class _HedefSheet extends StatefulWidget {
  const _HedefSheet({
    required this.scaffoldContext,
    required this.navigateToTab,
  });

  final BuildContext scaffoldContext;
  final void Function(int tabIndex) navigateToTab;

  @override
  State<_HedefSheet> createState() => _HedefSheetState();
}

class _HedefSheetState extends State<_HedefSheet> {
  late final TextEditingController _name;
  late final TextEditingController _tutar;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _tutar = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _tutar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + pad),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: DashboardQuickActionSheets._pillHandle()),
              Text('Hedef oluştur', style: AppTypography.sectionTitle.copyWith(fontSize: 20)),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Otomatik birikim hedefini tanımla (demo).',
                style: AppTypography.sectionHint,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Hedef adı (örn. Tatil fonu)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _tutar,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hedef tutar (₺)',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Yüzde seç', style: AppTypography.sectionHint),
              const _PctSliderRow(),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                    SnackBar(content: Text('Hedef kaydedildi: ${_name.text.isEmpty ? 'Yeni hedef' : _name.text} (demo).')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.heroDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Kaydet'),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.navigateToTab(4);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                      const SnackBar(content: Text('Yatırım sekmesi açıldı.')),
                    );
                  });
                },
                icon: const Icon(Icons.trending_up_outlined),
                label: const Text('Yatırım ekranını aç'),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PctSliderRow extends StatefulWidget {
  const _PctSliderRow();

  @override
  State<_PctSliderRow> createState() => _PctSliderRowState();
}

class _PctSliderRowState extends State<_PctSliderRow> {
  double _v = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: _v,
          min: 5,
          max: 35,
          divisions: 6,
          label: '%${_v.round()}',
          onChanged: (nv) => setState(() => _v = nv),
        ),
        Text(
          "Seçilen: gelirin %${_v.round()}'ü",
          style: AppTypography.listSubtitle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
