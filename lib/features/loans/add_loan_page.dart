import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/rtl_navigation.dart';
import '../../data/models/loan.dart';
import '../../state/app_store.dart';
import 'jalali_picker.dart';

class AddLoanPage extends StatefulWidget {
  const AddLoanPage({super.key});
  @override
  State<AddLoanPage> createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController();
  final lender = TextEditingController();
  final total = TextEditingController();
  final amount = TextEditingController();
  final count = TextEditingController(text: '12');
  final notes = TextEditingController();

  String type = 'خودرو';
  String frequency = 'monthly';
  int frequencyValue = 1;
  DateTime firstDue = DateTime.now().add(const Duration(days: 30));
  bool saving = false;
  bool reminder = true;

  @override
  void dispose() {
    title.dispose();
    lender.dispose();
    total.dispose();
    amount.dispose();
    count.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leadingWidth: 56,
          leading: const RtlBackButton(),
          title: const Text('ثبت وام یا خرید اقساطی'),
        ),
        body: GlassBackground(
          child: SafeArea(
            top: false,
            child: Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  Row(
                    children: [
                      _typeCard('مسکن', Icons.home_rounded),
                      const SizedBox(width: 7),
                      _typeCard('خودرو', Icons.directions_car_filled_rounded),
                      const SizedBox(width: 7),
                      _typeCard('کالا', Icons.shopping_bag_rounded),
                      const SizedBox(width: 7),
                      _typeCard('وام بانکی', Icons.account_balance_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: title,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'عنوان',
                      hintText: 'مثلاً وام خودرو',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'عنوان را وارد کنید'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'مبلغ هر قسط (تومان)',
                    ),
                    validator: (v) => parseMoney(v ?? '') <= 0
                        ? 'مبلغ نامعتبر'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: count,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(labelText: 'تعداد اقساط'),
                    validator: (v) =>
                        (int.tryParse(toEnglishDigits(v ?? '')) ?? 0) <= 0
                            ? 'تعداد نامعتبر'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: total,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [ThousandsSeparatorInputFormatter()],
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'مبلغ کل بازپرداخت (تومان)',
                      hintText: 'اگر خالی باشد خودکار محاسبه می‌شود',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lender,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'بانک / فروشگاه / شخص',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    radius: 18,
                    onTap: () async {
                      final d = await showJalaliPicker(
                        context,
                        initial: firstDue,
                      );
                      if (d != null) setState(() => firstDue = d);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تاریخ اولین سررسید',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                jalaliDate(firstDue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const RtlNextIcon(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: const InputDecoration(labelText: 'دوره پرداخت'),
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('ماهانه'),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text('هفتگی'),
                      ),
                    ],
                    onChanged: (v) => setState(() => frequency = v!),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    radius: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: reminder,
                      title: const Text(
                        'یادآوری',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text(
                        'قبل از سررسید به من یادآوری کن',
                        style: TextStyle(fontSize: 9),
                      ),
                      onChanged: (v) => setState(() => reminder = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: notes,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'یادداشت (اختیاری)',
                    ),
                  ),
                  const SizedBox(height: 18),
                  GradientButton(
                    label: saving ? 'در حال ساخت اقساط...' : 'ایجاد اقساط',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: saving ? null : save,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _typeCard(String value, IconData icon) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => type = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: type == value
                  ? AppColors.blue.withValues(alpha: .10)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: .08)
                      : Colors.white.withValues(alpha: .70)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: type == value
                    ? AppColors.cyan
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: .12)
                        : Colors.white.withValues(alpha: .86)),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: type == value ? AppColors.blue : AppColors.muted,
                ),
                const SizedBox(height: 5),
                FittedBox(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: type == value
                          ? AppColors.blue
                          : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);

    final store = context.read<AppStore>();
    final a = parseMoney(amount.text);
    final c = int.parse(toEnglishDigits(count.text));
    var t = parseMoney(total.text);
    if (t <= 0) t = a * c;

    if (reminder) await store.notifications.requestPermission();

    await store.createLoan(
      Loan(
        title: title.text.trim(),
        type: type,
        lender: lender.text.trim(),
        totalAmount: t,
        installmentAmount: a,
        installmentCount: c,
        startDate: firstDue,
        frequency: frequency,
        frequencyValue: frequencyValue,
        notes: notes.text.trim(),
        colorIndex: store.loans.length % 3,
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    );

    if (mounted) Navigator.pop(context);
  }
}
