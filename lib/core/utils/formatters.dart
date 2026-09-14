import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';

const _fa = '۰۱۲۳۴۵۶۷۸۹';
const _en = '0123456789';

String toPersianDigits(Object value) {
  var s = value.toString();
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(_en[i], _fa[i]);
  }
  return s;
}

String toEnglishDigits(String value) {
  var s = value;
  for (var i = 0; i < 10; i++) {
    s = s.replaceAll(_fa[i], _en[i]);
  }
  return s;
}

String _groupThousands(String digits, {String separator = ','}) {
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// نمایش عدد ورودی مالی به شکل 12,500,000 هنگام تایپ.
/// ارقام فارسی/انگلیسی را می‌پذیرد و فقط برای خوانایی جداکننده می‌گذارد.
String formatMoneyInput(Object value) {
  final raw = toEnglishDigits(value.toString()).replaceAll(RegExp(r'[^0-9]'), '');
  if (raw.isEmpty) return '';
  final normalized = raw.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  return _groupThousands(normalized);
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatMoneyInput(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String money(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final grouped = _groupThousands(digits, separator: '٬');
  return '${negative ? '−' : ''}${toPersianDigits(grouped)} تومان';
}

String compactMoney(int value) {
  if (value >= 1000000000) {
    return '${toPersianDigits((value / 1000000000).toStringAsFixed(value % 1000000000 == 0 ? 0 : 1))} میلیارد';
  }
  if (value >= 1000000) {
    return '${toPersianDigits((value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1))} میلیون';
  }
  return money(value);
}

int parseMoney(String value) {
  final normalized = toEnglishDigits(value).replaceAll(RegExp(r'[^0-9-]'), '');
  return int.tryParse(normalized) ?? 0;
}

const jalaliMonths = [
  'فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور',
  'مهر','آبان','آذر','دی','بهمن','اسفند'
];
const weekDays = [
  'شنبه','یکشنبه','دوشنبه','سه‌شنبه','چهارشنبه','پنجشنبه','جمعه'
];

String jalaliDate(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  return '${toPersianDigits(j.day)} ${jalaliMonths[j.month - 1]} ${toPersianDigits(j.year)}';
}

String jalaliShort(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  return '${toPersianDigits(j.year)}/${toPersianDigits(j.month.toString().padLeft(2,'0'))}/${toPersianDigits(j.day.toString().padLeft(2,'0'))}';
}

String jalaliMonthKey(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  return '${j.year}-${j.month}';
}

DateTime addJalaliMonths(DateTime start, int months) {
  final j = Jalali.fromDateTime(start);
  final total = j.year * 12 + (j.month - 1) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final maxDay = Jalali(year, month, 1).monthLength;
  final day = j.day > maxDay ? maxDay : j.day;
  return Jalali(year, month, day).toDateTime();
}

String relativeDue(DateTime due) {
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(due.year, due.month, due.day);
  final d = b.difference(a).inDays;
  if (d == 0) return 'امروز';
  if (d == 1) return 'فردا';
  if (d < 0) return '${toPersianDigits(d.abs())} روز گذشته';
  return '${toPersianDigits(d)} روز دیگر';
}
