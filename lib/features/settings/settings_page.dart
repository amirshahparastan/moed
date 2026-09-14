import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/brand.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../services/biometric_service.dart';
import '../../services/settings_service.dart';
import '../../state/app_store.dart';
import 'brand_pages.dart';
import 'reminders_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final settings = store.settings;

    return GlassBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
          children: [
            const Text(
              'تنظیمات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            const Text('ظاهر', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            GlassCard(
              radius: 22,
              child: Row(
                children: [
                  _themeOption(store, settings, 'light', Icons.light_mode_rounded, 'روشن'),
                  const SizedBox(width: 8),
                  _themeOption(store, settings, 'dark', Icons.dark_mode_rounded, 'تیره'),
                  const SizedBox(width: 8),
                  _themeOption(store, settings, 'system', Icons.language_rounded, 'سیستمی'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('حساب و یادآوری', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _row(
              icon: Icons.person_outline_rounded,
              title: 'نام کاربر',
              subtitle: settings.userName.isEmpty ? 'تعریف نشده' : settings.userName,
              onTap: () => _editName(context, store),
            ),
            _row(
              icon: Icons.notifications_none_rounded,
              title: 'یادآوری‌ها',
              subtitle: 'زمان، سررسید و پیگیری اقساط معوق',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RemindersPage()),
              ),
            ),
            _row(
              icon: Icons.lock_outline_rounded,
              title: 'قفل برنامه',
              subtitle: settings.biometric ? 'قفل دستگاه فعال است' : 'برای حفظ اطلاعات غیرفعال است',
              onTap: () => _toggleLock(context, store),
            ),
            const SizedBox(height: 10),
            const Text('داده‌ها و خروجی', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _row(
              icon: Icons.cloud_upload_outlined,
              title: 'پشتیبان‌گیری',
              subtitle: 'ساخت فایل بکاپ کامل اطلاعات',
              onTap: store.backup.shareBackup,
            ),
            _row(
              icon: Icons.restore_rounded,
              title: 'بازیابی',
              subtitle: 'بازیابی اطلاعات از فایل پشتیبان',
              onTap: () async {
                try {
                  final ok = await store.restore();
                  if (context.mounted && ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اطلاعات بازیابی شد')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                }
              },
            ),
            _row(
              icon: Icons.picture_as_pdf_outlined,
              title: 'صادرات PDF',
              subtitle: 'گزارش رسمی هر وام از صفحه جزئیات',
              onTap: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('خروجی PDF'),
                  content: const Text(
                    'وارد جزئیات یک وام شوید و از منوی بالا گزینه «خروجی PDF» را انتخاب کنید.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('باشه'),
                    ),
                  ],
                ),
              ),
            ),
            _row(
              icon: Icons.table_view_outlined,
              title: 'خروجی CSV',
              subtitle: 'همه اقساط و وضعیت پرداخت برای اکسل',
              onTap: () => store.backup.shareCsv(store.loans, store.installments),
            ),
            const SizedBox(height: 10),
            const Text('PULSE و پشتیبانی', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _row(
              icon: Icons.info_outline_rounded,
              title: 'درباره موعد',
              subtitle: 'PULSE • توسعه ${BrandInfo.developerName}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutMoedPage()),
              ),
            ),
            _row(
              icon: Icons.privacy_tip_outlined,
              title: 'حریم خصوصی',
              subtitle: 'نحوه نگهداری داده‌ها و مجوزها',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPage()),
              ),
            ),
            _row(
              icon: Icons.gavel_rounded,
              title: 'شرایط استفاده',
              subtitle: 'مسئولیت داده‌ها، تحلیل‌ها و بکاپ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsPage()),
              ),
            ),
            _row(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'انتقادات و پیشنهادات',
              subtitle: BrandInfo.feedbackEmail,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackPage()),
              ),
            ),
            const SizedBox(height: 10),
            const GlassCard(
              radius: 20,
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    BrandInfo.attribution,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'نسخه ${BrandInfo.appVersion}',
                    style: TextStyle(fontSize: 8, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    AppStore store,
    AppSettings settings,
    String mode,
    IconData icon,
    String label,
  ) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => store.setSettings(settings.copyWith(themeMode: mode)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: settings.themeMode == mode
                  ? AppColors.blue.withValues(alpha: .08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: settings.themeMode == mode ? AppColors.cyan : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: settings.themeMode == mode ? AppColors.blue : AppColors.muted,
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: settings.themeMode == mode ? AppColors.blue : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _row({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(13),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const RtlNextIcon(),
            ],
          ),
        ),
      );

  Future<void> _editName(BuildContext context, AppStore store) async {
    final controller = TextEditingController(text: store.settings.userName);
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('نام کاربر'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'نام'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'نام نمی‌تواند خالی باشد'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await store.setSettings(
                store.settings.copyWith(userName: controller.text.trim()),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _toggleLock(BuildContext context, AppStore store) async {
    if (!store.settings.biometric) {
      final ok = await BiometricService().authenticate();
      if (!ok) return;
    }
    await store.setSettings(
      store.settings.copyWith(biometric: !store.settings.biometric),
    );
  }
}
