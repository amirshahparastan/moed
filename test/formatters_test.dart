import 'package:flutter_test/flutter_test.dart';
import 'package:moed/core/utils/formatters.dart';

void main() {
  test('persian money parser accepts Persian digits', () {
    expect(parseMoney('۱۲٬۵۰۰٬۰۰۰ تومان'), 12500000);
  });
  test('jalali monthly schedule stays in calendar', () {
    final d = DateTime(2026, 9, 14);
    expect(addJalaliMonths(d, 1).isAfter(d), isTrue);
  });
}
