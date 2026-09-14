import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../data/models/installment.dart';
import '../../state/app_store.dart';
import 'jalali_picker.dart';

class LoanDetailPage extends StatefulWidget {
  final int loanId;
  const LoanDetailPage({super.key, required this.loanId});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final loan = store.loanById(widget.loanId);
    if (loan == null) {
      return const Scaffold(body: Center(child: Text('وام پیدا نشد')));
    }

    final items = store.installmentsFor(widget.loanId);
    final paid = items.where((e) => e.isPaid).length;
    final rem = items.fold<int>(0, (s, e) => s + e.remaining);
    final paidAmount = items.fold<int>(0, (s, e) => s + e.paidAmount);
    final progress = items.isEmpty ? 0.0 : paid / items.length;
    final pending = items.where((e) => !e.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final next = pending.isEmpty ? null : pending.first;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: const RtlBackButton(),
        title: const Text('جزئیات وام'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pdf', child: Text('خروجی PDF')),
              PopupMenuItem(value: 'delete', child: Text('حذف وام')),
            ],
            onSelected: (v) async {
              if (v == 'pdf') {
                await store.backup.shareLoanPdf(loan, items);
              }
              if (v == 'delete' && context.mounted) {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('حذف وام؟'),
                        content: const Text(
                          'تمام اقساط و پرداخت‌های این وام حذف می‌شود.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('انصراف'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (ok) {
                  await store.deleteLoan(widget.loanId);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: GlassBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            GlassCard(
              radius: 28,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _loanIcon(loan.type),
                  const SizedBox(height: 8),
                  Text(
                    loan.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    loan.lender,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: CustomPaint(
                      painter: _RingPainter(progress),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${toPersianDigits(paid)} / ${toPersianDigits(items.length)}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'پرداخت شده',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _mini(money(loan.installmentAmount), 'مبلغ هر قسط')),
                      const SizedBox(width: 7),
                      Expanded(child: _mini(money(rem), 'مانده')),
                      const SizedBox(width: 7),
                      Expanded(child: _mini(money(paidAmount), 'پرداخت شده')),
                    ],
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 10),
                    GlassCard(
                      radius: 17,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'قسط بعدی ${relativeDue(next.dueDate)} (${jalaliDate(next.dueDate)})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      label: 'پرداخت این قسط',
                      icon: Icons.check_rounded,
                      onPressed: () => _pay(context, store, next),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _payAhead(context, store, loan.id!, rem),
                        icon: const Icon(Icons.fast_forward_rounded),
                        label: const Text('پرداخت زودتر چند قسط'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('جدول اقساط')),
                ButtonSegment(value: 1, label: Text('نمودار')),
                ButtonSegment(value: 2, label: Text('جزئیات')),
              ],
              selected: {tab},
              onSelectionChanged: (v) => setState(() => tab = v.first),
            ),
            const SizedBox(height: 12),
            if (tab == 0)
              ...items.map((i) => _installmentRow(context, store, i)),
            if (tab == 1) _chart(items),
            if (tab == 2)
              GlassCard(
                child: Column(
                  children: [
                    _detail('نوع تعهد', loan.type),
                    _detail('طرف حساب', loan.lender.isEmpty ? '—' : loan.lender),
                    _detail('مبلغ کل', money(loan.totalAmount)),
                    _detail('اولین سررسید', jalaliDate(loan.startDate)),
                    _detail('دوره پرداخت', loan.frequency == 'weekly' ? 'هفتگی' : 'ماهانه'),
                    if (loan.notes.isNotEmpty) _detail('یادداشت', loan.notes),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _loanIcon(String type) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDDF6FF), Color(0xFFE7E7FF)],
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withValues(alpha: .9)),
        ),
        child: Icon(
          switch (type) {
            'خودرو' => Icons.directions_car_filled_rounded,
            'مسکن' => Icons.home_rounded,
            'کالا' => Icons.shopping_bag_rounded,
            _ => Icons.account_balance_rounded,
          },
          color: AppColors.blue,
          size: 31,
        ),
      );

  Widget _mini(String value, String label) => GlassCard(
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value.replaceAll(' تومان', ''),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      );

  Widget _installmentRow(
    BuildContext context,
    AppStore store,
    Installment i,
  ) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: i.isPaid
                    ? AppColors.success.withValues(alpha: .12)
                    : i.isOverdue
                        ? AppColors.danger.withValues(alpha: .12)
                        : AppColors.blue.withValues(alpha: .10),
                child: Icon(
                  i.isPaid
                      ? Icons.check_rounded
                      : i.isOverdue
                          ? Icons.priority_high_rounded
                          : Icons.schedule_rounded,
                  size: 18,
                  color: i.isPaid
                      ? AppColors.success
                      : i.isOverdue
                          ? AppColors.danger
                          : AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قسط ${toPersianDigits(i.sequence)}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      jalaliDate(i.dueDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(i.amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (i.isPaid)
                    const Text(
                      'پرداخت شده',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _edit(context, store, i),
                          child: const Text('ویرایش'),
                        ),
                        TextButton(
                          onPressed: () => _pay(context, store, i),
                          child: const Text('پرداخت'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _chart(List<Installment> items) {
    final visible = items.take(12).toList();
    final maxValue = visible.isEmpty
        ? 1
        : visible.map((e) => e.amount).fold<int>(1, (a, b) => a > b ? a : b);
    return GlassCard(
      child: SizedBox(
        height: 230,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: visible.map((i) {
            final h = 28 + (i.amount / maxValue) * 135;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: i.isPaid
                              ? [
                                  AppColors.cyan.withValues(alpha: .60),
                                  AppColors.blue.withValues(alpha: .45),
                                ]
                              : const [AppColors.blue, AppColors.purple],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      toPersianDigits(i.sequence),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _detail(String title, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );

  Future<void> _payAhead(
    BuildContext context,
    AppStore store,
    int loanId,
    int remainingDebt,
  ) async {
    final controller = TextEditingController();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'پرداخت زودتر',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'مبلغ بین اقساط پرداخت‌نشده از نزدیک‌ترین سررسید تقسیم می‌شود. مانده فعلی: ${money(remainingDebt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'مبلغ پرداخت اضافه (تومان)',
                  hintText: 'مثلاً 25,000,000',
                ),
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: 'ثبت پرداخت زودتر',
                icon: Icons.auto_awesome_rounded,
                onPressed: () async {
                  final value = parseMoney(controller.text);
                  if (value <= 0) return;
                  await store.payAhead(loanId, value);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _pay(
    BuildContext context,
    AppStore store,
    Installment i,
  ) async {
    final c = TextEditingController(text: formatMoneyInput(i.remaining));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ثبت پرداخت',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('مانده این قسط: ${money(i.remaining)}'),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsSeparatorInputFormatter()],
              decoration: const InputDecoration(labelText: 'مبلغ پرداختی'),
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: 'ثبت پرداخت',
              onPressed: () async {
                final a = parseMoney(c.text);
                if (a > 0) {
                  await store.pay(i, a);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                }
              },
            ),
          ],
        ),
      ),
    );
    c.dispose();
  }

  Future<void> _edit(
    BuildContext context,
    AppStore store,
    Installment i,
  ) async {
    final c = TextEditingController(text: formatMoneyInput(i.amount));
    DateTime d = i.dueDate;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialog) => AlertDialog(
          title: Text('ویرایش قسط ${toPersianDigits(i.sequence)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: c,
                keyboardType: TextInputType.number,
                inputFormatters: const [ThousandsSeparatorInputFormatter()],
                decoration: const InputDecoration(labelText: 'مبلغ قسط'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(jalaliDate(d)),
                leading: const Icon(Icons.calendar_month),
                onTap: () async {
                  final x = await showJalaliPicker(dialogContext, initial: d);
                  if (x != null) setDialog(() => d = x);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () async {
                await store.editInstallment(
                  i,
                  dueDate: d,
                  amount: parseMoney(c.text),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
    c.dispose();
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  const _RingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final bg = Paint()
      ..color = const Color(0xFFE4ECF9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.blue, AppColors.purple],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value.clamp(0.0, 1.0).toDouble(),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}
