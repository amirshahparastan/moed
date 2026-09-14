import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/rtl_navigation.dart';

Future<DateTime?> showJalaliPicker(
  BuildContext context, {
  required DateTime initial,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _JalaliPicker(initial: Jalali.fromDateTime(initial)),
  );
}

class _JalaliPicker extends StatefulWidget {
  final Jalali initial;
  const _JalaliPicker({required this.initial});

  @override
  State<_JalaliPicker> createState() => _JalaliPickerState();
}

class _JalaliPickerState extends State<_JalaliPicker> {
  late Jalali shown;
  late Jalali selected;

  @override
  void initState() {
    super.initState();
    shown = Jalali(widget.initial.year, widget.initial.month, 1);
    selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final int firstWeekday = (shown.toDateTime().weekday + 1) % 7;
    final int len = shown.monthLength;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      title: SizedBox(
        width: double.infinity,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${jalaliMonths[shown.month - 1]} ${toPersianDigits(shown.year)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                tooltip: 'ماه قبل',
                onPressed: () => _move(-1),
                icon: const RtlPreviousMonthIcon(),
              ),
            ),
            Positioned(
              left: 0,
              child: IconButton(
                tooltip: 'ماه بعد',
                onPressed: () => _move(1),
                icon: const RtlNextMonthIcon(),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                  .map(
                    (e) => Expanded(
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: firstWeekday + len,
              itemBuilder: (_, i) {
                if (i < firstWeekday) return const SizedBox();
                final day = i - firstWeekday + 1;
                final active = selected.year == shown.year &&
                    selected.month == shown.month &&
                    selected.day == day;

                return InkWell(
                  onTap: () => setState(
                    () => selected = Jalali(shown.year, shown.month, day),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: active ? AppColors.blue : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        toPersianDigits(day),
                        style: TextStyle(
                          color: active ? Colors.white : null,
                          fontWeight: active ? FontWeight.w800 : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, selected.toDateTime()),
          child: const Text('تأیید'),
        ),
      ],
    );
  }

  void _move(int delta) {
    final int total = shown.year * 12 + shown.month - 1 + delta;
    setState(() {
      shown = Jalali(total ~/ 12, total % 12 + 1, 1);
    });
  }
}
