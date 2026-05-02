import 'package:flutter/material.dart';

import 'design_preset.dart';
import 'theme/design_tokens.dart';
import 'widgets/scrollable_screen_shell.dart';

/// Harcama kategorileri: Market, Fatura, Ulaşım, Eğlence (+ konut, gelir, yatırım).
enum _TxCategory {
  market,
  fatura,
  ulasim,
  eglence,
  konut,
  gelir,
  yatirim,
}

extension _TxCategoryX on _TxCategory {
  String get label => switch (this) {
        _TxCategory.market => 'Market',
        _TxCategory.fatura => 'Fatura',
        _TxCategory.ulasim => 'Ulaşım',
        _TxCategory.eglence => 'Eğlence',
        _TxCategory.konut => 'Konut',
        _TxCategory.gelir => 'Gelir',
        _TxCategory.yatirim => 'Yatırım',
      };

  IconData get icon => switch (this) {
        _TxCategory.market => Icons.shopping_basket_outlined,
        _TxCategory.fatura => Icons.receipt_long_outlined,
        _TxCategory.ulasim => Icons.directions_bus_outlined,
        _TxCategory.eglence => Icons.theaters_outlined,
        _TxCategory.konut => Icons.home_work_outlined,
        _TxCategory.gelir => Icons.account_balance_wallet_outlined,
        _TxCategory.yatirim => Icons.trending_up_outlined,
      };

  /// Tek renk ikonlu tasarım: arka plan tonu (siyah-beyaz uyumlu).
  Color get avatarTint => switch (this) {
        _TxCategory.market => const Color(0xFFE8E8E8),
        _TxCategory.fatura => const Color(0xFFE3E3E3),
        _TxCategory.ulasim => const Color(0xFFDEDEDE),
        _TxCategory.eglence => const Color(0xFFE6E6E6),
        _TxCategory.konut => const Color(0xFFDFDFDF),
        _TxCategory.gelir => const Color(0xFFD8F0E0),
        _TxCategory.yatirim => const Color(0xFFE2E8F5),
      };
}

/// İşlem geçmişi: kategorili liste + detay (işlem etkinliği UI Dashboard’dadır).
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

enum _TxFilter { tumu, gider, gelir }

class _TransactionEntry {
  const _TransactionEntry({
    required this.title,
    required this.dateLabel,
    required this.amountLabel,
    required this.isExpense,
    required this.merchant,
    required this.paymentMethod,
    required this.referenceCode,
    required this.detailNote,
    required this.category,
  });

  final String title;
  final String dateLabel;
  final String amountLabel;
  final bool isExpense;
  final String merchant;
  final String paymentMethod;
  final String referenceCode;
  final String detailNote;
  final _TxCategory category;
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _TxFilter _filter = _TxFilter.tumu;
  _TxCategory? _categoryFilter;

