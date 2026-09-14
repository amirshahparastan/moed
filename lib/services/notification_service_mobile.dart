import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../data/models/installment.dart';
import '../data/models/loan.dart';
import '../core/utils/formatters.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    tzdata.initializeTimeZones();
    try { final info = await FlutterTimezone.getLocalTimezone(); tz.setLocalLocation(tz.getLocation(info.identifier)); } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(settings: const InitializationSettings(android: android));
  }

  Future<void> requestPermission() async => _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  Future<void> openSettings() async => _plugin.openAppNotificationSettings();

  Future<void> reschedule({required List<Loan> loans, required List<Installment> installments, required bool enabled, required bool overdueFollowup, required List<int> reminderDays, required int hour}) async {
    await _plugin.cancelAll();
    if (!enabled) return;
    final now = DateTime.now();
    final loanMap = {for (final l in loans) l.id!: l};
    var serial = 1;
    for (final i in installments.where((x) => !x.isPaid)) {
      final loan = loanMap[i.loanId]; if (loan == null) continue;
      for (final before in reminderDays) {
        final scheduled = DateTime(i.dueDate.year, i.dueDate.month, i.dueDate.day, hour).subtract(Duration(days: before));
        if (!scheduled.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: i.id! * 10 + serial++ % 9,
          title: before == 0 ? 'امروز موعد پرداخت است' : 'یادآوری قسط ${loan.title}',
          body: '${money(i.remaining)} • ${before == 0 ? 'سررسید امروز' : '${toPersianDigits(before)} روز تا سررسید'}',
          scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
          notificationDetails: const NotificationDetails(android: AndroidNotificationDetails('installments','یادآوری اقساط', channelDescription: 'یادآوری سررسید اقساط', importance: Importance.high, priority: Priority.high)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'installment:${i.id}',
        );
      }
      if (overdueFollowup) for (final after in const [1,3,7]) {
        final scheduled = DateTime(i.dueDate.year, i.dueDate.month, i.dueDate.day, hour).add(Duration(days: after));
        if (!scheduled.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: i.id! * 100 + 50 + after,
          title: 'قسط ${loan.title} معوق شده',
          body: '${money(i.remaining)} هنوز پرداخت نشده است.',
          scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
          notificationDetails: const NotificationDetails(android: AndroidNotificationDetails('overdue','اقساط معوق', channelDescription: 'پیگیری اقساط پرداخت‌نشده', importance: Importance.high, priority: Priority.high)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'installment:${i.id}',
        );
      }
    }
  }
}
