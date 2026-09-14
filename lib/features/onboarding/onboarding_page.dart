import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';

class OnboardingPage extends StatefulWidget {
  final Future<void> Function(String name) onDone;
  const OnboardingPage({super.key, required this.onDone});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final name = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => busy = true);
    try {
      await widget.onDone(name.text.trim());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 34, 22, 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height - 78,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    const MoedLogo(size: 108),
                    const SizedBox(height: 18),
                    Text(
                      BrandInfo.appName,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: dark ? const Color(0xFFF4F7FF) : AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      BrandInfo.productLine,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? AppColors.mutedDark : AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 7,
                      runSpacing: 7,
                      children: const [
                        _FeaturePill(icon: Icons.calendar_month_rounded, text: 'تقویم شمسی'),
                        _FeaturePill(icon: Icons.notifications_active_outlined, text: 'یادآوری هوشمند'),
                        _FeaturePill(icon: Icons.insights_rounded, text: 'تحلیل فشار مالی'),
                      ],
                    ),
                    const Spacer(),
                    Form(
                      key: formKey,
                      child: GlassCard(
                        radius: 30,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            const Text(
                              'اقساطت را ثبت کن، موعدها را فراموش نکن\nو از قبل فشار مالی ماه‌های آینده را ببین.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: name,
                              textAlign: TextAlign.right,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'نام شما',
                                hintText: 'مثلاً امیر',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'لطفاً نام خود را وارد کنید';
                                }
                                if (value.trim().length < 2) {
                                  return 'نام واردشده خیلی کوتاه است';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 14),
                            GradientButton(
                              label: busy ? 'در حال آماده‌سازی موعد…' : 'ورود به موعد',
                              icon: Icons.login_rounded,
                              onPressed: busy ? null : _submit,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'اطلاعات اصلی شما روی دستگاه خودتان نگهداری می‌شود.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      BrandInfo.attribution,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.cyan.withValues(alpha: .32)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.blue),
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}