  static const List<_TransactionEntry> _all = [
    _TransactionEntry(
      title: 'Maaş Ödemesi',
      dateLabel: '30 Nisan 2026, 09:00',
      amountLabel: '+₺23.000',
      isExpense: false,
      merchant: 'Akıllı Finans A.Ş.',
      paymentMethod: 'Banka Havalesi',
      referenceCode: 'REF-GEL-202604300901',
      detailNote: 'Aylık net maaş ödemesi. Vergi ve SGK kesintileri yapılmış tutardır.',
      category: _TxCategory.gelir,
    ),
    _TransactionEntry(
      title: 'Market Alışverişi',
      dateLabel: '30 Nisan 2026, 10:45',
      amountLabel: '-₺460',
      isExpense: true,
      merchant: 'CarrefourSA Kadıköy',
      paymentMethod: 'Temassız Kart · **** 4821',
      referenceCode: 'TXN-884921044',
      detailNote: 'Gıda ve temizlik ürünleri. Fiş POS üzerinden otomatik olarak Market kategorisine işlendi.',
      category: _TxCategory.market,
    ),
    _TransactionEntry(
      title: 'Elektrik Faturası',
      dateLabel: '29 Nisan 2026, 20:10',
      amountLabel: '-₺780',
      isExpense: true,
      merchant: 'CK Enerji',
      paymentMethod: 'Otomatik Ödeme Talimatı',
      referenceCode: 'FTV-E250429881',
      detailNote: 'Mart dönemi tüketim faturası. Fatura kategorisi altında takip edilir.',
      category: _TxCategory.fatura,
    ),
    _TransactionEntry(
      title: 'İstanbul Kart Bakiye',
      dateLabel: '29 Nisan 2026, 07:28',
      amountLabel: '-₺175',
      isExpense: true,
      merchant: 'Biletmatik · Kadıköy',
      paymentMethod: 'Temassız Kart · **** 4821',
      referenceCode: 'TRN-METRO-902114',
      detailNote: 'Toplu taşıma bakiye yükleme. Ulaşım harcaması olarak raporlanır.',
      category: _TxCategory.ulasim,
    ),
    _TransactionEntry(
      title: 'Fon Satışı',
      dateLabel: '29 Nisan 2026, 14:32',
      amountLabel: '+₺2.250',
      isExpense: false,
      merchant: 'Akıllı Yatırım',
      paymentMethod: 'Yatırım Hesabı',
      referenceCode: 'INV-YTF-S742',
      detailNote: 'Para piyasası fonundan kısmi satış. Tutar ana hesaba aktarıldı.',
      category: _TxCategory.yatirim,
    ),
    _TransactionEntry(
      title: 'Kira Ödemesi',
      dateLabel: '28 Nisan 2026, 08:12',
      amountLabel: '-₺8.000',
      isExpense: true,
      merchant: 'Ev Sahibi · ****567',
      paymentMethod: 'FAST / IBAN',
      referenceCode: 'FAST-772910332',
      detailNote: 'Mayıs ayı kira ödemesi. Konut kategorisi.',
      category: _TxCategory.konut,
    ),
    _TransactionEntry(
      title: 'Streaming Aboneliği',
      dateLabel: '27 Nisan 2026, 03:02',
      amountLabel: '-₺149',
      isExpense: true,
      merchant: 'Dijital Platform A.Ş.',
      paymentMethod: 'Sanal Kart · **** 9034',
      referenceCode: 'SUB-RNW-49201',
      detailNote: 'Dijital içerik aboneliği. Eğlence kategorisi.',
      category: _TxCategory.eglence,
    ),
  ];

  List<_TransactionEntry> get _visible {
    Iterable<_TransactionEntry> list = _all;
    switch (_filter) {
      case _TxFilter.tumu:
        break;
      case _TxFilter.gider:
        list = list.where((e) => e.isExpense);
        break;
      case _TxFilter.gelir:
        list = list.where((e) => !e.isExpense);
        break;
    }
    if (_categoryFilter != null) {
      list = list.where((e) => e.category == _categoryFilter);
    }
    return list.toList();
  }

