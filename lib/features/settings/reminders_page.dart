import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../state/app_store.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final settings = store.settings;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: const RtlBackButton(),
        title: const Text('یادآوری‌ها'),
      ),
      body: GlassBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _switchCard(
              'فعال بودن یادآوری‌ها',
              'اعلان سررسیدها روی دستگاه',
              settings.remindersEnabled,
              (v) => store.setSettings(settings.copyWith(remindersEnabled: v)),
            ),
            const SizedBox(height: 8),
            _toggle(
              '۳ روز قبل از سررسید',
              3,
              settings.reminderDays.contains(3),
              store,
            ),
            _toggle(
              '۱ روز قبل از سررسید',
              1,
              settings.reminderDays.contains(1),
              store,
            ),
            _toggle(
              'روز سررسید',
              0,
              settings.reminderDays.contains(0),
              store,
            ),
            _switchCard(
              'پیگیری اقساط معوق',
              'یادآوری در روزهای ۱، ۳ و ۷ بعد از سررسید',
              settings.overdueFollowup,
              (v) => store.setSettings(settings.copyWith(overdueFollowup: v)),
            ),
            const SizedBox(height: 8),
            GlassCard(
              radius: 20,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.reminderHour,
                    minute: 0,
                  ),
                );
                if (time != null) {
                  await store.setSettings(
                    settings.copyWith(reminderHour: time.hour),
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.blue),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ساعت یادآوری',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${toPersianDigits(settings.reminderHour.toString().padLeft(2, '0'))}:۰۰',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const RtlNextIcon(),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'نمونه اعلان',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            GlassCard(
              radius: 22,
              foregroundColor: AppColors.ink,
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF7FF), Color(0xFFF1EDFF)],
              ),
              child: Row(
                children: [
                  const MoedLogo(size: 46),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موعد',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'قسط خودرو ۸ روز دیگر • ۱۲٬۵۰۰٬۰۰۰ تومان',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF657694),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('تنظیمات اعلان‌های سیستم'),
                subtitle: const Text(
                  'اگر اعلان‌ها در Android بسته باشند از اینجا فعال کنید',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: store.notifications.openSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchCard(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: value,
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _toggle(
    String title,
    int day,
    bool value,
    AppStore store,
  ) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: value,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            onChanged: (enabled) {
              final list = [...store.settings.reminderDays];
              if (enabled) {
                if (!list.contains(day)) list.add(day);
              } else {
                list.remove(day);
              }
              list.sort((a, b) => b.compareTo(a));
              store.setSettings(store.settings.copyWith(reminderDays: list));
            },
          ),
        ),
      );
}
