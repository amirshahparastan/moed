import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool onboarded;
  final String userName;
  final String themeMode;
  final bool biometric;
  final bool remindersEnabled;
  final bool overdueFollowup;
  final List<int> reminderDays;
  final int reminderHour;

  const AppSettings({
    required this.onboarded,
    required this.userName,
    required this.themeMode,
    required this.biometric,
    required this.remindersEnabled,
    required this.overdueFollowup,
    required this.reminderDays,
    required this.reminderHour,
  });

  AppSettings copyWith({
    bool? onboarded,
    String? userName,
    String? themeMode,
    bool? biometric,
    bool? remindersEnabled,
    bool? overdueFollowup,
    List<int>? reminderDays,
    int? reminderHour,
  }) => AppSettings(
        onboarded: onboarded ?? this.onboarded,
        userName: userName ?? this.userName,
        themeMode: themeMode ?? this.themeMode,
        biometric: biometric ?? this.biometric,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        overdueFollowup: overdueFollowup ?? this.overdueFollowup,
        reminderDays: reminderDays ?? this.reminderDays,
        reminderHour: reminderHour ?? this.reminderHour,
      );
}

class SettingsService {
  final _prefs = SharedPreferencesAsync();

  Future<AppSettings> load() async => AppSettings(
        onboarded: await _prefs.getBool('onboarded') ?? false,
        userName: await _prefs.getString('user_name') ?? '',
        themeMode: await _prefs.getString('theme') ?? 'system',
        biometric: await _prefs.getBool('biometric') ?? false,
        remindersEnabled: await _prefs.getBool('reminders_enabled') ?? true,
        overdueFollowup: await _prefs.getBool('overdue_followup') ?? true,
        reminderDays: (await _prefs.getStringList('reminder_days') ?? ['3','1','0'])
            .map(int.parse)
            .toList(),
        reminderHour: await _prefs.getInt('reminder_hour') ?? 10,
      );

  Future<void> save(AppSettings s) async {
    await _prefs.setBool('onboarded', s.onboarded);
    await _prefs.setString('user_name', s.userName);
    await _prefs.setString('theme', s.themeMode);
    await _prefs.setBool('biometric', s.biometric);
    await _prefs.setBool('reminders_enabled', s.remindersEnabled);
    await _prefs.setBool('overdue_followup', s.overdueFollowup);
    await _prefs.setStringList(
      'reminder_days',
      s.reminderDays.map((e) => '$e').toList(),
    );
    await _prefs.setInt('reminder_hour', s.reminderHour);
  }
}
