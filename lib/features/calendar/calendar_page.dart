import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../state/app_store.dart';
import '../loans/loan_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Jalali shown;
  Jalali? selected;

  @override
  void initState() {
    super.initState();
    final Jalali now = Jalali.now();
    shown = Jalali(now.year, now.month, 1);
    selected = now;
  }

  @override
  Widget build(BuildContext context) {
    final AppStore store = context.watch<AppStore>();
    final int firstOffset = (shown.toDateTime().weekday + 1) % 7;
    final int monthLength = shown.monthLength;

    final selectedItems = selected == null
        ? <dynamic>[]
        : store.installments.where((item) {
            final Jalali j = Jalali.fromDateTime(item.dueDate);
            return j.year == selected!.year &&
                j.month == selected!.month &&
                j.day == selected!.day;
          }).toList();

    return GlassBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            const Text(
              'تقویم اقساط',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Text(
                          '${jalaliMonths[shown.month - 1]} ${toPersianDigits(shown.year)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            tooltip: 'ماه قبل',
                            onPressed: () => move(-1),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.blue.withValues(alpha: .08),
                            ),
                            icon: const RtlPreviousMonthIcon(),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: IconButton(
                            tooltip: 'ماه بعد',
                            onPressed: () => move(1),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.blue.withValues(alpha: .08),
                            ),
                            icon: const RtlNextMonthIcon(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <String>['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                        .map(
                          (String label) => Expanded(
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                    ),
                    itemCount: firstOffset + monthLength,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < firstOffset) {
                        return const SizedBox();
                      }

                      final int day = index - firstOffset + 1;
                      final Jalali date = Jalali(
                        shown.year,
                        shown.month,
                        day,
                      );

                      final items = store.installments.where((item) {
                        final Jalali itemDate =
                            Jalali.fromDateTime(item.dueDate);
                        return itemDate.year == date.year &&
                            itemDate.month == date.month &&
                            itemDate.day == date.day;
                      }).toList();

                      final bool active = selected?.year == date.year &&
                          selected?.month == date.month &&
                          selected?.day == date.day;
                      final bool hasOverdue =
                          items.any((item) => item.isOverdue);
                      final bool allPaid = items.isNotEmpty &&
                          items.every((item) => item.isPaid);

                      return InkWell(
                        onTap: () => setState(() => selected = date),
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.blue.withValues(alpha: .16)
                                : null,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                toPersianDigits(day),
                                style: TextStyle(
                                  fontWeight:
                                      active ? FontWeight.w900 : null,
                                ),
                              ),
                              if (items.isNotEmpty)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasOverdue
                                        ? AppColors.danger
                                        : allPaid
                                            ? AppColors.success
                                            : AppColors.purple,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.success, label: 'پرداخت‌شده'),
                      SizedBox(width: 12),
                      _LegendDot(color: AppColors.purple, label: 'در انتظار'),
                      SizedBox(width: 12),
                      _LegendDot(color: AppColors.danger, label: 'معوق'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selected == null
                  ? ''
                  : 'سررسیدهای ${jalaliDate(selected!.toDateTime())}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            if (selectedItems.isEmpty)
              const GlassCard(
                child: Text('برای این روز قسطی ثبت نشده است'),
              )
            else
              ...selectedItems.map(
                (item) {
                  final loan = store.loanById(item.loanId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => LoanDetailPage(
                            loanId: item.loanId,
                          ),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.isPaid
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: item.isPaid
                                ? AppColors.success
                                : AppColors.blue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(loan?.title ?? '')),
                          Text(money(item.remaining)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void move(int delta) {
    final int total = shown.year * 12 + shown.month - 1 + delta;
    setState(() {
      shown = Jalali(total ~/ 12, total % 12 + 1, 1);
    });
  }
}


class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      );
}
