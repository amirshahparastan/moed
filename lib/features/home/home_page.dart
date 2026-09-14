import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../data/models/loan.dart';
import '../../state/app_store.dart';
import '../loans/add_loan_page.dart';
import '../loans/loan_detail_page.dart';
import '../settings/reminders_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color nextCardText = dark ? const Color(0xFFF7F9FF) : AppColors.ink;
    final Color nextCardMuted = dark ? AppColors.mutedDark : AppColors.muted;
    final next = store.nextInstallment;
    final analytics = store.analytics;
    final nextLoan = next == null ? null : store.loanById(next.loanId);
    final paidTotal = store.installments.fold<int>(0, (s, e) => s + e.paidAmount);
    final thisMonthCount = analytics.months.isEmpty
        ? 0
        : store.pending.where((e) {
            final j = Jalali.fromDateTime(e.dueDate);
            final m = analytics.months.first;
            return j.year == m.year && j.month == m.month;
          }).length;

    return GlassBackground(
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => store.refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _editProfile(context, store),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.blue.withValues(alpha: .10),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سلام ${store.settings.userName.isEmpty ? '' : store.settings.userName} ☀️',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'مدیریت هوشمند اقساط و سررسیدها',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'یادآوری‌ها',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RemindersPage(),
                          ),
                        ),
                        icon: const Icon(Icons.notifications_none_rounded),
                      ),
                      if (store.pending.any((e) => e.isOverdue) ||
                          (store.nextInstallment != null &&
                              _daysUntil(store.nextInstallment!.dueDate) <= 3))
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GlassCard(
                radius: 28,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: dark
                      ? const [
                          Color(0xFF304765),
                          Color(0xFF223550),
                          Color(0xFF1B2A43),
                        ]
                      : [
                          Colors.white.withValues(alpha: .94),
                          AppColors.cyan.withValues(alpha: .16),
                          AppColors.purple.withValues(alpha: .10),
                        ],
                ),
                foregroundColor: nextCardText,
                onTap: next == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoanDetailPage(loanId: next.loanId),
                          ),
                        ),
                child: next == null || nextLoan == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('هنوز قسط فعالی ثبت نشده است')),
                      )
                    : Row(
                        // چیدمان فیزیکی را LTR قفل می‌کنیم تا RTL جای فلش را
                        // عوض نکند: آیکن وام چپ، متن وسط، فلش ورود راست.
                        textDirection: TextDirection.ltr,
                        children: [
                          _LoanIcon(type: nextLoan.type, size: 66),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'قسط بعدی',
                                    style: TextStyle(
                                      color: nextCardText,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    money(next.remaining),
                                    style: TextStyle(
                                      color: nextCardText,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    nextLoan.title,
                                    style: TextStyle(
                                      color: nextCardMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    relativeDue(next.dueDate),
                                    style: TextStyle(
                                      color: next.isOverdue
                                          ? AppColors.danger
                                          : nextCardMuted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.blue, AppColors.cyan],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const PhysicalChevron.right(
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _stat(
                      compactMoney(analytics.totalRemaining),
                      'مانده کل',
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _stat(compactMoney(paidTotal), 'پرداخت شده'),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _stat(
                      '${toPersianDigits(thisMonthCount)} قسط',
                      'این ماه',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.all(13),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('۳۰ روز آینده', style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(
                            '${toPersianDigits(store.dueNext30Days.length)} قسط • ${compactMoney(store.dueNext30Amount)}',
                            style: const TextStyle(fontSize: 9, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'اقساط من',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddLoanPage()),
                    ),
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      size: 36,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (store.loans.isEmpty)
                GlassCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 42,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 8),
                      const Text('اولین وام یا خرید اقساطی را ثبت کنید'),
                      const SizedBox(height: 14),
                      GradientButton(
                        label: 'ثبت اولین قسط',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddLoanPage()),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...store.loans.map((loan) => _loanCard(context, store, loan)),
              const SizedBox(height: 12),
              GlassCard(
                radius: 22,
                foregroundColor: AppColors.ink,
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDF8FF), Color(0xFFF2EEFF)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: AppColors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نگاه مالی موعد',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            analytics.insights.first,
                            style: const TextStyle(
                              color: Color(0xFF657694),
                              fontSize: 10,
                              height: 1.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
        radius: 18,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.muted),
            ),
          ],
        ),
      );

  Widget _loanCard(BuildContext context, AppStore store, Loan loan) {
    final items = store.installmentsFor(loan.id!);
    final paid = items.where((e) => e.isPaid).length;
    final progress = items.isEmpty ? 0.0 : paid / items.length;
    final pending = items.where((e) => !e.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final next = pending.isEmpty ? null : pending.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: GlassCard(
        padding: const EdgeInsets.all(13),
        radius: 20,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanDetailPage(loanId: loan.id!)),
        ),
        child: Row(
          children: [
            _LoanIcon(type: loan.type, size: 46),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.blue.withValues(alpha: .08),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  next == null
                      ? 'تسویه شده'
                      : relativeDue(next.dueDate),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: next?.isOverdue == true
                        ? AppColors.danger
                        : AppColors.blue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${toPersianDigits((progress * 100).round())}٪',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


int _daysUntil(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(due.year, due.month, due.day);
  return target.difference(today).inDays;
}

Future<void> _editProfile(BuildContext context, AppStore store) async {
    final controller = TextEditingController(text: store.settings.userName);
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 18,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'حساب کاربری',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'نامی که در صفحه اصلی نمایش داده می‌شود.',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'نام شما'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'نام نمی‌تواند خالی باشد'
                      : null,
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'ذخیره',
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    await store.setSettings(
                      store.settings.copyWith(userName: controller.text.trim()),
                    );
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
  }

class _LoanIcon extends StatelessWidget {
  final String type;
  final double size;
  const _LoanIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDDF6FF), Color(0xFFE9E9FF)],
          ),
          borderRadius: BorderRadius.circular(size * .34),
          border: Border.all(color: Colors.white.withValues(alpha: .9)),
        ),
        child: Icon(_icon(type), color: AppColors.blue, size: size * .50),
      );

  IconData _icon(String value) => switch (value) {
        'خودرو' => Icons.directions_car_filled_rounded,
        'مسکن' => Icons.home_rounded,
        'کالا' => Icons.laptop_mac_rounded,
        'شخصی' => Icons.person_rounded,
        _ => Icons.account_balance_rounded,
      };
}
