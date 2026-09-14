import 'package:shamsi_date/shamsi_date.dart';
import '../data/models/installment.dart';
import '../core/utils/formatters.dart';

class MonthStat { final int year, month, total, unpaid, paid; const MonthStat(this.year,this.month,this.total,this.unpaid,this.paid); String get label => jalaliMonths[month-1]; }
class AnalyticsSnapshot {
  final int totalRemaining, thisMonth, nextMonth, overdueAmount, overdueCount, averageSixMonths;
  final DateTime? debtFreeDate; final List<MonthStat> months; final List<String> insights;
  const AnalyticsSnapshot({required this.totalRemaining, required this.thisMonth, required this.nextMonth, required this.overdueAmount, required this.overdueCount, required this.averageSixMonths, required this.debtFreeDate, required this.months, required this.insights});
}

class AnalyticsService {
  AnalyticsSnapshot calculate(List<Installment> items) {
    final now = DateTime.now(); final jNow = Jalali.fromDateTime(now);
    final active = items.where((e)=>!e.isPaid).toList();
    final totalRemaining = active.fold<int>(0,(s,e)=>s+e.remaining);
    final overdue = active.where((e)=>e.dueDate.isBefore(DateTime(now.year,now.month,now.day))).toList();
    final months = <MonthStat>[];
    for (var offset=0; offset<6; offset++) {
      final totalM = jNow.year*12+(jNow.month-1)+offset; final y=totalM~/12; final m=totalM%12+1;
      final inMonth=items.where((e){final j=Jalali.fromDateTime(e.dueDate); return j.year==y && j.month==m;}).toList();
      months.add(MonthStat(y,m,inMonth.fold(0,(s,e)=>s+e.amount),inMonth.where((e)=>!e.isPaid).fold(0,(s,e)=>s+e.remaining),inMonth.fold(0,(s,e)=>s+e.paidAmount)));
    }
    final thisMonth=months.first.unpaid; final nextMonth=months.length>1?months[1].unpaid:0;
    final avg=(months.fold<int>(0,(s,e)=>s+e.unpaid)/months.length).round();
    final debtFree=active.isEmpty?null:(active.map((e)=>e.dueDate).toList()..sort()).last;
    final insights=<String>[];
    if (thisMonth>0 && nextMonth>thisMonth) { final p=((nextMonth-thisMonth)/thisMonth*100).round(); insights.add('ماه آینده فشار پرداخت ${toPersianDigits(p)}٪ بیشتر از این ماه است.'); }
    if (months.isNotEmpty) { final peak=months.reduce((a,b)=>a.unpaid>=b.unpaid?a:b); if(peak.unpaid>0) insights.add('${peak.label} با ${compactMoney(peak.unpaid)} سنگین‌ترین ماه ۶ ماه آینده است.'); }
    final close=active.where((e)=>e.dueDate.difference(now).inDays>=0 && e.dueDate.difference(now).inDays<=3).toList();
    if(close.length>=2) insights.add('${toPersianDigits(close.length)} قسط در سه روز آینده نزدیک به هم سررسید می‌شوند.');
    if(overdue.isNotEmpty) insights.add('${toPersianDigits(overdue.length)} قسط معوق به مبلغ ${compactMoney(overdue.fold(0,(s,e)=>s+e.remaining))} نیاز به رسیدگی دارد.');
    if(insights.isEmpty) insights.add('برنامه پرداخت فعلی منظم است؛ سررسیدهای نزدیک تحت کنترل‌اند.');
    return AnalyticsSnapshot(totalRemaining:totalRemaining,thisMonth:thisMonth,nextMonth:nextMonth,overdueAmount:overdue.fold(0,(s,e)=>s+e.remaining),overdueCount:overdue.length,averageSixMonths:avg,debtFreeDate:debtFree,months:months,insights:insights);
  }
}
