import '../data/models/installment.dart';
import '../data/models/loan.dart';

/// Browser preview stub. Android uses the real local-notification service.
class NotificationService {
  Future<void> init() async {}
  Future<void> requestPermission() async {}
  Future<void> openSettings() async {}
  Future<void> reschedule({
    required List<Loan> loans,
    required List<Installment> installments,
    required bool enabled,
    required bool overdueFollowup,
    required List<int> reminderDays,
    required int hour,
  }) async {}
}
