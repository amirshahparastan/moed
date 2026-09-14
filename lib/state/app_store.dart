import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/utils/formatters.dart';
import '../data/app_database.dart';
import '../data/models/loan.dart';
import '../data/models/installment.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../services/backup_export_service.dart';

class AppStore extends ChangeNotifier {
  final db=AppDatabase.instance; final settingsService=SettingsService(); final notifications=NotificationService(); final analyticsService=AnalyticsService();
  late final backup=BackupExportService(db);
  AppSettings settings=const AppSettings(onboarded:false,userName:'',themeMode:'system',biometric:false,remindersEnabled:true,overdueFollowup:true,reminderDays:[3,1,0],reminderHour:10);
  List<Loan> loans=[]; List<Installment> installments=[]; bool ready=false;

  Future<void> init() async {
    settings=await settingsService.load();

    // نسخه‌های قبلی اجازه می‌دادند بدون نام وارد شوند و نام «کاربر» ذخیره می‌شد.
    // از این نسخه، ورود اولیه حتماً به نام معتبر نیاز دارد.
    if (settings.onboarded &&
        (settings.userName.trim().isEmpty || settings.userName.trim() == 'کاربر')) {
      settings = settings.copyWith(onboarded: false, userName: '');
      await settingsService.save(settings);
    }

    await refresh(reschedule:false);
    ready=true;
    notifyListeners();

    // Notification/timezone initialization can be slow on some Android devices.
    // Never block first paint of the app on it.
    unawaited(_initNotificationsInBackground());
  }

  Future<void> _initNotificationsInBackground() async {
    try {
      await notifications.init();
      await notifications.reschedule(
        loans: loans,
        installments: installments,
        enabled: settings.remindersEnabled,
        overdueFollowup: settings.overdueFollowup,
        reminderDays: settings.reminderDays,
        hour: settings.reminderHour,
      );
    } catch (_) {
      // The app must remain usable even if notification initialization fails.
    }
  }

  Future<void> refresh({bool reschedule=true}) async { loans=await db.loans(); installments=await db.installments(); if(reschedule) await notifications.reschedule(loans:loans,installments:installments,enabled:settings.remindersEnabled,overdueFollowup:settings.overdueFollowup,reminderDays:settings.reminderDays,hour:settings.reminderHour); notifyListeners(); }

  AnalyticsSnapshot get analytics=>analyticsService.calculate(installments);
  List<Installment> get pending => installments.where((e)=>!e.isPaid).toList()..sort((a,b)=>a.dueDate.compareTo(b.dueDate));
  Installment? get nextInstallment => pending.isEmpty?null:pending.first;

  List<Installment> get dueNext30Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = today.add(const Duration(days: 30));
    return pending.where((e) {
      final due = DateTime(e.dueDate.year, e.dueDate.month, e.dueDate.day);
      return !due.isBefore(today) && !due.isAfter(end);
    }).toList();
  }

  int get dueNext30Amount => dueNext30Days.fold<int>(0, (s,e)=>s+e.remaining);
  int get totalPaidAmount => installments.fold<int>(0, (s,e)=>s+e.paidAmount);
  int get totalScheduledAmount => installments.fold<int>(0, (s,e)=>s+e.amount);
  double get overallProgress => totalScheduledAmount == 0 ? 0 : (totalPaidAmount / totalScheduledAmount).clamp(0,1);
  Loan? loanById(int id){ try{return loans.firstWhere((e)=>e.id==id);}catch(_){return null;} }
  List<Installment> installmentsFor(int loanId)=>installments.where((e)=>e.loanId==loanId).toList();

  Future<void> setSettings(AppSettings value) async {
    final previous = settings;
    final safeValue = value.onboarded && value.userName.trim().isEmpty
        ? value.copyWith(userName: settings.userName.trim())
        : value;

    // Apply UI settings first. Theme changes should feel instant.
    settings = safeValue;
    notifyListeners();
    await settingsService.save(safeValue);

    final reminderConfigChanged =
        previous.remindersEnabled != safeValue.remindersEnabled ||
        previous.overdueFollowup != safeValue.overdueFollowup ||
        previous.reminderHour != safeValue.reminderHour ||
        !listEquals(previous.reminderDays, safeValue.reminderDays);

    if (reminderConfigChanged) {
      unawaited(notifications.reschedule(
        loans: loans,
        installments: installments,
        enabled: safeValue.remindersEnabled,
        overdueFollowup: safeValue.overdueFollowup,
        reminderDays: safeValue.reminderDays,
        hour: safeValue.reminderHour,
      ));
    }
  }

  Future<void> setThemeMode(String mode) async {
    if (settings.themeMode == mode) return;
    final next = settings.copyWith(themeMode: mode);
    settings = next;
    notifyListeners();
    await settingsService.save(next);
  }
  Future<void> completeOnboarding(String name) async {
    final value = name.trim();
    if (value.isEmpty) return;
    await setSettings(settings.copyWith(onboarded: true, userName: value));
  }

  Future<void> createLoan(Loan loan) async {
    await notifications.requestPermission();
    await db.createLoan(loan,(id)=>List.generate(loan.installmentCount,(index){
      DateTime due;
      if(loan.frequency=='weekly') due=loan.startDate.add(Duration(days:7*loan.frequencyValue*index));
      else due=addJalaliMonths(loan.startDate,loan.frequencyValue*index);
      final amount=(index==loan.installmentCount-1 ? (loan.totalAmount-loan.installmentAmount*(loan.installmentCount-1)).clamp(0,loan.installmentAmount) : loan.installmentAmount).toInt();
      return Installment(loanId:id,sequence:index+1,dueDate:due,amount:amount==0?loan.installmentAmount:amount,paidAmount:0,status:'pending');
    })); await refresh();
  }
  Future<void> pay(Installment item,int amount,{String note=''}) async { await db.addPayment(item,amount,note:note); await refresh(); }

  Future<void> payAhead(int loanId,int amount,{String note='پرداخت زودتر'}) async {
    if(amount<=0)return;
    var remaining=amount;
    final items=installmentsFor(loanId).where((e)=>!e.isPaid).toList()
      ..sort((a,b)=>a.dueDate.compareTo(b.dueDate));
    for(final item in items){
      if(remaining<=0)break;
      final actual=remaining>item.remaining?item.remaining:remaining;
      if(actual>0){
        await db.addPayment(item,actual,note:note);
        remaining-=actual;
      }
    }
    await refresh();
  }

  Future<void> editInstallment(Installment item,{DateTime? dueDate,int? amount}) async { await db.updateInstallment(item.id!,dueDate:dueDate,amount:amount); await refresh(); }
  Future<void> deleteLoan(int id) async { await db.deleteLoan(id); await refresh(); }
  Future<bool> restore() async { final ok=await backup.restoreBackup(); if(ok) await refresh(); return ok; }
}
