import 'package:flutter_test/flutter_test.dart';
import 'package:moed/data/models/installment.dart';
import 'package:moed/services/analytics_service.dart';

void main() {
  test('analytics calculates remaining debt and overdue', () {
    final now = DateTime.now();
    final items = [
      Installment(id:1,loanId:1,sequence:1,dueDate:now.subtract(const Duration(days:2)),amount:1000000,paidAmount:200000,status:'partial'),
      Installment(id:2,loanId:1,sequence:2,dueDate:now.add(const Duration(days:20)),amount:1000000,paidAmount:0,status:'pending'),
    ];
    final a = AnalyticsService().calculate(items);
    expect(a.totalRemaining, 1800000);
    expect(a.overdueCount, 1);
    expect(a.overdueAmount, 800000);
  });
}
