import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../data/models/installment.dart';
import '../../state/app_store.dart';
import 'smart_tools_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String period = 'monthly';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final analytics = store.analytics;
    final months = _months(store.installments, period);
    final maxValue = months.isEmpty
        ? 1
        : math.max(1, months.map((e) => e.amount).fold<int>(0, (a, b) => a > b ? a : b));
    final peak = months.isEmpty
        ? const _ReportMonth('', 0, 0, 0)
        : months.reduce((a, b) => b.amount > a.amount ? b : a);

    return GlassBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
          children: [
            const Text(
              'گزارش‌ها',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'monthly', label: Text('ماهانه')),
                ButtonSegment(value: 'quarter', label: Text('سه‌ماهه')),
                ButtonSegment(value: 'yearly', label: Text('سالانه')),
              ],
              selected: {period},
              onSelectionChanged: (v) => setState(() => period = v.first),
            ),
            const SizedBox(height: 12),
            GlassCard(
              radius: 22,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmartToolsPage()),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ابزار هوشمند موعد', style: TextStyle(fontWeight: FontWeight.w900)),
                        Text(
                          'افق ۳۰ روزه، نقطه عطف پرداخت و سناریوی تسویه سریع‌تر',
                          style: TextStyle(fontSize: 9, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  RtlNextIcon(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              radius: 26,
              child: Column(
                children: [
                  const Text(
                    'مجموع پرداخت این ماه',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    money(analytics.thisMonth),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 190,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const tooltipHeight = 30.0;
                        const labelHeight = 20.0;
                        final barAreaHeight = math.max(
                          1.0,
                          constraints.maxHeight - tooltipHeight - labelHeight,
                        );

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: months.map((m) {
                            final ratio = maxValue == 0 ? 0.0 : m.amount / maxValue;
                            final barHeight = math.max(
                              10.0,
                              barAreaHeight * ratio.clamp(0.0, 1.0),
                            );
                            final isPeak = m == peak;

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: tooltipHeight,
                                      child: Center(
                                        child: isPeak && m.amount > 0
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: .05),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    compactMoney(m.amount),
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.ink,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: barHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: isPeak
                                                  ? const [
                                                      AppColors.blue,
                                                      AppColors.purple,
                                                    ]
                                                  : [
                                                      AppColors.cyan.withValues(alpha: .68),
                                                      AppColors.blue.withValues(alpha: .34),
                                                    ],
                                            ),
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(9),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: labelHeight,
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            m.label,
                                            maxLines: 1,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metric('مانده کل', compactMoney(analytics.totalRemaining))),
                const SizedBox(width: 8),
                Expanded(child: _metric('میانگین ماهانه', compactMoney(analytics.averageSixMonths))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _metric('معوق', compactMoney(analytics.overdueAmount))),
                const SizedBox(width: 8),
                Expanded(
                  child: _metric(
                    'پایان تقریبی',
                    analytics.debtFreeDate == null
                        ? 'بدون بدهی'
                        : jalaliDate(analytics.debtFreeDate!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'بیشترین اقساط ماه‌های آینده',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...([...months]..sort((a, b) => b.amount.compareTo(a.amount)))
                .take(3)
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.all(13),
                      child: Row(
                        children: [
                          Expanded(child: Text(m.label)),
                          Text(
                            money(m.amount),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            GlassCard(
              foregroundColor: AppColors.ink,
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF7FF), Color(0xFFF1EDFF)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.blue),
                      SizedBox(width: 8),
                      Text(
                        'تحلیل موعد',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...analytics.insights.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        '• $s',
                        style: const TextStyle(
                          color: Color(0xFF657694),
                          fontSize: 10,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value) => GlassCard(
        radius: 18,
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: AppColors.muted),
            ),
          ],
        ),
      );

  List<_ReportMonth> _months(List<Installment> items, String p) {
    final now = Jalali.now();
    final count = p == 'yearly' ? 12 : p == 'quarter' ? 9 : 6;
    final result = <_ReportMonth>[];
    for (var offset = 0; offset < count; offset++) {
      final total = now.year * 12 + now.month - 1 + offset;
      final y = total ~/ 12;
      final m = total % 12 + 1;
      final inMonth = items.where((e) {
        final j = Jalali.fromDateTime(e.dueDate);
        return j.year == y && j.month == m && !e.isPaid;
      });
      final amount = inMonth.fold<int>(0, (s, e) => s + e.remaining);
      result.add(_ReportMonth(jalaliMonths[m - 1], amount, y, m));
    }
    return result;
  }
}

class _ReportMonth {
  final String label;
  final int amount;
  final int year;
  final int month;
  const _ReportMonth(this.label, this.amount, this.year, this.month);
}
