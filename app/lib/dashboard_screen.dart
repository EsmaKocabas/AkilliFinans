import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import 'app_navigation.dart';
import 'dashboard_quick_action_sheets.dart';
import 'design_preset.dart';
import 'services/session_service.dart';
import 'theme/design_tokens.dart';
import 'widgets/financial_category_tile.dart';
import 'widgets/scrollable_screen_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.preset,
    this.onNavigateToTab,
  });

  final DesignPreset preset;
  final ValueChanged<AppTab>? onNavigateToTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  double _totalAsset = 0.0;
  double _income = 0.0;
  double _expense = 0.0;
  double _savings = 0.0;
  Map<String, double> _categoryDistribution = {'Market': 0.0, 'Fatura': 0.0, 'Ulaşım': 0.0};
  List<dynamic> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    AppSession.instance.addListener(_onBudgetChanged);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    AppSession.instance.removeListener(_onBudgetChanged);
    super.dispose();
  }

  void _onBudgetChanged() {
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final statsUrl = Uri.parse('${AppSession.baseUrl}/api/dashboard/stats');
      final txsUrl = Uri.parse('${AppSession.baseUrl}/api/transactions');

      final statsResponse = await http.get(statsUrl, headers: session.headers);
      final txsResponse = await http.get(txsUrl, headers: session.headers);

      if (statsResponse.statusCode == 200 && txsResponse.statusCode == 200) {
        final statsBody = jsonDecode(statsResponse.body)['data'];
        final txsBody = jsonDecode(txsResponse.body)['data'];

        if (mounted) {
          setState(() {
            _totalAsset = (statsBody['totalAsset'] as num).toDouble();
            
            // Proactively sync session budget so other listening widgets update
            if (session.budget != _totalAsset) {
              session.updateBudget(_totalAsset);
            }

            _income = (statsBody['income'] as num).toDouble();
            _expense = (statsBody['expense'] as num).toDouble();
            _savings = (statsBody['savings'] as num).toDouble();

            final dist = statsBody['categoryDistribution'] as Map<String, dynamic>;
            _categoryDistribution = dist.map((k, v) => MapEntry(k, (v as num).toDouble()));

            _recentTransactions = txsBody;
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Bütçe istatistikleri alınamadı (Kod: ${statsResponse.statusCode})';
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
                onPressed: () {
                  setState(() => _isLoading = true);
                  _fetchDashboardData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

    return Consumer<AppSession>(
      builder: (context, session, _) {
        final currentBudget = session.budget;
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
            _PortfolioCard(accent: widget.preset.primary, budget: currentBudget),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final incomeStr = '₺${_income.round()}';
                final expenseStr = '₺${_expense.round()}';
                final savingsStr = '₺${_savings.round()}';

                return isWide
                    ? Row(
                        children: [
                          Expanded(child: _StatCard(title: 'Gelir', value: incomeStr, trend: '+12%')),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _StatCard(title: 'Gider', value: expenseStr, trend: '-4%')),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _StatCard(title: 'Tasarruf', value: savingsStr, trend: '+18%')),
                        ],
                      )
                    : Column(
                        children: [
                          _StatCard(title: 'Gelir', value: incomeStr, trend: '+12%'),
                          const SizedBox(height: 10),
                          _StatCard(title: 'Gider', value: expenseStr, trend: '-4%'),
                          const SizedBox(height: 10),
                          _StatCard(title: 'Tasarruf', value: savingsStr, trend: '+18%'),
                        ],
                      );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _ActivitySection(transactions: _recentTransactions),
            const SizedBox(height: AppSpacing.md),
            _FinancialCategoriesSection(distribution: _categoryDistribution),
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
                      navigateToTab: widget.onNavigateToTab ?? (_) {},
                    ),
                  ),
                  _QuickActionChip(
                    icon: Icons.savings_outlined,
                    label: 'Hedef Oluştur',
                    onPressed: () => DashboardQuickActionSheets.showHedefOlustur(
                      context,
                      navigateToTab: widget.onNavigateToTab ?? (_) {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Son İşlemler',
              child: Column(
                children: [
                  if (_recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Henüz bir finansal işlem bulunmuyor.', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ..._recentTransactions.take(3).map((tx) {
                      final isPositive = (tx['amount'] as num) > 0;
                      final sign = isPositive ? '+' : '-';
                      final amountVal = (tx['amount'] as num).abs().round();
                      return _TransactionRow(
                        title: tx['title'] ?? 'Bilinmeyen İşlem',
                        date: tx['date'] ?? '',
                        amount: '$sign₺$amountVal',
                      );
                    }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.transactions});

  final List<dynamic> transactions;

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'market':
        return Icons.shopping_basket_outlined;
      case 'fatura':
        return Icons.receipt_long_outlined;
      case 'ulaşım':
      case 'ulasim':
        return Icons.directions_bus_outlined;
      case 'eğlence':
      case 'eglence':
        return Icons.theaters_outlined;
      case 'yatırım':
      case 'yatirim':
        return Icons.trending_up_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Limit list to last 5 transactions
    final items = transactions.take(5).toList();

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
                  'Son finansal hareketler (canlı veritabanı verileri).',
                  style: AppTypography.sectionHint,
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Henüz işlem bulunmuyor.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 72),
              ListTile(
                onTap: () => _showDashboardActivityDetail(context, items[i], _categoryIcon(items[i]['category'] ?? '')),
                leading: CircleAvatar(
                  backgroundColor: AppColors.chipBackground,
                  child: Icon(_categoryIcon(items[i]['category'] ?? ''), color: AppColors.textPrimary),
                ),
                title: Text(
                  '${items[i]['title']} - ₺${(items[i]['amount'] as num).abs().round()}',
                  style: AppTypography.listTitle,
                ),
                subtitle: Text(
                  '${items[i]['date']} · ${items[i]['paymentMethod'] ?? 'Kart'}',
                  style: AppTypography.listSubtitle,
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.black38),
              ),
            ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

void _showDashboardActivityDetail(BuildContext context, Map<String, dynamic> row, IconData icon) {
  final bottom = MediaQuery.paddingOf(context).bottom;
  final amountVal = (row['amount'] as num).toDouble();
  final isExpense = amountVal < 0;

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
                        child: Icon(icon, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row['title'] ?? '',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            _ActivityCategoryChip(label: row['category'] ?? 'Genel'),
                          ],
                        ),
                      ),
                      Text(
                        '${isExpense ? '-' : '+'}₺${amountVal.abs().round()}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isExpense ? Colors.red.shade700 : Colors.green.shade700,
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
                        value: row['category'] ?? 'Genel',
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tarih ve saat',
                        value: row['date'] ?? '',
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.storefront_outlined,
                        label: 'İşyeri / Karşı taraf',
                        value: row['merchant'] ?? '',
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.payment_outlined,
                        label: 'Ödeme yöntemi',
                        value: row['paymentMethod'] ?? 'Kart',
                      ),
                      _DashboardActivityDetailRow(
                        icon: Icons.tag_outlined,
                        label: 'Referans kodu',
                        value: row['referenceCode'] ?? '',
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
              Icon(Icons.label_outline, size: 14, color: AppColors.textPrimary.withOpacity(0.7)),
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

class _FinancialCategoriesSection extends StatefulWidget {
  const _FinancialCategoriesSection({required this.distribution});

  final Map<String, double> distribution;

  @override
  State<_FinancialCategoriesSection> createState() => _FinancialCategoriesSectionState();
}

class _FinancialCategoriesSectionState extends State<_FinancialCategoriesSection> {
  _SpendQuickFilter _selected = _SpendQuickFilter.tumu;

  List<_MonthlySpendSlice> get _chartSlices => [
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.market,
      label: 'Market',
      amountTry: widget.distribution['Market'] ?? 0.0,
      icon: Icons.shopping_basket_outlined,
      chartColor: const Color(0xFF263238),
    ),
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.fatura,
      label: 'Fatura',
      amountTry: widget.distribution['Fatura'] ?? 0.0,
      icon: Icons.receipt_long_outlined,
      chartColor: const Color(0xFF546E7A),
    ),
    _MonthlySpendSlice(
      filter: _SpendQuickFilter.ulasim,
      label: 'Ulaşım',
      amountTry: widget.distribution['Ulaşım'] ?? widget.distribution['Ulasim'] ?? 0.0,
      icon: Icons.directions_bus_outlined,
      chartColor: const Color(0xFF90A4AE),
    ),
  ];

  List<({String label, IconData icon, _SpendQuickFilter filter})> get _quickItems => [
    (label: 'Tümü', icon: Icons.pie_chart_outline_rounded, filter: _SpendQuickFilter.tumu),
    for (final s in _chartSlices)
      (label: s.label, icon: s.icon, filter: s.filter),
  ];

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
    final total = _totalSpend();
    
    // Fallback if spend is zero, render a grey circle
    if (total == 0) {
      return SizedBox(
        width: side,
        height: side,
        child: PieChart(
          PieChartData(
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: side * 0.34,
            sections: [
              PieChartSectionData(
                color: Colors.grey.shade300,
                value: 100,
                showTitle: false,
                radius: 52,
              )
            ],
          ),
        ),
      );
    }

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
                value: _chartSlices[i].amountTry == 0 ? 0.0001 : _chartSlices[i].amountTry, // prevent zero division inside chart
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
                color: s.chartColor.withOpacity(dimmed ? 0.38 : 1),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Icon(s.icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(dimmed ? 0.42 : 0.74)),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(dimmed ? 0.45 : 1),
                    ),
                  ),
                  Text(
                    '${_fmtTry(s.amountTry)} · %${pct.toStringAsFixed(1)}',
                    style: AppTypography.listSubtitle.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted.withOpacity(dimmed ? 0.5 : 1),
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
  const _PortfolioCard({required this.accent, required this.budget});

  final Color accent;
  final double budget;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Toplam Varlık', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  '₺${budget.round()}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28),
                ),
                const SizedBox(height: 6),
                const Text('+₺8.240 bu ay', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: accent.withOpacity(0.25),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trend.startsWith('+') ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              trend,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: trend.startsWith('+') ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
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
