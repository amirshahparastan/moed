import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/loan.dart';
import 'models/installment.dart';
import 'models/payment.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final p = join(await getDatabasesPath(), 'moed.db');
    return openDatabase(p, version: 1, onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'), onCreate: (db, _) async {
      await db.execute("""CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, type TEXT NOT NULL, lender TEXT NOT NULL,
        total_amount INTEGER NOT NULL, installment_amount INTEGER NOT NULL, installment_count INTEGER NOT NULL,
        start_date TEXT NOT NULL, frequency TEXT NOT NULL, frequency_value INTEGER NOT NULL DEFAULT 1,
        notes TEXT NOT NULL DEFAULT '', color_index INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL)""");
      await db.execute("""CREATE TABLE installments(
        id INTEGER PRIMARY KEY AUTOINCREMENT, loan_id INTEGER NOT NULL, sequence INTEGER NOT NULL,
        due_date TEXT NOT NULL, amount INTEGER NOT NULL, paid_amount INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending', paid_at TEXT,
        FOREIGN KEY(loan_id) REFERENCES loans(id) ON DELETE CASCADE)""");
      await db.execute("""CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT, installment_id INTEGER NOT NULL, amount INTEGER NOT NULL,
        paid_at TEXT NOT NULL, note TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(installment_id) REFERENCES installments(id) ON DELETE CASCADE)""");
      await db.execute('CREATE INDEX idx_installments_due ON installments(due_date)');
      await db.execute('CREATE INDEX idx_installments_loan ON installments(loan_id)');
    });
  }

  Future<List<Loan>> loans() async {
    final d = await db;
    return (await d.query('loans', orderBy: 'is_completed ASC, created_at DESC')).map(Loan.fromMap).toList();
  }
  Future<List<Installment>> installments({int? loanId}) async {
    final d = await db;
    final rows = await d.query('installments', where: loanId == null ? null : 'loan_id=?', whereArgs: loanId == null ? null : [loanId], orderBy: 'due_date ASC');
    return rows.map(Installment.fromMap).toList();
  }
  Future<List<Payment>> paymentsFor(int installmentId) async {
    final d = await db;
    return (await d.query('payments', where: 'installment_id=?', whereArgs: [installmentId], orderBy: 'paid_at DESC')).map(Payment.fromMap).toList();
  }

  Future<int> createLoan(Loan loan, List<Installment> Function(int id) buildInstallments) async {
    final d = await db;
    return d.transaction((txn) async {
      final map = loan.toMap()..remove('id');
      final id = await txn.insert('loans', map);
      final batch = txn.batch();
      for (final item in buildInstallments(id)) { final m = item.toMap()..remove('id'); batch.insert('installments', m); }
      await batch.commit(noResult: true);
      return id;
    });
  }

  Future<void> deleteLoan(int id) async { final d = await db; await d.delete('loans', where: 'id=?', whereArgs: [id]); }

  Future<void> updateInstallment(int id, {DateTime? dueDate, int? amount}) async {
    final d = await db; final values = <String,Object?>{};
    if (dueDate != null) values['due_date'] = dueDate.toIso8601String();
    if (amount != null) values['amount'] = amount;
    if (values.isNotEmpty) await d.update('installments', values, where: 'id=?', whereArgs: [id]);
  }

  Future<void> addPayment(Installment installment, int amount, {String note = ''}) async {
    final d = await db;
    await d.transaction((txn) async {
      final actual = amount.clamp(0, installment.remaining).toInt();
      if (actual <= 0) return;
      await txn.insert('payments', Payment(installmentId: installment.id!, amount: actual, paidAt: DateTime.now(), note: note).toMap()..remove('id'));
      final paid = installment.paidAmount + actual;
      final status = paid >= installment.amount ? 'paid' : 'partial';
      await txn.update('installments', {'paid_amount': paid, 'status': status, 'paid_at': status == 'paid' ? DateTime.now().toIso8601String() : null}, where: 'id=?', whereArgs: [installment.id]);
      if (status == 'paid') {
        final pending = Sqflite.firstIntValue(await txn.rawQuery("SELECT COUNT(*) FROM installments WHERE loan_id=? AND status!='paid'", [installment.loanId])) ?? 0;
        if (pending == 0) await txn.update('loans', {'is_completed': 1}, where: 'id=?', whereArgs: [installment.loanId]);
      }
    });
  }

  Future<Map<String,dynamic>> exportAll() async {
    final d = await db;
    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'loans': await d.query('loans'),
      'installments': await d.query('installments'),
      'payments': await d.query('payments'),
    };
  }

  Future<void> importAll(Map<String,dynamic> data) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.delete('payments'); await txn.delete('installments'); await txn.delete('loans');
      for (final item in (data['loans'] as List? ?? const [])) await txn.insert('loans', Map<String,Object?>.from(item as Map), conflictAlgorithm: ConflictAlgorithm.replace);
      for (final item in (data['installments'] as List? ?? const [])) await txn.insert('installments', Map<String,Object?>.from(item as Map), conflictAlgorithm: ConflictAlgorithm.replace);
      for (final item in (data['payments'] as List? ?? const [])) await txn.insert('payments', Map<String,Object?>.from(item as Map), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  String encodeBackup(Map<String,dynamic> data) => const JsonEncoder.withIndent('  ').convert(data);
}
