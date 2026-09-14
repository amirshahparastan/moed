import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/loan.dart';
import 'models/installment.dart';
import 'models/payment.dart';

/// Lightweight browser persistence used only for Chrome/Web preview.
/// Android keeps using the SQLite implementation via conditional export.
class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const _loansKey = 'moed_web_loans_v1';
  static const _installmentsKey = 'moed_web_installments_v1';
  static const _paymentsKey = 'moed_web_payments_v1';

  Future<List<Map<String, Object?>>> _readList(String key) async {
    final raw = await _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw) as List<dynamic>;
    return data.map((e) => Map<String, Object?>.from(e as Map)).toList();
  }

  Future<void> _writeList(String key, List<Map<String, Object?>> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  int _nextId(List<Map<String, Object?>> rows) {
    var max = 0;
    for (final row in rows) {
      final value = row['id'];
      if (value is num && value.toInt() > max) max = value.toInt();
    }
    return max + 1;
  }

  Future<List<Loan>> loans() async {
    final rows = await _readList(_loansKey);
    rows.sort((a, b) {
      final ac = (a['is_completed'] as num? ?? 0).toInt();
      final bc = (b['is_completed'] as num? ?? 0).toInt();
      if (ac != bc) return ac.compareTo(bc);
      final ad = DateTime.tryParse(a['created_at'] as String? ?? '') ?? DateTime(2000);
      final bd = DateTime.tryParse(b['created_at'] as String? ?? '') ?? DateTime(2000);
      return bd.compareTo(ad);
    });
    return rows.map(Loan.fromMap).toList();
  }

  Future<List<Installment>> installments({int? loanId}) async {
    var rows = await _readList(_installmentsKey);
    if (loanId != null) {
      rows = rows.where((e) => (e['loan_id'] as num).toInt() == loanId).toList();
    }
    rows.sort((a, b) => DateTime.parse(a['due_date'] as String).compareTo(DateTime.parse(b['due_date'] as String)));
    return rows.map(Installment.fromMap).toList();
  }

  Future<List<Payment>> paymentsFor(int installmentId) async {
    var rows = await _readList(_paymentsKey);
    rows = rows.where((e) => (e['installment_id'] as num).toInt() == installmentId).toList();
    rows.sort((a, b) => DateTime.parse(b['paid_at'] as String).compareTo(DateTime.parse(a['paid_at'] as String)));
    return rows.map(Payment.fromMap).toList();
  }

  Future<int> createLoan(Loan loan, List<Installment> Function(int id) buildInstallments) async {
    final loanRows = await _readList(_loansKey);
    final installmentRows = await _readList(_installmentsKey);
    final id = _nextId(loanRows);
    final loanMap = loan.toMap()..['id'] = id;
    loanRows.add(loanMap);

    var nextInstallmentId = _nextId(installmentRows);
    for (final item in buildInstallments(id)) {
      final map = item.toMap()..['id'] = nextInstallmentId++;
      installmentRows.add(map);
    }
    await _writeList(_loansKey, loanRows);
    await _writeList(_installmentsKey, installmentRows);
    return id;
  }

  Future<void> deleteLoan(int id) async {
    final loanRows = await _readList(_loansKey);
    final installmentRows = await _readList(_installmentsKey);
    final paymentRows = await _readList(_paymentsKey);
    final removedInstallmentIds = installmentRows
        .where((e) => (e['loan_id'] as num).toInt() == id)
        .map((e) => (e['id'] as num).toInt())
        .toSet();
    loanRows.removeWhere((e) => (e['id'] as num).toInt() == id);
    installmentRows.removeWhere((e) => (e['loan_id'] as num).toInt() == id);
    paymentRows.removeWhere((e) => removedInstallmentIds.contains((e['installment_id'] as num).toInt()));
    await _writeList(_loansKey, loanRows);
    await _writeList(_installmentsKey, installmentRows);
    await _writeList(_paymentsKey, paymentRows);
  }

  Future<void> updateInstallment(int id, {DateTime? dueDate, int? amount}) async {
    final rows = await _readList(_installmentsKey);
    final index = rows.indexWhere((e) => (e['id'] as num).toInt() == id);
    if (index < 0) return;
    if (dueDate != null) rows[index]['due_date'] = dueDate.toIso8601String();
    if (amount != null) rows[index]['amount'] = amount;
    await _writeList(_installmentsKey, rows);
  }

  Future<void> addPayment(Installment installment, int amount, {String note = ''}) async {
    final installmentRows = await _readList(_installmentsKey);
    final paymentRows = await _readList(_paymentsKey);
    final loanRows = await _readList(_loansKey);
    final index = installmentRows.indexWhere((e) => (e['id'] as num).toInt() == installment.id);
    if (index < 0) return;

    final actual = amount.clamp(0, installment.remaining).toInt();
    if (actual <= 0) return;
    final payment = Payment(
      id: _nextId(paymentRows),
      installmentId: installment.id!,
      amount: actual,
      paidAt: DateTime.now(),
      note: note,
    );
    paymentRows.add(payment.toMap());

    final paid = installment.paidAmount + actual;
    final status = paid >= installment.amount ? 'paid' : 'partial';
    installmentRows[index]['paid_amount'] = paid;
    installmentRows[index]['status'] = status;
    installmentRows[index]['paid_at'] = status == 'paid' ? DateTime.now().toIso8601String() : null;

    if (status == 'paid') {
      final hasPending = installmentRows.any((e) =>
          (e['loan_id'] as num).toInt() == installment.loanId &&
          e['status'] != 'paid');
      if (!hasPending) {
        final loanIndex = loanRows.indexWhere((e) => (e['id'] as num).toInt() == installment.loanId);
        if (loanIndex >= 0) loanRows[loanIndex]['is_completed'] = 1;
      }
    }

    await _writeList(_installmentsKey, installmentRows);
    await _writeList(_paymentsKey, paymentRows);
    await _writeList(_loansKey, loanRows);
  }

  Future<Map<String, dynamic>> exportAll() async => {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'loans': await _readList(_loansKey),
        'installments': await _readList(_installmentsKey),
        'payments': await _readList(_paymentsKey),
      };

  Future<void> importAll(Map<String, dynamic> data) async {
    List<Map<String, Object?>> convert(dynamic value) =>
        (value as List? ?? const []).map((e) => Map<String, Object?>.from(e as Map)).toList();
    await _writeList(_loansKey, convert(data['loans']));
    await _writeList(_installmentsKey, convert(data['installments']));
    await _writeList(_paymentsKey, convert(data['payments']));
  }

  String encodeBackup(Map<String, dynamic> data) => const JsonEncoder.withIndent('  ').convert(data);
}