  void _showDetail(_TransactionEntry tx) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryAvatar(category: tx.category, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              _CategoryPill(category: tx.category),
                            ],
                          ),
                        ),
                        Text(
                          tx.amountLabel,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: tx.isExpense ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        _DetailRow(icon: Icons.category_outlined, label: 'Kategori', value: tx.category.label),
                        _DetailRow(icon: Icons.calendar_today_outlined, label: 'Tarih ve saat', value: tx.dateLabel),
                        _DetailRow(icon: Icons.storefront_outlined, label: 'İşyeri / Karşı taraf', value: tx.merchant),
                        _DetailRow(icon: Icons.payment_outlined, label: 'Ödeme yöntemi', value: tx.paymentMethod),
                        _DetailRow(icon: Icons.tag_outlined, label: 'Referans kodu', value: tx.referenceCode),
                        const SizedBox(height: 12),
                        const Text(
                          'Açıklama',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tx.detailNote,
                          style: const TextStyle(color: Color(0xFF424242), height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).padding.bottom),
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kapat'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _setFilter(_TxFilter f) {
    setState(() {
      _filter = f;
      if (f == _TxFilter.gelir) {
        _categoryFilter = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final expenseSum = _all.where((e) => e.isExpense).fold<double>(
          0,
          (s, e) => s + _parseAmount(e.amountLabel),
        );
    final incomeSum = _all.where((e) => !e.isExpense).fold<double>(
          0,
          (s, e) => s + _parseAmount(e.amountLabel),
        );

    final showCategoryBar = _filter != _TxFilter.gelir;

    return ScrollableScreenShell(
      wideBreakpoint: 900,
      children: [
        const Text('İşlem Geçmişi', style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Kayıtları süzün; satıra dokunarak detayları görün. Özet işlem listesi için Dashboard’a bakın.',
          style: AppTypography.pageSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        _SummaryStrip(expenseSum: expenseSum, incomeSum: incomeSum),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: AppDecorations.surfaceCard(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listeyi daralt', style: AppTypography.sectionTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Önce işlem tipini, istenirse harcama kategorisini seçin.',
                style: AppTypography.sectionHint,
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _FilterChip(
                    label: 'Tümü',
                    selected: _filter == _TxFilter.tumu,
                    onTap: () => _setFilter(_TxFilter.tumu),
                  ),
                  _FilterChip(
                    label: 'Sadece harcamalar',
                    selected: _filter == _TxFilter.gider,
                    onTap: () => _setFilter(_TxFilter.gider),
                  ),
                  _FilterChip(
                    label: 'Sadece gelirler',
                    selected: _filter == _TxFilter.gelir,
                    onTap: () => _setFilter(_TxFilter.gelir),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showCategoryBar) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            decoration: AppDecorations.surfaceCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori filtresi', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _filter == _TxFilter.gider
                      ? 'Seçilen kategorideki harcamaları gösterir.'
                      : 'Tüm işlemler içinden seçilen kategoriye düşenleri gösterir.',
                  style: AppTypography.sectionHint,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilterChip(
                      label: const Text('Tümü'),
                      selected: _categoryFilter == null,
                      onSelected: (_) => setState(() => _categoryFilter = null),
                      avatar: const Icon(Icons.apps_outlined, size: 18),
                    ),
                    ...[
                      _TxCategory.market,
                      _TxCategory.fatura,
                      _TxCategory.ulasim,
                      _TxCategory.eglence,
                      _TxCategory.konut,
                      _TxCategory.yatirim,
                    ].map(
                      (c) => FilterChip(
                        avatar: Icon(c.icon, size: 18),
                        label: Text(c.label),
                        selected: _categoryFilter == c,
                        onSelected: (selected) {
                          setState(() {
                            _categoryFilter = selected ? c : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(child: Text('İşlem listesi', style: AppTypography.sectionTitle)),
            Text('${visible.length} kayıt', style: AppTypography.listSubtitle),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.tile),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Column(
              children: [
                Icon(Icons.filter_alt_off_outlined, size: 40, color: Colors.black38),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Bu filtreye uygun işlem yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs + 2),
                Text(
                  'Üstteki “Tümü” veya kategori seçimini sıfırlayın.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...visible.map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                child: _TxCard(entry: tx, onTap: () => _showDetail(tx)),
              )),
      ],
    );
  }

  static double _parseAmount(String label) {
    final digits = label.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 0;
    return double.tryParse(digits) ?? 0;
  }
}

/// Liste satırında kategori avatarı.
class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category, this.size = 44});

  final _TxCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.avatarTint,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(category.icon, color: Colors.black87, size: size * 0.48),
    );
  }
}

/// Metin pill — detay başlığı altında.
class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});

  final _TxCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: category.avatarTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(category.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.expenseSum, required this.incomeSum});

  final double expenseSum;
  final double incomeSum;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: AppColors.heroDark,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Örnek dönem özeti', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  'Toplam harcama · ₺${_formatMoney(expenseSum)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toplam gelir · ₺${_formatMoney(incomeSum)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.receipt_long_outlined, color: Colors.white54, size: 36),
        ],
      ),
    );
  }

  static String _formatMoney(double v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.heroDark : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  const _TxCard({required this.entry, required this.onTap});

  final _TransactionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expense = entry.isExpense;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _CategoryAvatar(category: entry.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _CategoryPill(category: entry.category),
                        Text(
                          entry.dateLabel.split(',').first,
                          style: const TextStyle(color: Color(0xFF616161), fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFF9E9E9E)),
                        SizedBox(width: 4),
                        Text(
                          'Detay için dokunun',
                          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.amountLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: expense ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.black45, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
