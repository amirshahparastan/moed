import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../state/app_store.dart';

class SmartToolsPage extends StatefulWidget {
  const SmartToolsPage({super.key});

  @override
  State<SmartToolsPage> createState() => _SmartToolsPageState();
}

class _SmartToolsPageState extends State<SmartToolsPage> {
  final extra = TextEditingController();

  @override
  void dispose() {
    extra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final analytics = store.analytics;
    final extraValue = parseMoney(extra.text);
    final int baseMonthly = analytics.averageSixMonths <= 0 ? 1 : analytics.averageSixMonths;
    final currentMonths = analytics.totalRemaining == 0
        ? 0
        : (analytics.totalRemaining / baseMonthly).ceil();
    final boostedMonthly = baseMonthly + extraValue;
    final boostedMonths = analytics.totalRemaining == 0
        ? 0
        : (analytics.totalRemaining / boostedMonthly).ceil();
    final diffMonths = currentMonths - boostedMonths;
    final int savedMonths = diffMonths < 0 ? 0 : diffMonths;
    final projected = boostedMonths == 0
        ? DateTime.now()
        : addJalaliMonths(DateTime.now(), boostedMonths);

    final progress = store.overallProgress;
    final percent = (progress * 100).round();
    final nextMilestone = percent < 25
        ? 25
        : percent < 50
            ? 50
            : percent < 75
                ? 75
                : 100;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: const RtlBackButton(),
        title: const Text('ابزار هوشمند موعد'),
      ),
      body: GlassBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              GlassCard(
                radius: 24,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF7FF), Color(0xFFF2EEFF)],
                ),
                foregroundColor: AppColors.ink,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.blue),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('افق ۳۰ روز آینده', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(
                            '${toPersianDigits(store.dueNext30Days.length)} قسط • ${money(store.dueNext30Amount)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF657694)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                radius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined, color: AppColors.purple),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('نقطه عطف پرداخت', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        Text('${toPersianDigits(percent)}٪', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nextMilestone == 100
                          ? 'هدف بعدی: تسویه کامل همه تعهدها.'
                          : 'هدف بعدی: رسیدن به ${toPersianDigits(nextMilestone)}٪ پرداخت کل.',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'سناریوی تسویه سریع‌تر',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              const Text(
                'ببین اگر هر ماه مبلغ بیشتری برای اقساط کنار بگذاری، به‌صورت تخمینی چند ماه زودتر از بدهی خارج می‌شوی.',
                style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: extra,
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'پرداخت اضافه ماهانه (تومان)',
                  hintText: 'مثلاً 5,000,000',
                  prefixIcon: Icon(Icons.add_card_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              GlassCard(
                radius: 22,
                child: Column(
                  children: [
                    _row('مانده فعلی', money(analytics.totalRemaining)),
                    _row('میانگین تعهد ماهانه', money(baseMonthly)),
                    _row('زمان تخمینی فعلی', '${toPersianDigits(currentMonths)} ماه'),
                    _row(
                      'با پرداخت اضافه',
                      extraValue <= 0 ? 'مبلغی وارد نشده' : '${toPersianDigits(boostedMonths)} ماه',
                    ),
                    _row(
                      'زمان ذخیره‌شده',
                      extraValue <= 0 ? '—' : '${toPersianDigits(savedMonths)} ماه',
                      highlight: true,
                    ),
                    if (extraValue > 0)
                      _row('پایان تخمینی جدید', jalaliDate(projected)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'این محاسبه یک سناریوی مدیریتی بر اساس داده‌های ثبت‌شده است و سود، جریمه یا قواعد تسویه بانک را محاسبه نمی‌کند.',
                style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value, {bool highlight = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ),
            Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: highlight ? AppColors.blue : null,
              ),
            ),
          ],
        ),
      );
}
