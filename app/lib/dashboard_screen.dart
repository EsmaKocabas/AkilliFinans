import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'dashboard_quick_action_sheets.dart';
import 'design_preset.dart';
import 'theme/design_tokens.dart';
import 'widgets/financial_category_tile.dart';
import 'widgets/scrollable_screen_shell.dart';

/// Görev kapsamı: İşlem etkinliği + finansal kategori kartları + token ile hizalı iskelet.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.preset,
    this.onNavigateToTab,
  });

  final DesignPreset preset;

  /// Alt gezinme ile sekme geçişi (Geçmiş = 2, Yatırım = 4).
  final ValueChanged<int>? onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return ScrollableScreenShell(
      wideBreakpoint: 900,
      children: [
        const Text('Dashboard', style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Özet varlık, son harcamalar ve kategori görünümü tek yerde.',
          style: AppTypography.pageSubtitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        _PortfolioCard(accent: preset.primary),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return isWide
                ? const Row(
                    children: [
                      Expanded(child: _StatCard(title: 'Gelir', value: '₺28.450', trend: '+12%')),
                      SizedBox(width: AppSpacing.md),
                      Expanded(child: _StatCard(title: 'Gider', value: '₺14.980', trend: '-4%')),
                      SizedBox(width: AppSpacing.md),
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
                  );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const _StaticActivitySection(),
        const SizedBox(height: AppSpacing.md),
        const _FinancialCategoriesSection(),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Hızlı Eylemler',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionChip(
                icon: Icons.add_card,
                label: 'Para Yatır',
                onPressed: () => DashboardQuickActionSheets.showParaYatir(context),
              ),
              _QuickActionChip(
                icon: Icons.send_outlined,
                label: 'Transfer',
                onPressed: () => DashboardQuickActionSheets.showTransfer(context),
              ),
              _QuickActionChip(
                icon: Icons.receipt_long_outlined,
                label: 'Fatura Öde',
                onPressed: () => DashboardQuickActionSheets.showFaturaOde(
                  context,
                  navigateToTab: onNavigateToTab ?? (_) {},
                ),
              ),
              _QuickActionChip(
                icon: Icons.savings_outlined,
                label: 'Hedef Oluştur',
                onPressed: () => DashboardQuickActionSheets.showHedefOlustur(
                  context,
                  navigateToTab: onNavigateToTab ?? (_) {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
  }
}

/// Sabit örnek harcamalar — backend yok (yalnızca UI).
class _StaticActivitySection extends StatelessWidget {
  const _StaticActivitySection();

  static const List<_StaticActivityRow> _rows = [
    _StaticActivityRow(
      titleLine: 'Market - 250 ₺',
      subtitle: 'Bugün · Kart ile ödeme',
      icon: Icons.shopping_basket_outlined,
      sheetTitle: 'Market işlemi',
      categoryLabel: 'Market',
      dateLabel: '2 Mayıs 2026, 09:41',
      amountLabel: '-₺250',
      isExpense: true,
      merchant: 'Çarşı Market · Kadıköy',
      paymentMethod: 'Temassız Kart · **** 4821',
      referenceCode: 'DASH-TXN-MK8842',
      detailNote:
          'Gıda ve kişisel bakım kalemleri. Dashboard işlem etkinliği kartından açılan örnek detay; fiş OCR ile tahmini kategori.',
    ),
    _StaticActivityRow(
      titleLine: 'Fatura - 450 ₺',
      subtitle: 'Dün · Otomatik ödeme',
      icon: Icons.receipt_long_outlined,
      sheetTitle: 'Elektrik faturası',
      categoryLabel: 'Fatura',
      dateLabel: '1 Mayıs 2026, 08:05',
      amountLabel: '-₺450',
      isExpense: true,
      merchant: 'Şehir Dağıtım A.Ş.',
      paymentMethod: 'Otomatik ödeme talimatı',
      referenceCode: 'FT-DASH-99102',
      detailNote: 'Nisan dönemi tüketim faturası. Otomatik ödemeden düşüm.',
    ),
    _StaticActivityRow(
      titleLine: 'Ulaşım - 120 ₺',
      subtitle: 'Dün · Toplu taşıma',
      icon: Icons.directions_bus_outlined,
      sheetTitle: 'Ulaşım',
      categoryLabel: 'Ulaşım',
      dateLabel: '1 Mayıs 2026, 07:52',
      amountLabel: '-₺120',
      isExpense: true,
      merchant: 'İstanbul Kart · Marmaray istasyonu',
      paymentMethod: 'NFC · QR',
      referenceCode: 'METRO-QR-77421',
      detailNote: 'Günlük yol geçişi ve bakiye yüklemesi.',
    ),
    _StaticActivityRow(
      titleLine: 'Eğlence - 89 ₺',
      subtitle: '26 Nisan · Abonelik',
      icon: Icons.theaters_outlined,
      sheetTitle: 'Eğlence aboneliği',
      categoryLabel: 'Eğlence',
      dateLabel: '26 Nisan 2026, 03:05',
      amountLabel: '-₺89',
      isExpense: true,
      merchant: 'Dijital Yayın Servisi',
      paymentMethod: 'Sanal Kart · **** 9034',
      referenceCode: 'SUB-DASH-E441',
      detailNote: 'Aylık dijital içerik aboneliği yenilemesi.',
    ),
    _StaticActivityRow(
      titleLine: 'Yatırım - 5.000 ₺',
      subtitle: '25 Nisan · Fon alımı',
      icon: Icons.trending_up_outlined,
      sheetTitle: 'Fon alımı',
      categoryLabel: 'Yatırım',
      dateLabel: '25 Nisan 2026, 14:20',
      amountLabel: '-₺5.000',
      isExpense: true,
      merchant: 'Akıllı Yatırım Portföy Yönetimi',
      paymentMethod: 'Ana Hesap · TL',
      referenceCode: 'INV-DASH-Y112',
      detailNote:
          'Birinci seri sermaye koruma fonundan alım. Ana hesaptan blokaj kaldırıldı.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.surfaceCard(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İşlem etkinliği', style: AppTypography.sectionTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Son finansal hareketler (örnek liste; şimdilik sabit veri).',
                  style: AppTypography.sectionHint,
                ),
              ],
            ),
          ),
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 72),
            ListTile(
              onTap: () => _showDashboardActivityDetail(context, _rows[i]),
              leading: CircleAvatar(
                backgroundColor: AppColors.chipBackground,
                child: Icon(_rows[i].icon, color: AppColors.textPrimary),
              ),
              title: Text(_rows[i].titleLine, style: AppTypography.listTitle),
              subtitle: Text(_rows[i].subtitle, style: AppTypography.listSubtitle),
              trailing: const Icon(Icons.chevron_right, color: Colors.black38),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

void _showDashboardActivityDetail(BuildContext context, _StaticActivityRow row) {
  final bottom = MediaQuery.paddingOf(context).bottom;
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
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.chipBackground,
                        child: Icon(row.icon, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.sheetTitle,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            _ActivityCategoryChip(label: row.categoryLabel),
                          ],
                        ),
                      ),
                      Text(
                        row.amountLabel,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: row.isExpense ? Colors.red.shade700 : Colors.green.shade700,
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
                      _DashboardActivityDetailRow(
                        icon: Icons.category_outlined,
                        label: 'Kategori',
                        value: row.categoryLabel,
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tarih ve saat',
                        value: row.dateLabel,
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.storefront_outlined,
                        label: 'İşyeri / Karşı taraf',
                        value: row.merchant,
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.payment_outlined,
                        label: 'Ödeme yöntemi',
                        value: row.paymentMethod,
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.tag_outlined,
                        label: 'Referans kodu',
                        value: row.referenceCode,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Açıklama',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        row.detailNote,
                        style: const TextStyle(color: Color(0xFF424242), height: 1.45),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
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

class _ActivityCategoryChip extends StatelessWidget {
  const _ActivityCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.label_outline, size: 14, color: AppColors.textPrimary.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.listSubtitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardActivityDetailRow extends StatelessWidget {
  const _DashboardActivityDetailRow({
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

class _StaticActivityRow {
  const _StaticActivityRow({
    required this.titleLine,
    required this.subtitle,
    required this.icon,
    required this.sheetTitle,
    required this.categoryLabel,
    required this.dateLabel,
    required this.amountLabel,
    required this.isExpense,
    required this.merchant,
    required this.paymentMethod,
    required this.referenceCode,
    required this.detailNote,
  });

  final String titleLine;
  final String subtitle;
  final IconData icon;
  final String sheetTitle;
  final String categoryLabel;
  final String dateLabel;
  final String amountLabel;
  final bool isExpense;
  final String merchant;
  final String paymentMethod;
  final String referenceCode;
  final String detailNote;
}

enum _SpendQuickFilter { tumu, market, fatura, ulasim }

class _MonthlySpendSlice {
  const _MonthlySpendSlice({
    required this.filter,
    required this.label,
    required this.amountTry,
    required this.icon,
    required this.chartColor,
  });

  final _SpendQuickFilter filter;
  final String label;
  final double amountTry;
  final IconData icon;
  final Color chartColor;
}

/// Aylık harcama pastası + hızlı kategori şeridi (demo veri).
class _FinancialCategoriesSection extends StatefulWidget {
  const _FinancialCategoriesSection();

  @override
  State<_FinancialCategoriesSection> createState() => _FinancialCategoriesSectionState();
}

class _FinancialCategoriesSectionState extends State<_FinancialCategoriesSection> {
  static const List<_MonthlySpendSlice> _chartSlices = [
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.market,
      label: 'Market',
      amountTry: 4960,
      icon: Icons.shopping_basket_outlined,
      chartColor: Color(0xFF263238),
    ),
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.fatura,
      label: 'Fatura',
      amountTry: 4340,
      icon: Icons.receipt_long_outlined,
      chartColor: Color(0xFF546E7A),
    ),
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.ulasim,
      label: 'Ulaşım',
      amountTry: 3100,
      icon: Icons.directions_bus_outlined,
      chartColor: Color(0xFF90A4AE),
    ),
  ];

  /// Şeritteki ilk öğe: Tümü; ardından pastadaki sıra ile uyumlu kategoriler.
  static List<({String label, IconData icon, _SpendQuickFilter filter})> get _quickItems => [
        (label: 'Tümü', icon: Icons.pie_chart_outline_rounded, filter: _SpendQuickFilter.tumu),
        for (final s in _chartSlices)
          (label: s.label, icon: s.icon, filter: s.filter),
      ];

  _SpendQuickFilter _selected = _SpendQuickFilter.tumu;

  double _totalSpend() => _chartSlices.fold<double>(0, (a, s) => a + s.amountTry);

  int? _focusedSliceIndex() {
    switch (_selected) {
      case _SpendQuickFilter.tumu:
        return null;
      case _SpendQuickFilter.market:
        return 0;
      case _SpendQuickFilter.fatura:
        return 1;
      case _SpendQuickFilter.ulasim:
        return 2;
    }
  }

  double _sectionRadius(int sliceIndex, int? focusedIdx) {
    const base = 52.0;
    if (focusedIdx == null) return base;
    return sliceIndex == focusedIdx ? base + 10 : base - 10;
  }

  Widget _pie(double side) {
    final focused = _focusedSliceIndex();
    return SizedBox(
      width: side,
      height: side,
      child: PieChart(
        PieChartData(
          startDegreeOffset: -90,
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: side * 0.34,
          sections: [
            for (var i = 0; i < _chartSlices.length; i++)
              PieChartSectionData(
                color: _chartSlices[i].chartColor,
                value: _chartSlices[i].amountTry,
                showTitle: false,
                radius: _sectionRadius(i, focused),
              ),
          ],
        ),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    final total = _totalSpend();
    final focus = _focusedSliceIndex();

    Widget row(_MonthlySpendSlice s, int i) {
      final pct = total > 0 ? (100 * s.amountTry / total) : 0.0;
      final dimmed = focus != null && focus != i;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: s.chartColor.withValues(alpha: dimmed ? 0.38 : 1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Icon(s.icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: dimmed ? 0.42 : 0.74)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: dimmed ? 0.45 : 1),
                    ),
                  ),
                  Text(
                    '${_fmtTry(s.amountTry)} · %${pct.toStringAsFixed(1)}',
                    style: AppTypography.listSubtitle.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: dimmed ? 0.5 : 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _chartSlices.length; i++) row(_chartSlices[i], i),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalSpend();
    final filterHint = switch (_selected) {
      _SpendQuickFilter.tumu => 'Ayın tamamına ait üç kategori dağılımı gösteriliyor.',
      _SpendQuickFilter.market => 'Şu anda yalnızca Market dilimi vurgulandı (demo süzüm).',
      _SpendQuickFilter.fatura => 'Şu anda yalnızca Fatura dilimi vurgulandı (demo süzüm).',
      _SpendQuickFilter.ulasim => 'Şu anda yalnızca Ulaşım dilimi vurgulandı (demo süzüm).',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: AppDecorations.surfaceCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finansal kategoriler', style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bu ayın toplam harcamalarınızın Market, Fatura ve Ulaşım dağılımı; pastada özet, altta hızlı süzüm.',
            style: AppTypography.sectionHint,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Harcama grafiği', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, c) {
              final chartSide = (c.maxWidth >= 560 ? 168.0 : 176.0).clamp(148.0, 188.0);
              final wide = c.maxWidth >= 560;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _pie(chartSide),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _legend(context)),
                  ],
                );
              }
              return Column(
                children: [
                  Center(child: _pie(chartSide)),
                  const SizedBox(height: AppSpacing.md),
                  _legend(context),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              'Aylık toplam harcama (örnek): ${_fmtTry(total)}',
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Hızlı kategori butonları', style: AppTypography.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _quickItems.length; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i < _quickItems.length - 1 ? AppSpacing.sm : 0),
                    child: FinancialCategoryTile(
                      label: _quickItems[i].label,
                      icon: _quickItems[i].icon,
                      compact: true,
                      selected: _selected == _quickItems[i].filter,
                      onTap: () => setState(() => _selected = _quickItems[i].filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(filterHint, style: AppTypography.caption),
        ],
      ),
    );
  }
}

String _fmtTry(double amount) {
  final abs = amount.round().abs().toString();
  final sb = StringBuffer(amount < 0 ? '-₺' : '₺');
  for (var i = 0; i < abs.length; i++) {
    if (i > 0 && (abs.length - i) % 3 == 0) sb.write('.');
    sb.write(abs[i]);
  }
  return sb.toString();
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.heroDark,
        borderRadius: BorderRadius.circular(AppRadii.card),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.surfaceCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.md),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        '$title\n$value\n$trend',
        style: const TextStyle(height: 1.45, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.textPrimary),
      label: Text(label),
      elevation: 0,
      shadowColor: Colors.transparent,
      side: const BorderSide(color: AppColors.borderSubtle),
      backgroundColor: AppColors.chipBackground,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
        backgroundColor: AppColors.chipBackground,
        child: Icon(isPositive ? Icons.arrow_downward : Icons.arrow_upward, color: AppColors.textPrimary),
      ),
      title: Text(title, style: AppTypography.listTitle),
      subtitle: Text(date, style: AppTypography.listSubtitle),
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
