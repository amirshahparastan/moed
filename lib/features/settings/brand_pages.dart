import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/brand.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';

class AboutMoedPage extends StatelessWidget {
  const AboutMoedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'درباره موعد',
      children: [
        const GlassCard(
          radius: 26,
          child: Column(
            children: [
              MoedLogo(size: 78),
              SizedBox(height: 10),
              Text(
                BrandInfo.appName,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4),
              Text(
                BrandInfo.productLine,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              SizedBox(height: 12),
              _BrandPill(text: 'محصولی از PULSE — پالس'),
              SizedBox(height: 8),
              Text(
                'توسعه و طراحی محصول: ${BrandInfo.developerName}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              SizedBox(height: 4),
              Text(
                'نسخه ${BrandInfo.appVersion}',
                style: TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          title: 'هدف موعد',
          icon: Icons.auto_awesome_rounded,
          body:
              'موعد برای مدیریت ساده، دقیق و هوشمند اقساط ساخته شده؛ از ثبت سررسید و پرداخت تا تقویم شمسی، یادآوری، گزارش فشار مالی و برنامه‌ریزی برای تسویه زودتر.',
        ),
        const _InfoCard(
          title: 'فلسفه محصول',
          icon: Icons.shield_outlined,
          body:
              'اطلاعات اصلی شما Local-first نگهداری می‌شود و برای استفاده روزمره نیازی به اتصال حساب بانکی یا تحویل رمز و اطلاعات حساس مالی ندارید.',
        ),
        GlassCard(
          onTap: () => _openWebsite(context),
          radius: 20,
          padding: const EdgeInsets.all(14),
          child: const Row(
            children: [
              Icon(Icons.language_rounded, color: AppColors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PULSE', style: TextStyle(fontWeight: FontWeight.w900)),
                    Text(
                      'wearepulse.ir',
                      style: TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              RtlNextIcon(),
            ],
          ),
        ),
      ],
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'حریم خصوصی',
      children: [
        _InfoCard(
          title: 'ذخیره‌سازی اطلاعات',
          icon: Icons.storage_rounded,
          body:
              'اطلاعات وام‌ها، اقساط و پرداخت‌ها به‌صورت پیش‌فرض روی دستگاه شما نگهداری می‌شود. موعد برای مدیریت اقساط نیازی به دریافت نام کاربری یا رمز حساب بانکی شما ندارد.',
        ),
        _InfoCard(
          title: 'اعلان‌ها',
          icon: Icons.notifications_none_rounded,
          body:
              'اجازه اعلان فقط برای یادآوری سررسیدها و اقساط معوق استفاده می‌شود. زمان و نوع یادآوری از داخل تنظیمات قابل کنترل است.',
        ),
        _InfoCard(
          title: 'قفل بیومتریک',
          icon: Icons.fingerprint_rounded,
          body:
              'در صورت فعال‌سازی، احراز هویت توسط سیستم‌عامل دستگاه انجام می‌شود. موعد اثرانگشت یا داده خام بیومتریک شما را دریافت یا ذخیره نمی‌کند.',
        ),
        _InfoCard(
          title: 'بکاپ و خروجی',
          icon: Icons.backup_outlined,
          body:
              'ساخت یا اشتراک‌گذاری فایل پشتیبان، PDF و CSV فقط با اقدام مستقیم شما انجام می‌شود. مسئولیت نگهداری فایل‌های خروجی پس از ذخیره یا اشتراک‌گذاری با کاربر است.',
        ),
        _InfoCard(
          title: 'فروش اطلاعات و تبلیغات',
          icon: Icons.do_not_disturb_alt_rounded,
          body:
              'در نسخه ۱.۰ موعد اطلاعات مالی کاربران به تبلیغ‌دهندگان فروخته نمی‌شود و هسته مدیریت اقساط بدون اتصال اجباری به سرویس تبلیغاتی طراحی شده است.',
        ),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'شرایط استفاده',
      children: [
        _InfoCard(
          title: 'ماهیت سرویس',
          icon: Icons.info_outline_rounded,
          body:
              'موعد ابزار مدیریت، ثبت و یادآوری اقساط است و جایگزین قرارداد، صورتحساب رسمی بانک یا مشاوره مالی و حقوقی نیست.',
        ),
        _InfoCard(
          title: 'مسئولیت اطلاعات',
          icon: Icons.fact_check_outlined,
          body:
              'کاربر مسئول صحت مبالغ، تاریخ‌ها، تعداد اقساط و پرداخت‌های واردشده است. پیش از تصمیم مالی مهم، اطلاعات را با منبع رسمی خود تطبیق دهید.',
        ),
        _InfoCard(
          title: 'تحلیل‌ها و پیش‌بینی‌ها',
          icon: Icons.insights_rounded,
          body:
              'تحلیل فشار مالی، تاریخ تقریبی پایان بدهی و سناریوهای تسویه بر اساس داده‌های ثبت‌شده در برنامه محاسبه می‌شوند و جنبه برنامه‌ریزی دارند.',
        ),
        _InfoCard(
          title: 'بکاپ',
          icon: Icons.cloud_done_outlined,
          body:
              'پیشنهاد می‌شود از اطلاعات مهم خود به‌صورت منظم فایل پشتیبان تهیه کنید، به‌خصوص پیش از تعویض دستگاه یا حذف برنامه.',
        ),
      ],
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final subject = TextEditingController(text: 'بازخورد درباره موعد');
  final body = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    subject.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> send() async {
    setState(() => busy = true);
    final uri = Uri(
      scheme: 'mailto',
      path: BrandInfo.feedbackEmail,
      queryParameters: {
        'subject': subject.text.trim().isEmpty ? 'بازخورد درباره موعد' : subject.text.trim(),
        'body': '${body.text.trim()}\n\n— موعد ${BrandInfo.appVersion} | PULSE',
      },
    );

    final ok = await launchUrl(uri);
    if (!mounted) return;
    setState(() => busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('امکان باز کردن برنامه ایمیل نبود. ایمیل پشتیبانی: ${BrandInfo.feedbackEmail}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'انتقادات و پیشنهادات',
      children: [
        const GlassCard(
          radius: 22,
          child: Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: AppColors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ارتباط مستقیم با PULSE', style: TextStyle(fontWeight: FontWeight.w900)),
                    Text(
                      BrandInfo.feedbackEmail,
                      style: TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: subject,
          decoration: const InputDecoration(labelText: 'موضوع'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: body,
          minLines: 5,
          maxLines: 9,
          decoration: const InputDecoration(
            labelText: 'پیام شما',
            hintText: 'پیشنهاد، ایراد یا قابلیتی که دوست دارید به موعد اضافه شود…',
          ),
        ),
        const SizedBox(height: 14),
        GradientButton(
          label: busy ? 'در حال باز کردن ایمیل…' : 'ارسال به PULSE',
          icon: Icons.send_rounded,
          onPressed: busy ? null : send,
        ),
      ],
    );
  }
}

class _InfoScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: const RtlBackButton(),
        title: Text(title),
      ),
      body: GlassBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String body;

  const _InfoCard({required this.title, required this.icon, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GlassCard(
        radius: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppColors.blue, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.85),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  final String text;
  const _BrandPill({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.w900),
        ),
      );
}

Future<void> _openWebsite(BuildContext context) async {
  final ok = await launchUrl(Uri.parse(BrandInfo.website));
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('امکان باز کردن وب‌سایت نبود')),
    );
  }
}
